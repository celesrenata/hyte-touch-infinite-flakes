import QtQuick
import "../"

Rectangle {
    color: "#1e1e1e"
    radius: 8
    
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 8
        
        Text {
            text: "Power Consumption"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            
            Column {
                spacing: 2
                Text {
                    text: "CPU"
                    color: "#888"
                    font.pixelSize: 10
                }
                Text {
                    text: SystemMonitor.cpuPower.toFixed(1) + "W"
                    color: "white"
                    font.pixelSize: 16
                }
            }
            
            Column {
                spacing: 2
                Text {
                    text: "GPU"
                    color: "#888"
                    font.pixelSize: 10
                }
                Text {
                    text: SystemMonitor.gpuPower.toFixed(1) + "W"
                    color: "white"
                    font.pixelSize: 16
                }
            }
            
            Column {
                spacing: 2
                Text {
                    text: "Total"
                    color: "#888"
                    font.pixelSize: 10
                }
                Text {
                    text: (SystemMonitor.cpuPower + SystemMonitor.gpuPower).toFixed(1) + "W"
                    color: "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
    }
}
