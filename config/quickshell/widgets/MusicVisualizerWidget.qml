import QtQuick 2.15

Rectangle {
    id: visualizer
    color: "transparent"
    
    property var audioData: []
    property int barCount: 32
    property real maxHeight: height * 0.8
    
    Timer {
        interval: 50
        running: true
        repeat: true
        onTriggered: updateAudioData()
    }
    
    function updateAudioData() {
        Process {
            program: "sh"
            arguments: ["-c", "pactl list sink-inputs | grep -A 20 'application.name = \"Music\"' | grep 'Volume:' | head -1 || echo 'Volume: 0%'"]
            onFinished: {
                // Simulate audio bars for now - replace with actual audio analysis
                audioData = []
                for (let i = 0; i < barCount; i++) {
                    audioData.push(Math.random() * maxHeight)
                }
                barsRepeater.model = audioData
            }
        }
    }
    
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        
        Repeater {
            id: barsRepeater
            model: audioData
            
            Rectangle {
                width: (visualizer.width - (barCount * 2)) / barCount
                height: modelData || 5
                color: Qt.hsla((index / barCount) * 0.8, 0.8, 0.6, 0.7)
                radius: 2
                
                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
            }
        }
    }
    
    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        text: "Music Visualizer"
        color: "white"
        font.pixelSize: 12
        opacity: 0.7
    }
}
