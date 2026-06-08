//composite.fsh
#include "settings.glsl"
#imclude "raymarch.glsl"

//Uniforms
#ifdef OPTIFINE
    uniform float frameTime;
    #define TIME_VAR frameTime
#else
    uniform float frametime;
    #define TIME_VAR frametime
#endif

//Global variable to keep the track of performance
uniform float frameTimePrev;

int getQualitySteps() {
    //Adjust steps based on previous frame time
    if (frameTimePrev > FPS_THRESHOLD_LOW) {return STEPS_LOW;
    }
    else if (frameTimePrev > FPS_THRESHOLD_MED) {return STEPS_MED;
    }
    else {return STEPS_HIGH;
    }
}
void main() {
    //determine quality for thisframe
    int steps = getQualitySteps();
    //Ray origin and Ray direction
    vec2 uv = (gl_FragCoord.xy * 2.0 - 1920.0) / 1080.0;
    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    float d = rayMarch(ro, rd, steps);
    // Debug Visulizer: If running in low mode, apply a subtle Red tint
    #if DEBUG_MODE == 1
        vec3 Color = (steps == STEPS_LOW) ?
    vec3(0.2, 0.0, 0.0) : vec3(d / 5.0);
        gl_FragColor = vec4(Color, 1.0);
    #else
        //Main rendering logic
        gl_FragColor = vec4(vec3(d/5.0), 1.0);
    #endif
}