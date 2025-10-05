import QtQuick 2.15
import ".." 1.0

Rectangle {
    id: visualizer
    color: "transparent"
    
    property var audioData: []
    property int barCount: 32
    property real maxHeight: height * 0.8
    property bool audioActive: false
    
    Timer {
        interval: 50
        running: true
        repeat: true
        onTriggered: updateAudioData()
    }
    
    function updateAudioData() {
        // Get audio spectrum data from PulseAudio monitor
        SystemMonitor.exec("pactl list sink-inputs | grep -q 'State: RUNNING' && echo 'active' || echo 'inactive'", function(output) {
            audioActive = output.trim() === 'active'
            
            if (audioActive) {
                // Use cava or similar for real audio spectrum analysis
                SystemMonitor.exec("timeout 0.1s cava -p /dev/stdin <<< 'bars=32\nraw_target=/dev/stdout\ndata_format=raw' 2>/dev/null | od -An -tu1 | head -32 || echo ''", function(spectrumOutput) {
                    if (spectrumOutput.trim()) {
                        var values = spectrumOutput.trim().split(/\s+/)
                        audioData = []
                        for (var i = 0; i < Math.min(barCount, values.length); i++) {
                            var normalizedValue = (parseInt(values[i]) || 0) / 255.0
                            audioData.push(normalizedValue * maxHeight)
                        }
                    } else {
                        // Fallback: detect audio activity and create simple visualization
                        SystemMonitor.exec("pactl list sink-inputs | grep -A 5 'State: RUNNING' | grep 'Volume:' | head -1 | grep -oE '[0-9]+%' | head -1 | tr -d '%'", function(volumeOutput) {
                            var volume = parseInt(volumeOutput) || 0
                            audioData = []
                            for (var j = 0; j < barCount; j++) {
                                var height = (volume / 100.0) * maxHeight * (0.3 + 0.7 * Math.random())
                                audioData.push(height)
                            }
                        })
                    }
                    barsRepeater.model = audioData
                })
            } else {
                // No audio playing - show minimal bars
                audioData = []
                for (var k = 0; k < barCount; k++) {
                    audioData.push(2)
                }
                barsRepeater.model = audioData
            }
        })
    }
    
    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        text: audioActive ? "♪ Music Visualizer" : "♫ No Audio"
        color: audioActive ? "#4ecdc4" : "#666666"
        font.pixelSize: 12
        opacity: 0.8
    }
    
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 2
        
        Repeater {
            id: barsRepeater
            model: audioData
            
            Rectangle {
                width: Math.max(2, (visualizer.width - (barCount * 2)) / barCount)
                height: Math.max(2, modelData || 2)
                color: audioActive ? 
                    Qt.hsla((index / barCount) * 0.8, 0.8, 0.6, 0.8) : 
                    Qt.hsla(0, 0, 0.3, 0.5)
                radius: 1
                
                Behavior on height {
                    NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
