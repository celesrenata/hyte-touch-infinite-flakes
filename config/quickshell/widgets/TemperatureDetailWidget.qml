import QtQuick

Rectangle {
    id: tempDetailWidget
    color: "#1e1e1e"
    radius: 8
    
    property real cpuTemp: 65.0
    property real gpuTemp: 72.0
    property real ambientTemp: 28.0
    property var tempHistory: []
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            cpuTemp = 60 + Math.random() * 20
            gpuTemp = 65 + Math.random() * 25
            ambientTemp = 25 + Math.random() * 10
            
            // Add to history (keep last 30 points)
            tempHistory.push({cpu: cpuTemp, gpu: gpuTemp, ambient: ambientTemp})
            if (tempHistory.length > 30) {
                tempHistory.shift()
            }
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: "Detailed Temperature Monitoring"
            color: "#00ff88"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Temperature histogram
        Rectangle {
            width: parent.width - 40
            height: 200
            color: "#2a2a2a"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                text: "Temperature History"
                color: "#00ff88"
                font.pixelSize: 16
                font.bold: true
            }
            
            Row {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                height: 120
                spacing: 2
                
                Repeater {
                    model: Math.min(tempHistory.length, 30)
                    
                    Rectangle {
                        width: (parent.width - (29 * 2)) / 30
                        height: tempHistory[index] ? (tempHistory[index].cpu / 100) * parent.height : 0
                        color: {
                            if (!tempHistory[index]) return "#333"
                            var temp = tempHistory[index].cpu
                            return temp > 80 ? "#ff4444" : temp > 60 ? "#ffaa00" : "#00ff88"
                        }
                        anchors.bottom: parent.bottom
                        
                        Rectangle {
                            width: parent.width
                            height: tempHistory[index] ? (tempHistory[index].gpu / 100) * parent.parent.height : 0
                            color: {
                                if (!tempHistory[index]) return "#333"
                                var temp = tempHistory[index].gpu
                                return temp > 85 ? "#ff4444" : temp > 70 ? "#ffaa00" : "#4ecdc4"
                            }
                            anchors.bottom: parent.bottom
                            opacity: 0.7
                        }
                    }
                }
            }
            
            // Legend
            Row {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 15
                
                Row {
                    spacing: 5
                    Rectangle { width: 12; height: 12; color: "#00ff88" }
                    Text { text: "CPU"; color: "white"; font.pixelSize: 10 }
                }
                Row {
                    spacing: 5
                    Rectangle { width: 12; height: 12; color: "#4ecdc4"; opacity: 0.7 }
                    Text { text: "GPU"; color: "white"; font.pixelSize: 10 }
                }
            }
        }
        
        Text {
            text: "History: " + tempHistory.length + " data points"
            color: "#666"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
