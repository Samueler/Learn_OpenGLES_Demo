#version 300 es
precision mediump float;
out vec4 fragColor;
in vec3 ourColor;
//in vec4 ourPosition;
void main() {
    fragColor = vec4(ourColor, 1.0);
//    fragColor = ourPosition;
}

