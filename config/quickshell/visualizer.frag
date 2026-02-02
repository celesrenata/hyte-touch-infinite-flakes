#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float bass;
    float mid;
    float treble;
    float overall;
    float time;
    float enablePulse;
    float enableGlow;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 color = texture(source, qt_TexCoord0);
    
    // Background pulse - hue shift based on frequency
    if (enablePulse > 0.5) {
        float hueShift = bass * 0.1 - treble * 0.05;
        
        // RGB to HSV
        vec3 hsv;
        float cmax = max(max(color.r, color.g), color.b);
        float cmin = min(min(color.r, color.g), color.b);
        float delta = cmax - cmin;
        
        if (delta > 0.0) {
            if (cmax == color.r) {
                hsv.x = mod((color.g - color.b) / delta, 6.0);
            } else if (cmax == color.g) {
                hsv.x = (color.b - color.r) / delta + 2.0;
            } else {
                hsv.x = (color.r - color.g) / delta + 4.0;
            }
            hsv.x = hsv.x / 6.0 + hueShift;
            hsv.y = delta / cmax;
        } else {
            hsv.x = 0.0;
            hsv.y = 0.0;
        }
        hsv.z = cmax;
        
        // HSV to RGB
        float h = hsv.x * 6.0;
        float c = hsv.z * hsv.y;
        float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
        float m = hsv.z - c;
        
        vec3 rgb;
        if (h < 1.0) rgb = vec3(c, x, 0.0);
        else if (h < 2.0) rgb = vec3(x, c, 0.0);
        else if (h < 3.0) rgb = vec3(0.0, c, x);
        else if (h < 4.0) rgb = vec3(0.0, x, c);
        else if (h < 5.0) rgb = vec3(x, 0.0, c);
        else rgb = vec3(c, 0.0, x);
        
        color.rgb = rgb + m;
    }
    
    // Brightness pulse with bass
    color.rgb *= 1.0 + bass * 0.2;
    
    // Glow effect on edges
    if (enableGlow > 0.5) {
        vec2 center = vec2(0.5, 0.5);
        float dist = distance(qt_TexCoord0, center);
        float vignette = 1.0 - smoothstep(0.3, 0.8, dist);
        color.rgb += vec3(overall * 0.3) * (1.0 - vignette);
    }
    
    // Chromatic aberration on bass hits
    if (bass > 0.5) {
        vec2 offset = (qt_TexCoord0 - 0.5) * bass * 0.01;
        float r = texture(source, qt_TexCoord0 + offset).r;
        float b = texture(source, qt_TexCoord0 - offset).b;
        color.r = mix(color.r, r, bass * 0.5);
        color.b = mix(color.b, b, bass * 0.5);
    }
    
    fragColor = color * qt_Opacity;
}
