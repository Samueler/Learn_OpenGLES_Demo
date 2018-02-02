#version 300 es
precision mediump float;

in vec2 ourTexCoord;
in vec3 ourColor;
out vec4 fragColor;

uniform sampler2D ourTexture;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main() {
//    fragColor = vec4(ourColor, 1);
//    fragColor = texture(ourTexture, ourTexCoord) * vec4(ourColor, 1.0);
//    fragColor = texture(ourTexture, ourTexCoord);
    vec4 curColor = texture(ourTexture, ourTexCoord);
    float h = dot(curColor.rgb, W);
    vec4 fanshe = vec4(vec3(h),1.0);
    
    //2、获取该纹理附近的上下左右的纹理并求其去色，补色
    vec4 sample0,sample1,sample2,sample3;
    float h0,h1,h2,h3;
    float fstep=0.0015;
    sample0=texture(ourTexture,vec2(ourTexCoord.x-fstep,ourTexCoord.y-fstep));
    sample1=texture(ourTexture,vec2(ourTexCoord.x+fstep,ourTexCoord.y-fstep));
    sample2=texture(ourTexture,vec2(ourTexCoord.x+fstep,ourTexCoord.y+fstep));
    sample3=texture(ourTexture,vec2(ourTexCoord.x-fstep,ourTexCoord.y+fstep));
    //这附近的4个纹理值同样得进行去色（黑白化）
    h0 = dot(sample0.rgb, W);
    h1 = dot(sample1.rgb, W);
    h2 = dot(sample2.rgb, W);
    h3 = dot(sample3.rgb, W);
    //反相，得到每个像素的补色
    sample0 = vec4(vec3(1.0 - h0) ,1.0);
    sample1 = vec4(vec3(1.0 - h1),1.0);
    sample2 = vec4(vec3(1.0 - h2),1.0);
    sample3 = vec4(vec3(1.0 - h3),1.0);
    //3、对反相颜色值进行均值模糊
    vec4 color=(sample0+sample1+sample2+sample3) / 4.0;
    //4、颜色减淡，将第1步中的像素和第3步得到的像素值进行计算
    vec3 endColor = fanshe.rgb+(fanshe.rgb*color.rgb)/(1.0-color.rgb);
    fragColor = vec4(endColor, 1.0);
}
