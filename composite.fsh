#version 120
/* * ============================================================================
 * Composite.fsh - The Master Rendering Pipeline
 * ============================================================================
 * Orchestrates the ray-marcher, manages lighting, and applies 
 * atmospheric post-processing effects to generate the final frame.
 * ----------------------------------------------------------------------------
 */

#include "settings.glsl"
#include "raymarch.glsl"

// --- Global Uniforms ---
uniform float frameTimePrev;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D gcolor; // Required to read the Minecraft game world

// --- Preprocessor Compatibility ---
#ifdef OPTIFINE
    uniform float frameTime;
    #define TIME_VAR frameTime
#else
    uniform float frametime;
    #define TIME_VAR frametime
#endif

// Performance-based quality scaling
int getQualitySteps() {
    if (frameTimePrev > FPS_THRESHOLD_LOW) return STEPS_LOW;
    if (frameTimePrev > FPS_THRESHOLD_MED) return STEPS_MED;
    return STEPS_HIGH;
}

void main() {
    // [1] PERFORMANCE: Dynamic Quality Scaling
    int steps = getQualitySteps();
    
    // [2] CAMERA: Projection Setup
    vec2 uv = (gl_FragCoord.xy * 2.0 - vec2(viewWidth, viewHeight)) / viewHeight;
    vec3 ro = vec3(sin(TIME_VAR * 0.2) * 2.0, 0.0, TIME_VAR * 1.5); 
    vec3 rd = normalize(vec3(uv, 1.0));
    
    // [3] MARCHING: SDF Traversal
    float d = rayMarch(ro, rd, steps);
    
    // [4] LIGHTING: Surface Shading & Atmospheric Effects
    vec3 finalColor = vec3(0.0);
    
    // Sample the background Minecraft frame
    vec3 mcColor = texture2D(gcolor, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).rgb;
    
    if (d < 100.0) { 
        // --- Surface Calculation ---
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(n, lightDir), 0.0);
        
        // [5] Temporal Decay: Creates a pulsing light effect
        float pulse = sin(TIME_VAR * 0.5) * 0.5 + 0.5;
        diff *= pulse;
        
        // --- Material & Glow ---
        vec3 objColor = getColor(p);
        vec3 bloom = pow(objColor * (diff + 0.5), vec3(2.0)); 
        finalColor = (objColor * (diff + 0.2)) + (bloom * 0.5);
        finalColor *= exp(-d * 0.05);
        
        // Output the spheres blended with the scene
        gl_FragColor = vec4(finalColor / (finalColor + vec3(1.0)), 1.0);
    } else {
        // [6] ENVIRONMENT: Output Minecraft game world
        gl_FragColor = vec4(mcColor, 1.0);
    }
}