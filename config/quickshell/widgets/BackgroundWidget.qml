import QtQuick 2.15
import QtMultimedia 5.15

Rectangle {
    id: bgWidget
    color: "transparent"
    
    property string currentBg: "/var/lib/touchdisplay/backgrounds/default.jpg"
    property var bgList: []
    property int currentIndex: 0
    
    Component.onCompleted: loadBackgrounds()
    
    function loadBackgrounds() {
        Process {
            program: "find"
            arguments: ["/var/lib/touchdisplay/backgrounds", "-type", "f", "-name", "*.jpg", "-o", "-name", "*.png", "-o", "-name", "*.mp4", "-o", "-name", "*.gif"]
            onFinished: {
                bgList = stdout.split('\n').filter(f => f.length > 0)
                if (bgList.length > 0) currentBg = bgList[0]
            }
        }
    }
    
    Image {
        id: staticBg
        anchors.fill: parent
        source: currentBg.endsWith('.mp4') ? "" : currentBg
        fillMode: Image.PreserveAspectCrop
        visible: !currentBg.endsWith('.mp4')
    }
    
    Video {
        id: videoBg
        anchors.fill: parent
        source: currentBg.endsWith('.mp4') ? currentBg : ""
        fillMode: VideoOutput.PreserveAspectCrop
        autoPlay: true
        loops: MediaPlayer.Infinite
        visible: currentBg.endsWith('.mp4')
    }
    
    function nextBackground() {
        if (bgList.length > 0) {
            currentIndex = (currentIndex + 1) % bgList.length
            currentBg = bgList[currentIndex]
        }
    }
    
    function prevBackground() {
        if (bgList.length > 0) {
            currentIndex = currentIndex > 0 ? currentIndex - 1 : bgList.length - 1
            currentBg = bgList[currentIndex]
        }
    }
}
