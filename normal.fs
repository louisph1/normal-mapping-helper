#version 330 core

in vec2 uv;

out vec4 fragColor;

void main() {
    float val = 1 - (uv.x*uv.x) - (uv.y*uv.y);
    float height;
    if (val >= 0) {
        height = sqrt(val);
        fragColor = vec4((uv + 1) / 2, height, 1);
    } else {
        fragColor = vec4(0,0,0,0);
    }
}