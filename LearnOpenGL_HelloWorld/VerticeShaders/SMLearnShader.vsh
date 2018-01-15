#version 300 es
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 ourColor;
//uniform float ourOffset;
//out vec4 ourPosition;

void main() {
    gl_Position = vec4(aPos, 1);
//    ourPosition = vec4(aPos, 1);
//    gl_Position = ourPosition;
    
//    gl_Position = vec4(aPos.x, -aPos.y, aPos.z, 1.0); // 将三角形位置倒转
//    gl_Position = vec4(aPos.x + ourOffset, aPos.yz, 1.0); // 使用uniform增加偏移属性
    ourColor = aColor;
}
