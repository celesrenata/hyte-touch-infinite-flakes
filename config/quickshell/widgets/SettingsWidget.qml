import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: "#1a1a1a"
    
    property real brightness: 1.0
    property int dimTimeout: 30
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: "Display Settings"
            color: "white"
            font.pixelSize: 18
            font.bold: true
        }
        
        // Brightness Control
        Rectangle {
            width: parent.width
            height: 80
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Brightness: " + Math.round(brightness * 100) + "%"
                    color: "white"
                }
                
                Slider {
                    width: parent.width - 20
                    from: 0.1
                    to: 1.0
                    value: brightness
                    onValueChanged: {
                        brightness = value
                        setBrightness(value)
                    }
                }
            }
        }
        
        // Auto-dim Settings
        Rectangle {
            width: parent.width
            height: 80
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Auto-dim timeout: " + dimTimeout + "s"
                    color: "white"
                }
                
                Slider {
                    width: parent.width - 20
                    from: 10
                    to: 300
                    stepSize: 10
                    value: dimTimeout
                    onValueChanged: dimTimeout = value
                }
            }
        }
    }
    
    function setBrightness(value) {
        Process {
            program: "sh"
            arguments: ["-c", "echo " + Math.round(value * 255) + " > /sys/class/backlight/*/brightness"]
        }
    }
}
