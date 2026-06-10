#version 120
/* * ============================================================================
 * final.fsh - The Display Output Stage
 * ============================================================================
 * The terminal node of the rendering pipeline. This stage performs final
 * gamma correction and maps the internal HDR colors to the monitor's 
 * output range (LDR).
 * ----------------------------------------------------------------------------
 */

// --- Uniforms ---
uniform float viewWidth;
uniform float viewHeight;

// --- Inputs ---
uniform sampler2D composite; // Receives the processed frame from composite1

void main() {
    // [1] UV NORMALIZATION
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    // [2] GAMMA CORRECTION
    // Maps the linear color space of our ray-marcher to sRGB for 
    // accurate display on standard monitors.
    vec3 color = texture2D(composite, uv).rgb;
    color = pow(color, vec3(1.0 / 2.2));

    // [3] OUTPUT
    // Write the final corrected color to the screen.
    gl_FragColor = vec4(color, 1.0);
}

/* * ----------------------------------------------------------------------------
 * Rendering Logic Visualization:
 */