import QtQuick 2.15
import QtQuick.Controls 2.15
import ".." 1.0

Rectangle {
    id: usageWidget
    color: "#2d2d2d"
    radius: 8
    
    property real cpuUsage: 0
    property real ramUsage: 0
    property real gpuUsage: 0
    property var diskUsage: []
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateUsage()
    }
    
    function updateUsage() {
        // CPU usage
        SystemMonitor.exec("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1", function(output) {
            cpuUsage = parseFloat(output) || 0
        })
        
        // RAM usage
        SystemMonitor.exec("free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'", function(output) {
            ramUsage = parseFloat(output) || 0
        })
        
        // GPU usage (NVIDIA)
        SystemMonitor.exec("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo '0'", function(output) {
            gpuUsage = parseFloat(output) || 0
        })
        
        // Disk usage for mounted partitions
        SystemMonitor.exec("df -h | grep -E '^/dev/' | awk '{print $5 \" \" $6}' | sed 's/%//'", function(output) {
            diskUsage = []
            var lines = output.trim().split('\n')
            for (var i = 0; i < lines.length && i < 3; i++) {
                if (lines[i]) {
                    var parts = lines[i].split(' ')
                    diskUsage.push({
                        usage: parseFloat(parts[0]) || 0,
                        mount: parts[1] || "/"
                    })
                }
            }
            diskRepeater.model = diskUsage
        })
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 15
        
        Column {
            width: parent.width
            spacing: 15
            
            Text {
                text: "System Usage"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
            
            // CPU Usage Bar
            UsageBar {
                width: parent.width
                label: "CPU"
                value: cpuUsage
                color: "#ff9f43"
            }
            
            // RAM Usage Bar  
            UsageBar {
                width: parent.width
                label: "RAM"
                value: ramUsage
                color: "#10ac84"
            }
            
            // GPU Usage Bar
            UsageBar {
                width: parent.width
                label: "GPU"
                value: gpuUsage
                color: "#5f27cd"
            }
            
            // Disk Usage Bars
            Text {
                text: "Storage"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                topPadding: 10
            }
            
            Repeater {
                id: diskRepeater
                model: diskUsage
                
                UsageBar {
                    width: parent.width
                    label: modelData.mount
                    value: modelData.usage
                    color: "#e17055"
                }
            }
        }
    }
}
