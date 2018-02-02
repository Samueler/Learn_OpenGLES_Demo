#version 300 es

precision mediump float;

out vec4 fragColor;

uniform vec3 lightColor, boxColor;

void main() {
    float ambientStrength = 0.1;
    vec3 ambientBoxColor = ambientStrength * boxColor;
    fragColor = vec4(lightColor * ambientBoxColor, 1.0);
}
