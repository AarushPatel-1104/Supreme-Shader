#version 120

void main() {
    // This passes the vertex data through to the GPU
    gl_Position = ftransform();
}