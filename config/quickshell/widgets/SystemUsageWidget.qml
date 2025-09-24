import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: usageWidget
    color: "#2d2d2d"
    radius: 8
    
    property real cpuUsage: 0
    property real ramUsage: 0
    property real gpuUsage: 0
    property var diskUsage: ({})
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateUsage()
    }
    
    function updateUsage() {
        // CPU usage
        Process {
            program: "sh"
            arguments: ["-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
            onFinished: cpuUsage = parseFloat(stdout)
        }
        
        // RAM usage
        Process {
            program: "sh" 
            arguments: ["-c", "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"]
            onFinished: ramUsage = parseFloat(stdout)
        }
        
        // GPU usage (NVIDIA)
        Process {
            program: "nvidia-smi"
            arguments: ["--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
            onFinished: gpuUsage = parseFloat(stdout)
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        Text {
            text: "System Usage"
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
        
        // CPU Usage Bar
        UsageBar {
            label: "CPU"
            value: cpuUsage
            color: "#ff9f43"
        }
        
        // RAM Usage Bar  
        UsageBar {
            label: "RAM"
            value: ramUsage
            color: "#10ac84"
        }
        
        // GPU Usage Bar
        UsageBar {
            label: "GPU"
            value: gpuUsage
            color: "#5f27cd"
        }
    }
}
