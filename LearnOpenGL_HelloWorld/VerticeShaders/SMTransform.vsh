#version 300 es

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 ourTexCoord;

uniform mat4 transformMatrix;

void main() {
//    gl_Position = vec4(aPos, 1.0);
    gl_Position = vec4(aPos, 1.0) * transformMatrix;
    ourTexCoord = aTexCoord;
}
