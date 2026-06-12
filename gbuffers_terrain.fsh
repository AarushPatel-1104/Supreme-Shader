#version 120
uniform sampler2D lightmap;
uniform sampler2D texture;
varying vec2 texCoord;

void main() {
    // This simple code ensures the terrain is drawn into the buffer
    gl_FragColor = texture2D(texture, texCoord);
}