import QtQuick

Rectangle {
    id: usageWidget
    color: "#1e1e1e"
    radius: 8
    
    property real cpuUsage: 45.0
    property real ramUsage: 68.0
    property real gpuUsage: 32.0
    
    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            cpuUsage = 20 + Math.random() * 60
            ramUsage = 40 + Math.random() * 50
            gpuUsage = 10 + Math.random() * 70
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 15
        
        Text {
            text: "System Usage"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Column {
            spacing: 10
            
            // CPU Usage
            Row {
                spacing: 10
                Text {
                    text: "CPU"
                    color: "#888"
                    font.pixelSize: 14
                    width: 40
                }
                Rectangle {
                    width: 100
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (cpuUsage / 100)
                        height: parent.height
                        color: cpuUsage > 80 ? "#ff4444" : cpuUsage > 60 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: cpuUsage.toFixed(0) + "%"
                    color: "white"
                    font.pixelSize: 12
                }
            }
            
            // RAM Usage
            Row {
                spacing: 10
                Text {
                    text: "RAM"
                    color: "#888"
                    font.pixelSize: 14
                    width: 40
                }
                Rectangle {
                    width: 100
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (ramUsage / 100)
                        height: parent.height
                        color: ramUsage > 85 ? "#ff4444" : ramUsage > 70 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: ramUsage.toFixed(0) + "%"
                    color: "white"
                    font.pixelSize: 12
                }
            }
            
            // GPU Usage
            Row {
                spacing: 10
                Text {
                    text: "GPU"
                    color: "#888"
                    font.pixelSize: 14
                    width: 40
                }
                Rectangle {
                    width: 100
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (gpuUsage / 100)
                        height: parent.height
                        color: gpuUsage > 90 ? "#ff4444" : gpuUsage > 70 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: gpuUsage.toFixed(0) + "%"
                    color: "white"
                    font.pixelSize: 12
                }
            }
        }
    }
}
