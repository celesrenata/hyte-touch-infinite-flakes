import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    color: "#1a1a1a"
    
    property int nodesReady: 0
    property real clusterMemory: 0
    property real clusterCPU: 0
    property real clusterStorage: 0
    property real gpuUtil: 0
    property real gpuMemory: 0
    property real gpuPower: 0
    property int runningPods: 0
    property int pendingPods: 0
    property int failedPods: 0
    property real totalPower: 0
    Component.onCompleted: {
        console.log("GrafanaWidget loaded")
        console.log("GRAFANA_API_TOKEN env:", Quickshell.env("GRAFANA_API_TOKEN") ? "SET" : "NOT SET")
    }
    
    Process {
        id: prometheusQuery
        running: true
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(kube_node_status_condition{node=~\"gremlin-.*\",condition=\"Ready\",status=\"true\"})' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        onRunningChanged: console.log("Process running:", running)
        onExited: (exitCode, exitStatus) => console.log("Process exited:", exitCode, exitStatus)
        
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Stream finished, length:", text ? text.length : "null")
                if (!text || text.length === 0) {
                    console.log("Empty response!")
                    return
                }
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        nodesReady = parseInt(data.data.result[0].value[1])
                        console.log("Nodes ready:", nodesReady)
                    } else {
                        console.log("No result in data:", JSON.stringify(data).substring(0, 100))
                    }
                } catch (e) {
                    console.log("Parse error:", e, "Text:", text.substring(0, 100))
                }
                memoryQuery.running = true
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.length > 0) {
                    console.log("Stderr:", text)
                }
            }
        }
    }
    
    Process {
        id: memoryQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=(1 - sum(node_memory_MemAvailable_bytes{instance=~\"10.1.1.(12|13|14|15):9100\"}) / sum(node_memory_MemTotal_bytes{instance=~\"10.1.1.(12|13|14|15):9100\"})) * 100' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        clusterMemory = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                cpuQuery.running = true
            }
        }
    }
    
    Process {
        id: cpuQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=(1 - sum(rate(node_cpu_seconds_total{instance=~\"10.1.1.(12|13|14|15):9100\",mode=\"idle\"}[5m])) / sum(rate(node_cpu_seconds_total{instance=~\"10.1.1.(12|13|14|15):9100\"}[5m]))) * 100' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        clusterCPU = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                storageQuery.running = true
            }
        }
    }
    
    Process {
        id: storageQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=(1 - sum(node_filesystem_avail_bytes{instance=~\"10.1.1.(12|13|14|15):9100\",mountpoint=\"/\"}) / sum(node_filesystem_size_bytes{instance=~\"10.1.1.(12|13|14|15):9100\",mountpoint=\"/\"})) * 100' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        clusterStorage = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                gpuQuery.running = true
            }
        }
    }
    
    Process {
        id: gpuQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=avg(DCGM_FI_DEV_GPU_UTIL)' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        gpuUtil = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                gpuMemQuery.running = true
            }
        }
    }
    
    Process {
        id: gpuMemQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=avg(DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) * 100)' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        gpuMemory = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                gpuPowerQuery.running = true
            }
        }
    }
    
    Process {
        id: gpuPowerQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(DCGM_FI_DEV_POWER_USAGE)' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        gpuPower = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
                podsQuery.running = true
            }
        }
    }
    
    Process {
        id: podsQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(kube_pod_status_phase{phase=\"Running\"} == 1 and on(pod,namespace) kube_pod_info{node=~\"gremlin-.*\"})' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        runningPods = parseInt(data.data.result[0].value[1])
                    }
                } catch (e) {}
                pendingQuery.running = true
            }
        }
    }
    
    Process {
        id: pendingQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(kube_pod_status_phase{phase=\"Pending\"} == 1 and on(pod,namespace) kube_pod_info{node=~\"gremlin-.*\"})' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        pendingPods = parseInt(data.data.result[0].value[1])
                    }
                } catch (e) {}
                failedQuery.running = true
            }
        }
    }
    
    Process {
        id: failedQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(kube_pod_status_phase{phase=\"Failed\"} == 1 and on(pod,namespace) kube_pod_info{node=~\"gremlin-.*\"})' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        failedPods = parseInt(data.data.result[0].value[1])
                    }
                } catch (e) {}
                powerQuery.running = true
            }
        }
    }
    
    Process {
        id: powerQuery
        running: false
        command: ["/run/current-system/sw/bin/sh", "-c",
            "curl -s -H 'Authorization: Bearer " + (Quickshell.env("GRAFANA_API_TOKEN") || "") + "' " +
            "-G --data-urlencode 'query=sum(kasa_power_load)' " +
            "'https://grafana.celestium.life/api/datasources/proxy/uid/edz81hfw02t4wb/api/v1/query'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.data && data.data.result && data.data.result[0]) {
                        totalPower = parseFloat(data.data.result[0].value[1])
                    }
                } catch (e) {}
            }
        }
    }
    
    Timer {
        running: true
        repeat: true
        interval: 30000
        onTriggered: prometheusQuery.running = true
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        Text {
            text: "Kubernetes Cluster"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Cluster Resources
        Column {
            width: parent.width
            spacing: 15
            
            // Nodes Ready
            Row {
                spacing: 10
                Text {
                    text: "Nodes Ready:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Text {
                    text: nodesReady.toString()
                    color: nodesReady < 4 ? "#ff4444" : "#00ff88"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            // CPU
            Row {
                spacing: 10
                Text {
                    text: "CPU:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Rectangle {
                    width: 450
                    height: 18
                    color: "#333"
                    radius: 9
                    Rectangle {
                        width: parent.width * (clusterCPU / 100)
                        height: parent.height
                        color: clusterCPU > 90 ? "#ff4444" : clusterCPU > 70 ? "#ffaa00" : "#00ff88"
                        radius: 9
                    }
                }
                Text {
                    text: clusterCPU.toFixed(1) + "%"
                    color: clusterCPU > 90 ? "#ff4444" : "white"
                    font.pixelSize: 16
                    font.bold: clusterCPU > 90
                    width: 60
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // RAM
            Row {
                spacing: 10
                Text {
                    text: "RAM:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Rectangle {
                    width: 450
                    height: 18
                    color: "#333"
                    radius: 9
                    Rectangle {
                        width: parent.width * (clusterMemory / 100)
                        height: parent.height
                        color: clusterMemory > 90 ? "#ff4444" : clusterMemory > 70 ? "#ffaa00" : "#00ff88"
                        radius: 9
                    }
                }
                Text {
                    text: clusterMemory.toFixed(1) + "%"
                    color: clusterMemory > 90 ? "#ff4444" : "white"
                    font.pixelSize: 16
                    font.bold: clusterMemory > 90
                    width: 60
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // Storage
            Row {
                spacing: 10
                Text {
                    text: "Storage:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Rectangle {
                    width: 450
                    height: 18
                    color: "#333"
                    radius: 9
                    Rectangle {
                        width: parent.width * (clusterStorage / 100)
                        height: parent.height
                        color: clusterStorage > 90 ? "#ff4444" : clusterStorage > 70 ? "#ffaa00" : "#00ff88"
                        radius: 9
                    }
                }
                Text {
                    text: clusterStorage.toFixed(1) + "%"
                    color: clusterStorage > 90 ? "#ff4444" : "white"
                    font.pixelSize: 16
                    font.bold: clusterStorage > 90
                    width: 60
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // GPU Utilization
            Row {
                spacing: 10
                Text {
                    text: "GPU:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Rectangle {
                    width: 450
                    height: 18
                    color: "#333"
                    radius: 9
                    Rectangle {
                        width: parent.width * (gpuUtil / 100)
                        height: parent.height
                        color: gpuUtil > 90 ? "#ff4444" : gpuUtil > 70 ? "#ffaa00" : "#00ff88"
                        radius: 9
                    }
                }
                Text {
                    text: gpuUtil.toFixed(1) + "%"
                    color: gpuUtil > 90 ? "#ff4444" : "white"
                    font.pixelSize: 16
                    font.bold: gpuUtil > 90
                    width: 60
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // GPU Memory
            Row {
                spacing: 10
                Text {
                    text: "GPU Memory:"
                    color: "#888"
                    font.pixelSize: 14
                    width: 120
                }
                Rectangle {
                    width: 450
                    height: 18
                    color: "#333"
                    radius: 9
                    Rectangle {
                        width: parent.width * (gpuMemory / 100)
                        height: parent.height
                        color: gpuMemory > 90 ? "#ff4444" : gpuMemory > 70 ? "#ffaa00" : "#00ff88"
                        radius: 9
                    }
                }
                Text {
                    text: gpuMemory.toFixed(1) + "%"
                    color: gpuMemory > 90 ? "#ff4444" : "white"
                    font.pixelSize: 16
                    font.bold: gpuMemory > 90
                    width: 60
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
        
        // Pods and Power
        Row {
            width: parent.width
            spacing: 20
            
            Column {
                spacing: 3
                Text {
                    text: "Running Pods"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: runningPods.toString()
                    color: "#00ff88"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Pending"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: pendingPods.toString()
                    color: pendingPods >= 5 ? "#ff4444" : pendingPods >= 1 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Failed"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: failedPods.toString()
                    color: failedPods >= 1 ? "#ff4444" : "#00ff88"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "GPU Power"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: gpuPower.toFixed(0) + "W"
                    color: gpuPower > 1500 ? "#ff4444" : gpuPower > 1000 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Total Power"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: totalPower.toFixed(0) + "W"
                    color: totalPower > 2000 ? "#ff4444" : totalPower > 1000 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
        }
    }
}
