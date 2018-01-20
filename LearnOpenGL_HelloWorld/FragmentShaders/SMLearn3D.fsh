#version 300 es
precision mediump float;

in vec2 ourTexCoord;
out vec4 fragColor;
uniform sampler2D boxTexture;
uniform sampler2D smileTexture;

void main() {
    fragColor = mix(texture(boxTexture, ourTexCoord), texture(smileTexture, ourTexCoord), 0.2);
}
