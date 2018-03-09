#version 300 es

precision mediump float;

in vec2 ourTexCoord;
out vec4 fragColor;

uniform sampler2D samplerY, samplerUV;
uniform mat3 YUVToRGBColorMatrix;

void  main() {
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = (texture(samplerY, ourTexCoord).r);
    yuv.yz = (texture(samplerUV, ourTexCoord).ra - vec2(0.5, 0.5));
    rgb = YUVToRGBColorMatrix * yuv;
//    fragColor = vec4(rgb,1);
    fragColor = vec4(0.5, 0.2, 0.7, 1.0);
}
