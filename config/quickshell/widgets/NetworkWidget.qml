import QtQuick
import "../"

Rectangle {
    id: networkWidget
    color: "#1e1e1e"
    radius: 8
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        Text {
            text: "Network Usage"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            width: parent.width
            height: parent.height - 40
            spacing: 20
        
        // Line graph
        Rectangle {
            width: parent.width * 0.75
            height: parent.height
            color: "#2a2a2a"
            radius: 8
            
            Canvas {
                id: canvas
                anchors.fill: parent
                anchors.margins: 20
                
                Timer {
                    interval: 2000
                    running: true
                    repeat: true
                    onTriggered: canvas.requestPaint()
                }
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    if (SystemMonitor.netDownHistory.length < 2) return
                    
                    var maxRate = Math.max(
                        Math.max(...SystemMonitor.netDownHistory),
                        Math.max(...SystemMonitor.netUpHistory),
                        10
                    )
                    var xStep = width / Math.max(SystemMonitor.netDownHistory.length - 1, 1)
                    
                    // Grid lines with labels
                    ctx.strokeStyle = "#444"
                    ctx.lineWidth = 1
                    ctx.fillStyle = "#888"
                    ctx.font = "10px sans-serif"
                    for (var i = 0; i <= 4; i++) {
                        var y = (i / 4) * height
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                        
                        var value = maxRate * (1 - i / 4)
                        ctx.fillText(value.toFixed(1) + " MB/s", 5, y - 2)
                    }
                    
                    // Download line
                    ctx.strokeStyle = "#00ff88"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    for (var i = 0; i < SystemMonitor.netDownHistory.length; i++) {
                        var x = i * xStep
                        var y = height - (SystemMonitor.netDownHistory[i] / maxRate) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                    
                    // Upload line
                    ctx.strokeStyle = "#ffaa00"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    for (var i = 0; i < SystemMonitor.netUpHistory.length; i++) {
                        var x = i * xStep
                        var y = height - (SystemMonitor.netUpHistory[i] / maxRate) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                }
            }
            
        }
        
        // Stats display
        Column {
            width: parent.width * 0.3
            height: parent.height
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            
            Column {
                spacing: 5
                width: parent.width
                
                Text {
                    text: "Download:"
                    color: "#888"
                    font.pixelSize: 12
                }
                Text {
                    text: SystemMonitor.netDownMBps.toFixed(2) + " MB/s"
                    color: "#00ff88"
                    font.pixelSize: 20
                    font.bold: true
                }
                Text {
                    text: SystemMonitor.formatBytes(SystemMonitor.totalDownBytes)
                    color: "#00ff88"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            Column {
                spacing: 5
                width: parent.width
                
                Text {
                    text: "Upload:"
                    color: "#888"
                    font.pixelSize: 12
                }
                Text {
                    text: SystemMonitor.netUpMBps.toFixed(2) + " MB/s"
                    color: "#ffaa00"
                    font.pixelSize: 20
                    font.bold: true
                }
                Text {
                    text: SystemMonitor.formatBytes(SystemMonitor.totalUpBytes)
                    color: "#ffaa00"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
        }
    }
}
}
