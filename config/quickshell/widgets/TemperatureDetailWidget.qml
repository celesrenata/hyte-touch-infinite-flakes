import QtQuick 2.15
import QtCharts 2.15
import ".." 1.0

Rectangle {
    color: "#1a1a1a"
    
    ChartView {
        anchors.fill: parent
        anchors.margins: 20
        
        backgroundColor: "transparent"
        legend.visible: true
        legend.color: "white"
        
        ValueAxis {
            id: xAxis
            min: 0
            max: 60
            titleText: "Time (seconds)"
            color: "white"
            labelsColor: "white"
        }
        
        ValueAxis {
            id: yAxis
            min: 20
            max: 90
            titleText: "Temperature (°C)"
            color: "white"
            labelsColor: "white"
        }
        
        LineSeries {
            name: "CPU"
            axisX: xAxis
            axisY: yAxis
            color: "#ff6b6b"
            width: 2
        }
        
        LineSeries {
            name: "GPU"
            axisX: xAxis
            axisY: yAxis
            color: "#4ecdc4"
            width: 2
        }
        
        LineSeries {
            name: "Ambient"
            axisX: xAxis
            axisY: yAxis
            color: "#feca57"
            width: 2
        }
    }
}
