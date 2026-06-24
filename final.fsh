#version 120
/* * ============================================================================
 * final.fsh - The Display Output Stage
 * ============================================================================
 * Maps internal HDR colors to monitor range.
 * ----------------------------------------------------------------------------
 */

uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D composite; 

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    // [2] GAMMA CORRECTION
    // Maps linear space to sRGB. 
    // TODO: Verify if this double-gamma corrects on some drivers; 
    // sometimes Minecraft does its own conversion.
    vec3 color = texture2D(composite, uv).rgb;
    color = pow(color, vec3(1.0 / 2.2));

    gl_FragColor = vec4(color, 1.0);
}