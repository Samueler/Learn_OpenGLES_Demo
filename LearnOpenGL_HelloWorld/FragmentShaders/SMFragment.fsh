#version 300 es                               
precision mediump float;
in vec4 vertexColor;
out vec4 fragColor; // 从顶点着色器传入的变量（名称、数据类型相同）
void main() {
//    fragColor = vec4(1.0, 0, 0, 1.0);
    fragColor = vertexColor;
}
