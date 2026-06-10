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

// --- Preprocessor Compatibility ---
#ifdef OPTIFINE
    unifrom float frameTime;
    #define TIME_VAR frameTime
#else
    uniform float frametime;
    #define TIME_VAR frametime
#endif

void main() {
    // [1] PERFORMANCE: Dynamic Quality Scaling
    // Adjusts step count based on frame budget to maintain consistent performance.
    int steps = getQualitySteps();
    
    // [2] CAMERA: Projection Setup
    // Maps pixel coordinates (UV) to Normalized Device Coordinates and 
    // calculates the Ray Origin (ro) and Ray Direction (rd).
    vec2 uv = (gl_FragCoord.xy * 2.0 - vec2(viewWidth, viewHeight)) / viewHeight;
    vec3 ro = vec3(sin(TIME_VAR * 0.2) * 2.0, 0.0, TIME_VAR * 1.5); 
    vec3 rd = normalize(vec3(uv, 1.0));
    
    // [3] MARCHING: SDF Traversal
    // Casts a ray through the Signed Distance Field to find intersection depth.
    float d = rayMarch(ro, rd, steps);
    
    // [4] LIGHTING: Surface Shading & Atmospheric Effects
    vec3 finalColor = vec3(0.0);
    
    if (d < 100.0) { 
        // --- Surface Calculation ---
        vec3 p = ro + rd * d;          // Collision point
        vec3 n = getNormal(p);         // Surface normal via gradient estimation
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(n, lightDir), 0.0);
        
        // [5] Temporal Decay: Creates a pulsing light effect that fades in and out
        float pulse = sin(TIME_VAR * 0.5) * 0.5 + 0.5; // Oscillates between 0 and 1
        diff *= pulse; // The light intensity now decays/pulses over time
        
        // --- Material & Glow ---
        vec3 objColor = getColor(p);
        
        // Bloom: Boosts high-intensity areas for a "Glow" effect
        vec3 bloom = pow(objColor * (diff + 0.5), vec3(2.0)); 
        finalColor = (objColor * (diff + 0.2)) + (bloom * 0.5);
        
        // Exponential Fog: Attenuates light density over distance to simulate depth.
        finalColor *= exp(-d * 0.05); 
    } 
    else {
        // --- Environment Rendering (Skybox) ---
        // A simple horizon-based vertical gradient to mimic sky depth.
        float sky = pow(max(rd.y, 0.0), 0.5);
        finalColor = mix(vec3(0.02, 0.02, 0.05), vec3(0.1, 0.1, 0.2), sky);
    }

    // [6] POST-FX: Tone Mapping
    // Normalizes colors into the displayable range (Reinhard mapping)
    // and outputs the final color to the frame buffer.
    finalColor = finalColor / (finalColor + vec3(1.0));
    gl_FragColor = vec4(finalColor, 1.0);
}

/* * ----------------------------------------------------------------------------
 * Rendering Logic Visualization:
 */