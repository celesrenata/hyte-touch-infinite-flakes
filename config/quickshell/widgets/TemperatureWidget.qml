import QtQuick 2.15
import QtCharts 2.15

Rectangle {
    id: tempWidget
    color: "#1e1e1e"
    radius: 8
    
    property var temperatures: ({})
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTemperatures()
    }
    
    function updateTemperatures() {
        // Read from sensors via system monitor
        Process {
            program: "sensors"
            arguments: ["-j"]
            onFinished: {
                try {
                    temperatures = JSON.parse(stdout)
                    tempChart.updateData()
                } catch(e) {
                    console.log("Failed to parse sensor data")
                }
            }
        }
    }
    
    ChartView {
        id: tempChart
        anchors.fill: parent
        anchors.margins: 10
        
        backgroundColor: "transparent"
        legend.visible: true
        legend.alignment: Qt.AlignBottom
        
        LineSeries {
            id: cpuSeries
            name: "CPU"
            color: "#ff6b6b"
        }
        
        LineSeries {
            id: gpuSeries
            name: "GPU" 
            color: "#4ecdc4"
        }
        
        LineSeries {
            id: ramSeries
            name: "RAM"
            color: "#45b7d1"
        }
        
        function updateData() {
            // Update chart with new temperature data
            // Implementation depends on sensor output format
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
}
