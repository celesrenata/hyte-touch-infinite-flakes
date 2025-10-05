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
        SystemMonitor.exec("find /var/lib/touchdisplay/backgrounds -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.mp4' -o -name '*.gif' \\) 2>/dev/null || echo ''", function(output) {
            bgList = output.trim().split('\n').filter(f => f.length > 0)
            if (bgList.length > 0) {
                currentBg = bgList[0]
                updateBackground()
            }
        })
    }
    
    function updateBackground() {
        if (currentBg.endsWith('.mp4')) {
            staticBg.visible = false
            animatedBg.visible = false
            videoBg.visible = true
            videoBg.source = currentBg
        } else if (currentBg.endsWith('.gif')) {
            staticBg.visible = false
            videoBg.visible = false
            animatedBg.visible = true
            animatedBg.source = currentBg
        } else {
            videoBg.visible = false
            animatedBg.visible = false
            staticBg.visible = true
            staticBg.source = currentBg
        }
    }
    
    Image {
        id: staticBg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    
    AnimatedImage {
        id: animatedBg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false
        playing: visible
    }
    
    Video {
        id: videoBg
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        autoPlay: true
        loops: MediaPlayer.Infinite
        visible: false
        muted: true
    }
    
    // Touch controls overlay
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        // Left side - previous background
        MouseArea {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.2
            
            onClicked: prevBackground()
            
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: parent.pressed ? 0.3 : 0
                
                Text {
                    anchors.centerIn: parent
                    text: "◀"
                    color: "white"
                    font.pixelSize: 24
                    opacity: parent.parent.pressed ? 1 : 0
                }
            }
        }
        
        // Right side - next background  
        MouseArea {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.2
            
            onClicked: nextBackground()
            
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: parent.pressed ? 0.3 : 0
                
                Text {
                    anchors.centerIn: parent
                    text: "▶"
                    color: "white"
                    font.pixelSize: 24
                    opacity: parent.parent.pressed ? 1 : 0
                }
            }
        }
        
        // Center info
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 10
            width: childrenRect.width + 20
            height: childrenRect.height + 10
            color: "black"
            opacity: 0.6
            radius: 5
            visible: bgList.length > 1
            
            Text {
                anchors.centerIn: parent
                text: (currentIndex + 1) + " / " + bgList.length
                color: "white"
                font.pixelSize: 12
            }
        }
    }
    
    function nextBackground() {
        if (bgList.length > 1) {
            currentIndex = (currentIndex + 1) % bgList.length
            currentBg = bgList[currentIndex]
            updateBackground()
        }
    }
    
    function prevBackground() {
        if (bgList.length > 1) {
            currentIndex = currentIndex > 0 ? currentIndex - 1 : bgList.length - 1
            currentBg = bgList[currentIndex]
            updateBackground()
        }
    }
}
