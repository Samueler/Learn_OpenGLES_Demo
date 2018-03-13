#version 300 es

precision mediump float;

in vec2 ourTexCoord;
out vec4 fragColor;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform mat3 colorConversionMatrix;

void  main() {
    mediump vec3 yuv;
    lowp vec3 rgb;

    yuv.x = (texture(SamplerY, ourTexCoord).r);
    yuv.yz = (texture(SamplerUV, ourTexCoord).ra - vec2(0.5));
    rgb = colorConversionMatrix * yuv;

    fragColor = vec4(rgb,1);
}

