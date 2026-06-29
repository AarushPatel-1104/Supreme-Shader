#version 120
uniform sampler2D lightmap;
uniform sampler2D texture;
varying vec2 texCoord;

void main() {
    // Basic terrain draw call. 
    // FIXME: Not currently blending lightmap data—everything looks flat.
    // Need to multiply by lightmap texture once I figure out the coordinate mapping.
    // this is minecraft colour i wonder if he is black or white.
    gl_FragColor = texture2D(texture, texCoord);
}