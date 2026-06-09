/* * ============================================================================
 * Composite1.fsh - Cinematic Post-Processing Stack
 * ============================================================================
 * Enhances the raw rendered output with filmic properties to simulate a 
 * physical camera lens and temporal smoothness.
 * ----------------------------------------------------------------------------
 */

#include "settings.glsl"

// --- Uniforms ---
// These MUST be declared here to access the screen dimensions
uniform float viewWidth;
uniform float viewHeight;

// --- Inputs ---
uniform sampler2D composite;     // Current frame buffer
uniform sampler2D prevComposite; // Previous frame buffer (used for temporal effects)

void main() {
    // [1] UV NORMALIZATION
    // Maps screen coordinates to a 0.0 - 1.0 range.
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    
    // [2] LENS DISTORTION: Geometric Correction
    // Distorts coordinates from the center to simulate barrel distortion 
    // common in wide-angle physical glass lenses.
    vec2 distUV = uv - 0.5;
    distUV *= (1.0 + dot(distUV, distUV) * 0.15);
    vec2 centeredUV = distUV + 0.5;

    // [3] TEMPORAL BLUR: Motion Smoothing
    // Blends the current frame with the previous buffer to reduce jitter 
    // and create a soft, cinematic motion-trail effect.
    vec3 current = texture2D(composite, centeredUV).rgb;
    vec3 previous = texture2D(prevComposite, centeredUV).rgb;
    vec3 finalColor = mix(current, previous, 0.5);
    
    // [4] VIGNETTE: Focus Enhancement
    // Darkens the corners of the frame using an inverse falloff gradient
    // to guide the viewer's gaze toward the center of the image.
    finalColor *= smoothstep(0.8, 0.2, length((uv - 0.5) * 2.0));
    
    // [5] OUTPUT
    // Final composite pixel color written to the screen buffer.
    gl_FragColor = vec4(finalColor, 1.0);
}

/* * ----------------------------------------------------------------------------
 * Visualizing the Post-Processing Pipeline:
 */