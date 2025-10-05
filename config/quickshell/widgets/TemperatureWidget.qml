import QtQuick 2.15
import QtCharts 2.15
import ".." 1.0

Rectangle {
    id: tempWidget
    color: "#1e1e1e"
    radius: 8
    
    property var tempHistory: {
        "cpu": [],
        "gpu": [],
        "ambient": []
    }
    property int maxDataPoints: 60
    property real cpuTemp: 0
    property real gpuTemp: 0
    property real ambientTemp: 0
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTemperatures()
    }
    
    function updateTemperatures() {
        SystemMonitor.exec("sensors -A | grep -E 'Core 0|GPU|Ambient' | grep -oE '[0-9]+\\.[0-9]+°C' | head -3", function(output) {
            var lines = output.trim().split('\n')
            if (lines.length >= 2) {
                cpuTemp = parseFloat(lines[0]) || 0
                gpuTemp = parseFloat(lines[1]) || 0
                ambientTemp = lines[2] ? parseFloat(lines[2]) : 25
                
                addDataPoint("cpu", cpuTemp)
                addDataPoint("gpu", gpuTemp) 
                addDataPoint("ambient", ambientTemp)
                updateChart()
            }
        })
    }
    
    function addDataPoint(sensor, value) {
        tempHistory[sensor].push(value)
        if (tempHistory[sensor].length > maxDataPoints) {
            tempHistory[sensor].shift()
        }
    }
    
    function updateChart() {
        cpuSeries.clear()
        gpuSeries.clear()
        ambientSeries.clear()
        
        for (var i = 0; i < tempHistory.cpu.length; i++) {
            cpuSeries.append(i, tempHistory.cpu[i])
            gpuSeries.append(i, tempHistory.gpu[i] || 0)
            ambientSeries.append(i, tempHistory.ambient[i] || 25)
        }
    }
    
    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 15
        text: "System Temperatures"
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
    
    ChartView {
        id: tempChart
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: legendRow.top
        anchors.margins: 10
        
        backgroundColor: "transparent"
        legend.visible: false
        
        ValueAxis {
            id: xAxis
            min: 0
            max: maxDataPoints
            visible: false
        }
        
        ValueAxis {
            id: yAxis
            min: 20
            max: 90
            labelFormat: "%d°C"
            color: "white"
        }
        
        LineSeries {
            id: cpuSeries
            name: "CPU"
            color: "#ff6b6b"
            width: 2
            axisX: xAxis
            axisY: yAxis
        }
        
        LineSeries {
            id: gpuSeries
            name: "GPU"
            color: "#4ecdc4"
            width: 2
            axisX: xAxis
            axisY: yAxis
        }
        
        LineSeries {
            id: ambientSeries
            name: "Ambient"
            color: "#45b7d1"
            width: 2
            axisX: xAxis
            axisY: yAxis
        }
    }
    
    Row {
        id: legendRow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        spacing: 20
        
        Row {
            spacing: 5
            Rectangle { width: 12; height: 12; color: "#ff6b6b" }
            Text { text: "CPU: " + cpuTemp.toFixed(1) + "°C"; color: "white"; font.pixelSize: 12 }
        }
        Row {
            spacing: 5
            Rectangle { width: 12; height: 12; color: "#4ecdc4" }
            Text { text: "GPU: " + gpuTemp.toFixed(1) + "°C"; color: "white"; font.pixelSize: 12 }
        }
        Row {
            spacing: 5
            Rectangle { width: 12; height: 12; color: "#45b7d1" }
            Text { text: "Ambient: " + ambientTemp.toFixed(1) + "°C"; color: "white"; font.pixelSize: 12 }
        }
    }
}
