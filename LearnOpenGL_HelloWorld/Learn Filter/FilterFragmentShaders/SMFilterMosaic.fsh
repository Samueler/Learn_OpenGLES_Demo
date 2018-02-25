#version 300 es

precision mediump float;

in vec2 ourTexCoord;
out vec4 fragColor;

uniform sampler2D ourTexture;

const vec2 texSize = vec2(500.0, 500.0);
const vec2 mosaicSize = vec2(8.0, 8.0);

void main() {
    vec2 intXY = vec2(ourTexCoord.x * texSize.x, ourTexCoord.y * texSize.y);
    vec2 xyMosaic = vec2(floor(intXY.x / mosaicSize.x) * mosaicSize.x, floor(intXY.y / mosaicSize.y) * mosaicSize.y);
    vec2 uvMosaic = vec2(xyMosaic.x / texSize.x, xyMosaic.y / texSize.y);
    fragColor = texture(ourTexture, uvMosaic);
}


