import QtQuick

Rectangle {
    id: tempWidget
    color: "#1e1e1e"
    radius: 8
    
    property real cpuTemp: 65.0
    property real gpuTemp: 72.0
    property real ambientTemp: 28.0
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Simulate temperature changes for now
            cpuTemp = 60 + Math.random() * 20
            gpuTemp = 65 + Math.random() * 25
            ambientTemp = 25 + Math.random() * 10
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 15
        
        Text {
            text: "System Temperatures"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            Column {
                spacing: 5
                Text {
                    text: "CPU"
                    color: "#888"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: cpuTemp.toFixed(1) + "°C"
                    color: cpuTemp > 80 ? "#ff4444" : cpuTemp > 60 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 5
                Text {
                    text: "GPU"
                    color: "#888"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: gpuTemp.toFixed(1) + "°C"
                    color: gpuTemp > 85 ? "#ff4444" : gpuTemp > 70 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 5
                Text {
                    text: "Ambient"
                    color: "#888"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: ambientTemp.toFixed(1) + "°C"
                    color: "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
