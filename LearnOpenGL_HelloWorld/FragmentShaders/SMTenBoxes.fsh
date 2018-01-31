#version 300 es

precision mediump float;

in vec2 my_texCoor;
out vec4 fragColor;

uniform sampler2D boxTexture, smileTexture;

void main() {
    fragColor = mix(texture(boxTexture, my_texCoor), texture(smileTexture, my_texCoor), 0.2);
}
