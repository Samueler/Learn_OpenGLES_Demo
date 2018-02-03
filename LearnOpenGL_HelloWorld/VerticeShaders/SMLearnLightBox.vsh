#version 300 es

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out vec3 Normal, FragPos;

uniform mat4 projectMatrix, viewMatrix, modelMatrix;

void main() {
    gl_Position = projectMatrix * viewMatrix * modelMatrix * vec4(aPos, 1.0);
    Normal = mat3(transpose(inverse(modelMatrix))) * aNormal;
    FragPos = vec3(modelMatrix * vec4(aPos, 1.0));
}
