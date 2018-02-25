#version 300 es

precision mediump float;

in vec2 ourTexCoord;

out vec4 fragColor;

uniform sampler2D ourTexture;

const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

void main() {
    vec4 textureColor = texture(ourTexture, ourTexCoord);
    float luminance = dot(textureColor.rgb, luminanceWeighting);

    fragColor = vec4(vec3(luminance), 1.0);
}
