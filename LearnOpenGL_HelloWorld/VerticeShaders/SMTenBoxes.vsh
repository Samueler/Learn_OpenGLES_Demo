#version 300 es

layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec2 a_texCoor;

out vec2 my_texCoor;

uniform mat4 modelMatrix, viewMatrix, projectMatrix;

void main() {
    gl_Position = projectMatrix * viewMatrix * modelMatrix * vec4(a_Pos, 1.0);
    my_texCoor = a_texCoor;
}
