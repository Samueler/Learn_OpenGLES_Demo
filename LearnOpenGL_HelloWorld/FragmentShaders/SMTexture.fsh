#version 300 es
precision mediump float;

in vec2 ourTexCoord;
in vec3 ourColor;
out vec4 fragColor;

uniform sampler2D ourTexture;

void main() {
//    fragColor = vec4(ourColor, 1);
    fragColor = texture(ourTexture, ourTexCoord);
}
