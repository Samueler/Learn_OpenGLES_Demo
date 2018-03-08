#version 300 es

precision mediump float;

in vec2 ourTexCoor;

uniform sampler2D samplerY;
uniform sampler2D samplerUV;
uniform mat3 yuvConversationColorMatrix;

void  main() {
    
    mediump vec3 ourYUV;
    lowp vec3 ourRGB;
    
    ourYUV.x = texture2D(samplerY, ourTexCoor).r;
    ourYUV.yz = texture2D(samplerUV, ourTexCoor).gb;
    
    ourRGB = yuvConversationColorMatrix * ourYUV;
    
    gl_FragColor = vec4(ourRGB, 1.0);
}
