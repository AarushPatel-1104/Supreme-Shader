//composite.fsh
#include "settings.glsl"

//Uniforms provided by Minecraft/Iris
uniform float frametime;

//Global variable to keep the track of performance
float smoothedFrameTime = 0.0;

int getQualitySteps() {
    //Exponential Moving Average(Low-Pass Filter)
    smoothedFrameTime = mix(smoothedFrameTime, frametime, SMOOTHING_FACTOR);
    //Adjust steps based on smoothed performance
    if (smoothedFrameTime > FPS_THRESHOLD_LOW) {return STEPS_LOW;
    }
    else if (smoothedFrameTime > FPS_THRESHOLD_MED) {return STEPS_MED;
    }
    else {return STEPS_HIGH;
    }
}
void main() {
    //determine quality for thisframe
    int steps = getQualitySteps();
    //Placeholder for future Ray MArching call
    // Debug Visulizer: If running in low mode, apply a subtle Red tint
    #if DEBUG_MODE == 1
        vec3 debugColor = (steps == STEPS_LOW) ?
    vec3(0.2, 0.0, 0.0) : vec3(0.0);
        gl_FragColor = vec4(debugColor, 1.0);
    #else
        //Main rendering logic
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    #endif
}