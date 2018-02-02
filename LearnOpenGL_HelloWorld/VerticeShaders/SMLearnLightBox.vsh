#version 300 es

layout (location = 0) in vec3 aPos;

uniform mat4 projectMatrix, viewMatrix, modelMatrix;

void main() {
    gl_Position = projectMatrix * viewMatrix * modelMatrix * vec4(aPos, 1.0);
}
