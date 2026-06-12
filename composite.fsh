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
uniform vec3 cameraPosition;    // ADDED: The actual player position
uniform sampler2D gcolor;       // Minecraft scene color
uniform sampler2D depthtex0;    // Minecraft scene depth

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
    
    // CHANGED: Using cameraPosition to sync with Minecraft's actual movement
    vec3 ro = cameraPosition; 
    
    // This ray direction setup handles the perspective projection
    vec3 rd = normalize(vec3((gl_FragCoord.xy * 2.0 - vec2(viewWidth, viewHeight)) / viewHeight, 1.0));
    
    // [3] MARCHING: SDF Traversal
    float d = rayMarch(ro, rd, steps);
    
    // [4] INTEGRATION: Sample Minecraft scene and depth
    vec3 mcColor = texture2D(gcolor, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;
    
    // [5] RENDERING LOGIC: Depth-Aware Composition
    // The multiplier '200.0' scales the depth buffer to world units
    bool isObjectCloser = (d < 100.0) && (d < (depth * 200.0)); 

    if (isObjectCloser) { 
        // --- Surface Calculation ---
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(n, lightDir), 0.0);
        
        // Material & Glow
        vec3 objColor = getColor(p);
        vec3 finalColor = objColor * (diff + 0.3);
        
        // [ALPHA BLENDING] 
        // We blend the object color (objColor) with the world color (mcColor)
        // 0.3 is the transparency level (70% transparent)
        vec3 blendedColor = mix(mcColor, finalColor, 0.3);
        
        gl_FragColor = vec4(blendedColor, 1.0);
    } else {
        // [6] ENVIRONMENT: Output Minecraft game world
        gl_FragColor = vec4(mcColor, 1.0);
        gl_FragDepth = depth; 
    }
}