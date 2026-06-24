#version 120
/* * ============================================================================
 * Composite.fsh - The Master Rendering Pipeline
 * ============================================================================
 * Handles the ray-marcher, lighting, and post-processing for the volume pass.
 * ----------------------------------------------------------------------------
 */

#include "settings.glsl"
#include "raymarch.glsl"

// --- Global Uniforms ---
uniform float frameTimePrev;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;    
uniform sampler2D gcolor;       
uniform sampler2D depthtex0;    

// --- Preprocessor Compatibility ---
#ifdef OPTIFINE
    uniform float frameTime;
    #define TIME_VAR frameTime
#else
    uniform float frametime;
    #define TIME_VAR frametime
#endif

// TODO: fix spike in FPS when new chunks load; current logic dies hard then.
int getQualitySteps() {
    if (frameTimePrev > FPS_THRESHOLD_LOW) return STEPS_LOW;
    if (frameTimePrev > FPS_THRESHOLD_MED) return STEPS_MED;
    return STEPS_HIGH;
}

void main() {
    int steps = getQualitySteps();
    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    
    // Sync ro with cameraPosition. 
    // If jitter occurs, check view matrix; math here is simple enough.
    vec3 ro = cameraPosition; 
    vec3 rd = normalize(vec3((gl_FragCoord.xy * 2.0 - vec2(viewWidth, viewHeight)) / viewHeight, 1.0));
    
    // [3] MARCHING: SDF Traversal
    float d = rayMarch(ro, rd, steps);
    
    vec3 mcColor = texture2D(gcolor, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;
    
    // [5] RENDERING LOGIC: Depth-Aware Composition
    // HACK: 200.0 is a magic number because linearizing the depth buffer failed. 
    // This breaks if render distance changes in game settings.
    bool isObjectCloser = (d < 100.0) && (d < (depth * 200.0)); 

    if (isObjectCloser) { 
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(n, lightDir), 0.0);
        
<<<<<<< HEAD
        // [5] Temporal Decay: Creates a pulsing light effect
        float pulse = sin(TIME_VAR * 0.5) * 0.5 + 0.5;
        diff *= pulse;
        
        // --- Material & Glow ---
        vec3 objColor = getColor(p);
        vec3 bloom = pow(objColor * (diff + 0.5), vec3(2.0)); 
        finalColor = (objColor * (diff + 0.2)) + (bloom * 0.5);
        finalColor *= exp(-d * 0.05);
        
        // Apply tone mapping and output
        gl_FragColor = vec4(finalColor / (finalColor + vec3(1.0)), 1.0);
    } else {
        // [6] ENVIRONMENT: Output the raw Minecraft world
=======
        vec3 objColor = getColor(p);
        vec3 finalColor = objColor * (diff + 0.3);
        
        // FIXME: 0.3 blend is hardcoded for now. 
        // Need to link this to time-of-day uniforms later.
        vec3 blendedColor = mix(mcColor, finalColor, 0.3);
        
        gl_FragColor = vec4(blendedColor, 1.0);
    } else {
        // [6] ENVIRONMENT: Passthrough
        // Just dump the G-buffer result if nothing hit in the raymarcher.
>>>>>>> 639449d (Final Polish along with few changes)
        gl_FragColor = vec4(mcColor, 1.0);
        gl_FragDepth = depth; 
    }
}