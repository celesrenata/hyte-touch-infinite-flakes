#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float bass;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 color = texture(source, qt_TexCoord0);
    
    // Smooth bass-reactive color shift
    float intensity = bass * 0.6;
    color.rgb += vec3(intensity * 0.8, intensity * 0.3, intensity * 1.0);
    
    // Edge glow
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(qt_TexCoord0, center);
    float edgeGlow = bass * (1.0 - smoothstep(0.3, 0.7, dist));
    color.rgb += vec3(edgeGlow * 0.5, edgeGlow * 0.2, edgeGlow * 0.8);
    
    fragColor = color * qt_Opacity;
}
