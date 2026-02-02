pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    
    property real cpuUsage: 0
    property real ramUsage: 0
    property real gpuUsage: 0
    property real gpuMemUsage: 0
    property real diskUsage: 0
    property real cpuTemp: 0
    property real gpuTemp: 0
    property real moboTemp: 0
    property real chipsetTemp: 0
    property real cpuPower: 0
    property real gpuPower: 0
    property real netUpMBps: 0
    property real netDownMBps: 0
    property var netUpHistory: []
    property var netDownHistory: []
    property real totalUpBytes: 0
    property real totalDownBytes: 0
    
    property real prevRx: 0
    property real prevTx: 0
    
    function formatBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(2) + " KB"
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(2) + " MB"
        if (bytes < 1099511627776) return (bytes / 1073741824).toFixed(2) + " GB"
        return (bytes / 1099511627776).toFixed(2) + " TB"
    }
    
    property var proc: Process {
        running: true
        command: ["/run/current-system/sw/bin/sh", "-c", "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/celes/bin:$PATH; echo $(top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}');echo $(free | grep Mem | awk '{print ($3/$2) * 100}');echo $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits);echo $(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F', ' '{print ($1/$2)*100}');echo $(df / | tail -1 | awk '{print $5}' | tr -d '%');echo $(sensors | grep 'Tctl:' | awk '{print $2}' | tr -d '+°C');echo $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits);echo $(sensors | grep 'Motherboard:' | awk '{print $2}' | tr -d '+°C');echo $(sensors | grep 'Chipset:' | awk '{print $2}' | tr -d '+°C');echo $(echo \"scale=2; $(cat /sys/class/hwmon/hwmon3/in0_input) * $(cat /sys/class/hwmon/hwmon3/curr1_input) / 1000000\" | bc);echo $(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits);cat /proc/net/dev | grep -E 'enp5s0f0|enp5s0f1|br0' | awk '{rx+=$2; tx+=$10} END {print rx,tx}'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n')
                root.cpuUsage = parseFloat(lines[0]) || 0
                root.ramUsage = parseFloat(lines[1]) || 0
                root.gpuUsage = parseFloat(lines[2]) || 0
                root.gpuMemUsage = parseFloat(lines[3]) || 0
                root.diskUsage = parseFloat(lines[4]) || 0
                root.cpuTemp = parseFloat(lines[5]) || 0
                root.gpuTemp = parseFloat(lines[6]) || 0
                root.moboTemp = parseFloat(lines[7]) || 0
                root.chipsetTemp = parseFloat(lines[8]) || 0
                root.cpuPower = parseFloat(lines[9]) || 0
                root.gpuPower = parseFloat(lines[10]) || 0
                
                // Network stats
                var netStats = lines[11] ? lines[11].split(' ') : [0, 0]
                var rx = parseFloat(netStats[0]) || 0
                var tx = parseFloat(netStats[1]) || 0
                
                if (root.prevRx > 0) {
                    var rxDelta = rx - root.prevRx
                    var txDelta = tx - root.prevTx
                    
                    root.netDownMBps = (rxDelta / 1048576) / 2
                    root.netUpMBps = (txDelta / 1048576) / 2
                    
                    root.totalDownBytes += rxDelta
                    root.totalUpBytes += txDelta
                    
                    var newDown = root.netDownHistory.slice()
                    newDown.push(root.netDownMBps)
                    if (newDown.length > 30) newDown.shift()
                    root.netDownHistory = newDown
                    
                    var newUp = root.netUpHistory.slice()
                    newUp.push(root.netUpMBps)
                    if (newUp.length > 30) newUp.shift()
                    root.netUpHistory = newUp
                }
                
                root.prevRx = rx
                root.prevTx = tx
                
                updateTimer.start()
            }
        }
    }
    
    property var updateTimer: Timer {
        interval: 2000
        onTriggered: proc.running = true
    }
}
