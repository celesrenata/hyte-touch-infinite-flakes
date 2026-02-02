varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform lowp float bass;

void main() {
    vec4 color = texture2D(source, qt_TexCoord0);
    
    // Make it super obvious - full bright colors on bass
    if (bass > 0.5) {
        color.rgb = vec3(1.0, 0.0, 1.0); // Bright magenta
    } else if (bass > 0.1) {
        color.rgb = mix(color.rgb, vec3(1.0, 0.5, 1.0), bass * 2.0);
    }
    
    gl_FragColor = color;
}
