#version 300 es
layout (location = 0) in vec4 vPosition;
out vec4 fragColor;
void main() {
    gl_Position = vPosition;
}                                             
