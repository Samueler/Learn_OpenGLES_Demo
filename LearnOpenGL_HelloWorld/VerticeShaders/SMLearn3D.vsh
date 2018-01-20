#version 300 es
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 ourTexCoord;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectMatrix;

void main() {
//    gl_Position = vec4(aPos, 1.0);
    gl_Position = projectMatrix * viewMatrix * modelMatrix * vec4(aPos, 1.0);
    ourTexCoord = aTexCoord;
}
