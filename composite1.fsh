#version 120
/* * ============================================================================
 * Composite1.fsh - Cinematic Post-Processing Stack
 * ============================================================================
 * Handles lens effects and temporal smoothing for the final image.
 * ----------------------------------------------------------------------------
 */

#include "settings.glsl"

uniform float viewWidth;
uniform float viewHeight;

uniform sampler2D composite;      
uniform sampler2D prevComposite;  

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    
    // [2] LENS DISTORTION
    // barrel distortion. 0.15 is arbitrary; looks okay but check if it 
    // stretches too much at high resolutions.
    vec2 distUV = uv - 0.5;
    distUV *= (1.0 + dot(distUV, distUV) * 0.15);
    vec2 centeredUV = distUV + 0.5;

    // [3] TEMPORAL BLUR
    // blending prev frame for motion smoothing. 
    // FIXME: 0.5 is way too high, causes massive ghosting. 
    // Need to implement a proper reprojection matrix later.
    vec3 current = texture2D(composite, centeredUV).rgb;
    vec3 previous = texture2D(prevComposite, centeredUV).rgb;
    vec3 finalColor = mix(current, previous, 0.5);
    
    // [4] VIGNETTE
    // Darkens corners. smoothstep feels better than raw math here.
    finalColor *= smoothstep(0.8, 0.2, length((uv - 0.5) * 2.0));
    
    gl_FragColor = vec4(finalColor, 1.0);
}