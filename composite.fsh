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
uniform sampler2D gcolor;   // Minecraft scene color

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
    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec3 ro = vec3(sin(TIME_VAR * 0.2) * 2.0, 0.0, TIME_VAR * 1.5); 
    vec3 rd = normalize(vec3((gl_FragCoord.xy * 2.0 - vec2(viewWidth, viewHeight)) / viewHeight, 1.0));
    
    // [3] MARCHING: SDF Traversal
    float d = rayMarch(ro, rd, steps);
    
    // [4] INTEGRATION: Sample Minecraft scene using the declared gcolor sampler
    vec3 mcColor = texture2D(gcolor, texCoord).rgb;
    
    // [5] RENDERING LOGIC
    if (d < 100.0) { 
        // --- Surface Calculation ---
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(n, lightDir), 0.0);
        
        // Temporal Pulse Effect
        float pulse = sin(TIME_VAR * 0.5) * 0.5 + 0.5;
        diff *= pulse;
        
        // --- Material & Glow ---
        vec3 objColor = getColor(p);
        vec3 bloom = pow(objColor * (diff + 0.5), vec3(2.0)); 
        vec3 finalColor = (objColor * (diff + 0.2)) + (bloom * 0.5);
        finalColor *= exp(-d * 0.05);
        
        gl_FragColor = vec4(finalColor / (finalColor + vec3(1.0)), 1.0);
    } else {
        // [6] ENVIRONMENT: Output Minecraft game world
        gl_FragColor = vec4(mcColor, 1.0);
        
        // Force depth to far plane to prevent clipping
        gl_FragDepth = 1.0; 
    }
}