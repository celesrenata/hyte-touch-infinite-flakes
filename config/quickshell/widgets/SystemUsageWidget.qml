import QtQuick
import "../"

Rectangle {
    id: usageWidget
    color: "#1e1e1e"
    radius: 8
    
    property var cpuHistory: []
    property var ramHistory: []
    property var gpuHistory: []
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var newCpu = cpuHistory.slice()
            newCpu.push(SystemMonitor.cpuUsage)
            if (newCpu.length > 30) newCpu.shift()
            cpuHistory = newCpu
            
            var newRam = ramHistory.slice()
            newRam.push(SystemMonitor.ramUsage)
            if (newRam.length > 30) newRam.shift()
            ramHistory = newRam
            
            var newGpu = gpuHistory.slice()
            newGpu.push(SystemMonitor.gpuUsage)
            if (newGpu.length > 30) newGpu.shift()
            gpuHistory = newGpu
            
            cpuCanvas.requestPaint()
            ramCanvas.requestPaint()
            gpuCanvas.requestPaint()
        }
    }
    
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
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
                    width: 210
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (SystemMonitor.cpuUsage / 100)
                        height: parent.height
                        color: SystemMonitor.cpuUsage > 80 ? "#ff4444" : SystemMonitor.cpuUsage > 60 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: SystemMonitor.cpuUsage.toFixed(0) + "%"
                    color: SystemMonitor.cpuUsage > 90 ? "#ff4444" : "white"
                    font.bold: SystemMonitor.cpuUsage > 90
                    font.pixelSize: 16
                }
                }
            }
            Canvas {
                id: cpuCanvas
                width: 260
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (cpuHistory.length < 2) return
                    
                    var xStep = width / (cpuHistory.length - 1)
                    
                    ctx.strokeStyle = "#00ff88"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    for (var i = 0; i < cpuHistory.length; i++) {
                        var x = i * xStep
                        var y = height - (cpuHistory[i] / 100) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
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
                    width: 210
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (SystemMonitor.ramUsage / 100)
                        height: parent.height
                        color: SystemMonitor.ramUsage > 85 ? "#ff4444" : SystemMonitor.ramUsage > 70 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: SystemMonitor.ramUsage.toFixed(0) + "%"
                    color: SystemMonitor.ramUsage > 90 ? "#ff4444" : "white"
                    font.bold: SystemMonitor.ramUsage > 90
                    font.pixelSize: 16
                }
            }
            Canvas {
                id: ramCanvas
                width: 260
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (ramHistory.length < 2) return
                    
                    var xStep = width / (ramHistory.length - 1)
                    
                    ctx.strokeStyle = "#4ecdc4"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    for (var i = 0; i < ramHistory.length; i++) {
                        var x = i * xStep
                        var y = height - (ramHistory[i] / 100) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
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
                    width: 210
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (SystemMonitor.gpuUsage / 100)
                        height: parent.height
                        color: SystemMonitor.gpuUsage > 90 ? "#ff4444" : SystemMonitor.gpuUsage > 70 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: SystemMonitor.gpuUsage.toFixed(0) + "%"
                    color: SystemMonitor.gpuUsage > 90 ? "#ff4444" : "white"
                    font.bold: SystemMonitor.gpuUsage > 90
                    font.pixelSize: 16
                }
            }
            
            // GPU Memory
            Row {
                spacing: 10
                Text {
                    text: "VRAM"
                    color: "#888"
                    font.pixelSize: 14
                    width: 40
                }
                Rectangle {
                    width: 210
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (SystemMonitor.gpuMemUsage / 100)
                        height: parent.height
                        color: SystemMonitor.gpuMemUsage > 90 ? "#ff4444" : SystemMonitor.gpuMemUsage > 70 ? "#ffaa00" : "#4ecdc4"
                        radius: 4
                    }
                }
                Text {
                    text: SystemMonitor.gpuMemUsage.toFixed(0) + "%"
                    color: SystemMonitor.gpuMemUsage > 90 ? "#ff4444" : "white"
                    font.bold: SystemMonitor.gpuMemUsage > 90
                    font.pixelSize: 16
                }
            }
            Canvas {
                id: gpuCanvas
                width: 260
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (gpuHistory.length < 2) return
                    
                    var xStep = width / (gpuHistory.length - 1)
                    
                    ctx.strokeStyle = "#ff88ff"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    for (var i = 0; i < gpuHistory.length; i++) {
                        var x = i * xStep
                        var y = height - (gpuHistory[i] / 100) * height
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                }
            }
            
            // Disk Usage
            Row {
                spacing: 10
                Text {
                    text: "Disk"
                    color: "#888"
                    font.pixelSize: 14
                    width: 40
                }
                Rectangle {
                    width: 210
                    height: 8
                    color: "#333"
                    radius: 4
                    Rectangle {
                        width: parent.width * (SystemMonitor.diskUsage / 100)
                        height: parent.height
                        color: SystemMonitor.diskUsage > 90 ? "#ff4444" : SystemMonitor.diskUsage > 80 ? "#ffaa00" : "#00ff88"
                        radius: 4
                    }
                }
                Text {
                    text: SystemMonitor.diskUsage.toFixed(0) + "%"
                    color: SystemMonitor.diskUsage > 90 ? "#ff4444" : "white"
                    font.bold: SystemMonitor.diskUsage > 90
                    font.pixelSize: 16
                }
            }
            Text {
                text: "R: " + SystemMonitor.diskReadMB.toFixed(1) + " MB/s  W: " + SystemMonitor.diskWriteMB.toFixed(1) + " MB/s"
                color: "#888"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
