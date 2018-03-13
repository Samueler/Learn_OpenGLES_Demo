#version 300 es

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 ourTexCoord;

void main() {
    
    const float degree = radians(-90.0);
    const mat3 rotate = mat3(
                              cos(degree),  sin(degree), 0.0,
                             -sin(degree), -cos(degree), 0.0,
                                      0.0,          0.0, 1.0
                             );
    gl_Position = vec4(rotate * aPos, 1.0);
    ourTexCoord = aTexCoord;
}

