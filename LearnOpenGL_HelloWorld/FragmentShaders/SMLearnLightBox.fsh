#version 300 es

precision mediump float;

out vec4 fragColor;
in vec3 Normal, FragPos;

uniform vec3 lightColor, boxColor, lightPos, viewerPos;

void main() {
    // 环境光照
//    float ambientStrength = 0.1;
//    vec3 ambientBoxColor = ambientStrength * boxColor;
//    fragColor = vec4(lightColor * ambientBoxColor, 1.0);
    
    // 漫反射
    float ambientStrength = 0.1;
    float speculatStrength = 0.5;
    
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    
    vec3 viewerDir = normalize(viewerPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewerDir, reflectDir), 0.0), 32.0);
    vec3 specular = speculatStrength * spec * lightColor;
    
    vec3 result = (ambientStrength + diffuse + specular) * boxColor;
    fragColor = vec4(result, 1.0);
}
