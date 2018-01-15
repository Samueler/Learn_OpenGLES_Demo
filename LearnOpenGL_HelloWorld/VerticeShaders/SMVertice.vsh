#version 300 es
layout (location = 0) in vec4 vPosition;

// 通过顶点着色器控制片段着色器的颜色
out vec4 vertexColor;

void main() {
    gl_Position = vPosition;
    // 将颜色从顶点着色器传入片段着色器（out）
    vertexColor = vec4(1, 0.8, 0.0, 1.0);
}
