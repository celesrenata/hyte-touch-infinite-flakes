import QtQuick
import "../"

Rectangle {
    id: tempWidget
    color: "#1e1e1e"
    radius: 8
    
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
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
                    text: SystemMonitor.cpuTemp > 0 ? SystemMonitor.cpuTemp.toFixed(1) + "°C" : "--"
                    color: SystemMonitor.cpuTemp > 80 ? "#ff4444" : SystemMonitor.cpuTemp > 60 ? "#ffaa00" : "#00ff88"
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
                    text: SystemMonitor.gpuTemp > 0 ? SystemMonitor.gpuTemp.toFixed(1) + "°C" : "--"
                    color: SystemMonitor.gpuTemp > 85 ? "#ff4444" : SystemMonitor.gpuTemp > 70 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 5
                Text {
                    text: "Mobo"
                    color: "#888"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: SystemMonitor.moboTemp > 0 ? SystemMonitor.moboTemp.toFixed(1) + "°C" : "--"
                    color: SystemMonitor.moboTemp > 60 ? "#ff4444" : SystemMonitor.moboTemp > 50 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 5
                Text {
                    text: "Chipset"
                    color: "#888"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: SystemMonitor.chipsetTemp > 0 ? SystemMonitor.chipsetTemp.toFixed(1) + "°C" : "--"
                    color: SystemMonitor.chipsetTemp > 80 ? "#ff4444" : SystemMonitor.chipsetTemp > 70 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Temperature bar graph
        Rectangle {
            width: parent.width - 40
            height: 150
            color: "#2a2a2a"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            
            property real minTemp: 20
            property real maxTemp: 100
            
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 0
                
                // Y-axis (Fahrenheit)
                Item {
                    width: 35
                    height: parent.height
                    
                    Repeater {
                        model: [
                            {temp: 100, f: 212},
                            {temp: 80, f: 176},
                            {temp: 60, f: 140},
                            {temp: 40, f: 104},
                            {temp: 20, f: 68}
                        ]
                        Text {
                            text: modelData.f + "°F"
                            color: "#666"
                            font.pixelSize: 9
                            y: ((100 - modelData.temp) / 80) * (parent.height - 20)
                        }
                    }
                }
                
                // Graph area
                Item {
                    height: parent.height
                    width: parent.width - 70
                    
                    // Horizontal grid lines
                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: 20
                        spacing: (parent.height - 20) / 4
                        z: 0
                        
                        Repeater {
                            model: 5
                            Rectangle {
                                width: parent.parent.width
                                height: 1
                                color: "#444"
                            }
                        }
                    }
                    
                    // Bars
                    Row {
                        anchors.fill: parent
                        anchors.bottomMargin: 20
                        spacing: 10
                        z: 1
                        
                        Repeater {
                            model: [
                                {temp: SystemMonitor.cpuTemp, label: "CPU"},
                                {temp: SystemMonitor.gpuTemp, label: "GPU"},
                                {temp: SystemMonitor.moboTemp, label: "Mobo"},
                                {temp: SystemMonitor.chipsetTemp, label: "Chip"}
                            ]
                            
                            Item {
                                width: (parent.width - 30) / 4
                                height: parent.height
                                
                                Rectangle {
                                    width: parent.width
                                    height: Math.max(((modelData.temp - 20) / 80) * parent.height, 0)
                                    anchors.bottom: parent.bottom
                                    radius: 4
                                    
                                    property real tempRatio: Math.min(Math.max((modelData.temp - 40) / 60, 0), 1)
                                    color: Qt.rgba(
                                        0.0 + tempRatio,
                                        1.0 - tempRatio,
                                        0.0,
                                        1.0
                                    )
                                }
                            }
                        }
                    }
                    
                    // Labels
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 10
                        
                        Repeater {
                            model: ["CPU", "GPU", "Mobo", "Chip"]
                            Text {
                                width: (parent.width - 30) / 4
                                text: modelData
                                color: "#888"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                
                // Y-axis (Celsius)
                Item {
                    width: 35
                    height: parent.height
                    
                    Repeater {
                        model: [100, 80, 60, 40, 20]
                        Text {
                            text: modelData + "°C"
                            color: "#666"
                            font.pixelSize: 9
                            y: ((100 - modelData) / 80) * (parent.height - 20)
                        }
                    }
                }
            }
        }
    }
}
