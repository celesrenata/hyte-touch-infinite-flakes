varying highp vec2 qt_TexCoord0;
uniform sampler2D source;

void main() {
    gl_FragColor = texture2D(source, qt_TexCoord0);
}
