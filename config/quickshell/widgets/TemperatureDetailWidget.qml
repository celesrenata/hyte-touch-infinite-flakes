import QtQuick
import "../"

Rectangle {
    id: tempDetailWidget
    color: "#1e1e1e"
    radius: 8
    
    property var tempHistory: []
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Add to history (keep last 60 points = 2 minutes)
            var newHistory = tempHistory.slice()
            newHistory.push({cpu: SystemMonitor.cpuTemp, gpu: SystemMonitor.gpuTemp})
            if (newHistory.length > 60) {
                newHistory.shift()
            }
            tempHistory = newHistory
            canvas.requestPaint()
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: "Temperature History"
            color: "#00ff88"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Temperature graph
        Rectangle {
            width: parent.width
            height: parent.height - 80
            color: "#2a2a2a"
            radius: 8
            
            Canvas {
                id: canvas
                anchors.fill: parent
                anchors.margins: 20
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    if (tempHistory.length < 2) return
                    
                    // Find actual min/max temps for better scaling
                    var maxTemp = 0
                    var minTemp = 100
                    for (var i = 0; i < tempHistory.length; i++) {
                        maxTemp = Math.max(maxTemp, tempHistory[i].cpu, tempHistory[i].gpu)
                        minTemp = Math.min(minTemp, tempHistory[i].cpu, tempHistory[i].gpu)
                    }
                    // Add padding
                    maxTemp += 5
                    minTemp = Math.max(0, minTemp - 5)
                    
                    var xStep = width / Math.max(tempHistory.length - 1, 1)
                    
                    // Draw CPU line
                    ctx.strokeStyle = "#00ff88"
                    ctx.lineWidth = 3
                    ctx.beginPath()
                    for (var i = 0; i < tempHistory.length; i++) {
                        var x = i * xStep
                        var y = height - ((tempHistory[i].cpu - minTemp) / (maxTemp - minTemp)) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                    
                    // Draw GPU line
                    ctx.strokeStyle = "#4ecdc4"
                    ctx.lineWidth = 3
                    ctx.beginPath()
                    for (var i = 0; i < tempHistory.length; i++) {
                        var x = i * xStep
                        var y = height - ((tempHistory[i].gpu - minTemp) / (maxTemp - minTemp)) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                }
            }
            
            // Legend
            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 15
                spacing: 15
                
                Row {
                    spacing: 5
                    Rectangle { width: 20; height: 3; color: "#00ff88" }
                    Text { text: "CPU"; color: "white"; font.pixelSize: 12 }
                }
                Row {
                    spacing: 5
                    Rectangle { width: 20; height: 3; color: "#4ecdc4" }
                    Text { text: "GPU"; color: "white"; font.pixelSize: 12 }
                }
            }
            
            // Current values
            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 15
                spacing: 30
                
                Text {
                    text: "CPU: " + SystemMonitor.cpuTemp.toFixed(1) + "°C"
                    color: "#00ff88"
                    font.pixelSize: 14
                }
                Text {
                    text: "GPU: " + SystemMonitor.gpuTemp.toFixed(1) + "°C"
                    color: "#4ecdc4"
                    font.pixelSize: 14
                }
            }
        }
    }
}
