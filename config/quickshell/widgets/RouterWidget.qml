import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    color: "#1a1a1a"
    
    function formatBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(2) + " B"
        else if (bytes < 1048576) return (bytes / 1024).toFixed(2) + " KB"
        else if (bytes < 1073741824) return (bytes / 1048576).toFixed(2) + " MB"
        else if (bytes < 1099511627776) return (bytes / 1073741824).toFixed(2) + " GB"
        else return (bytes / 1099511627776).toFixed(2) + " TB"
    }
    
    property real wanInMBps: 0
    property real wanOutMBps: 0
    property real vpnInMBps: 0
    property real vpnOutMBps: 0
    property real wgOtherInMBps: 0
    property real wgOtherOutMBps: 0
    property real k8sInMBps: 0
    property real k8sOutMBps: 0
    
    property real totalWanInGB: 0
    property real totalWanOutGB: 0
    property real totalVpnInGB: 0
    property real totalVpnOutGB: 0
    property real totalWgOtherInGB: 0
    property real totalWgOtherOutGB: 0
    property real totalK8sInGB: 0
    property real totalK8sOutGB: 0
    
    property var wanInHistory: []
    property var wanOutHistory: []
    property var vpnInHistory: []
    property var vpnOutHistory: []
    property var wgOtherInHistory: []
    property var wgOtherOutHistory: []
    property var k8sInHistory: []
    property var k8sOutHistory: []
    
    property var lastWanIn: 0
    property var lastWanOut: 0
    property var lastVpnIn: 0
    property var lastVpnOut: 0
    property var lastWgOtherIn: 0
    property var lastWgOtherOut: 0
    property var lastK8sIn: 0
    property var lastK8sOut: 0
    property var lastTime: 0
    property var initialWanIn: 0
    property var initialWanOut: 0
    property var initialVpnIn: 0
    property var initialVpnOut: 0
    property var initialWgOtherIn: 0
    property var initialWgOtherOut: 0
    property var initialK8sIn: 0
    property var initialK8sOut: 0
    
    Process {
        id: snmpQuery
        running: true
        command: ["/run/current-system/sw/bin/sh", "-c",
            "nix-shell -p net-snmp --run \"snmpget -v2c -c public 192.168.42.1 " +
            "IF-MIB::ifInOctets.1 IF-MIB::ifOutOctets.1 " + // WAN
            "IF-MIB::ifInOctets.4 IF-MIB::ifOutOctets.4 " + // Cellular
            "IF-MIB::ifInOctets.9 IF-MIB::ifOutOctets.9 " + // Surfshark
            "IF-MIB::ifInOctets.10 IF-MIB::ifOutOctets.10 " + // NORDVPN
            "IF-MIB::ifInOctets.14 IF-MIB::ifOutOctets.14 " + // Mullvad
            "IF-MIB::ifInOctets.11 IF-MIB::ifOutOctets.11 " + // IntegratedCurry
            "IF-MIB::ifInOctets.13 IF-MIB::ifOutOctets.13 " + // DenofDebauchry
            "IF-MIB::ifInOctets.16 IF-MIB::ifOutOctets.16 " + // Arsham
            "IF-MIB::ifInOctets.17 IF-MIB::ifOutOctets.17 " + // Renato
            "IF-MIB::ifInOctets.18 IF-MIB::ifOutOctets.18 " + // Caleb
            "IF-MIB::ifInOctets.15 IF-MIB::ifOutOctets.15 " + // Khorne
            "IF-MIB::ifInOctets.19 IF-MIB::ifOutOctets.19\""]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var lines = text.split('\n')
                    var currentTime = Date.now()
                    
                    var wanIn = 0, wanOut = 0
                    var vpnIn = 0, vpnOut = 0
                    var wgOtherIn = 0, wgOtherOut = 0
                    var k8sIn = 0, k8sOut = 0
                    
                    for (var i = 0; i < lines.length; i++) {
                        var match = lines[i].match(/ifInOctets\.(\d+) = Counter\d+: (\d+)/)
                        if (match) {
                            var ifIndex = parseInt(match[1])
                            var value = parseInt(match[2])
                            if (ifIndex === 1 || ifIndex === 4) wanIn += value
                            else if (ifIndex === 9 || ifIndex === 10 || ifIndex === 14) vpnIn += value
                            else if (ifIndex === 11 || ifIndex === 13 || ifIndex === 16 || ifIndex === 17 || ifIndex === 18 || ifIndex === 15) wgOtherIn += value
                            else if (ifIndex === 19) k8sIn = value
                        }
                        
                        match = lines[i].match(/ifOutOctets\.(\d+) = Counter\d+: (\d+)/)
                        if (match) {
                            var ifIndex = parseInt(match[1])
                            var value = parseInt(match[2])
                            if (ifIndex === 1 || ifIndex === 4) wanOut += value
                            else if (ifIndex === 9 || ifIndex === 10 || ifIndex === 14) vpnOut += value
                            else if (ifIndex === 11 || ifIndex === 13 || ifIndex === 16 || ifIndex === 17 || ifIndex === 18 || ifIndex === 15) wgOtherOut += value
                            else if (ifIndex === 19) k8sOut = value
                        }
                    }
                    
                    if (initialWanIn === 0) {
                        initialWanIn = wanIn
                        initialWanOut = wanOut
                        initialVpnIn = vpnIn
                        initialVpnOut = vpnOut
                        initialWgOtherIn = wgOtherIn
                        initialWgOtherOut = wgOtherOut
                        initialK8sIn = k8sIn
                        initialK8sOut = k8sOut
                    }
                    
                    totalWanInGB = (wanIn - initialWanIn)
                    totalWanOutGB = (wanOut - initialWanOut)
                    totalVpnInGB = (vpnIn - initialVpnIn)
                    totalVpnOutGB = (vpnOut - initialVpnOut)
                    totalWgOtherInGB = (wgOtherIn - initialWgOtherIn)
                    totalWgOtherOutGB = (wgOtherOut - initialWgOtherOut)
                    totalK8sInGB = (k8sIn - initialK8sIn)
                    totalK8sOutGB = (k8sOut - initialK8sOut)
                    
                    if (lastTime > 0) {
                        var timeDelta = (currentTime - lastTime) / 1000
                        wanInMBps = Math.max(0, ((wanIn - lastWanIn) / timeDelta) / 1048576)
                        wanOutMBps = Math.max(0, ((wanOut - lastWanOut) / timeDelta) / 1048576)
                        vpnInMBps = Math.max(0, ((vpnIn - lastVpnIn) / timeDelta) / 1048576)
                        vpnOutMBps = Math.max(0, ((vpnOut - lastVpnOut) / timeDelta) / 1048576)
                        wgOtherInMBps = Math.max(0, ((wgOtherIn - lastWgOtherIn) / timeDelta) / 1048576)
                        wgOtherOutMBps = Math.max(0, ((wgOtherOut - lastWgOtherOut) / timeDelta) / 1048576)
                        k8sInMBps = Math.max(0, ((k8sIn - lastK8sIn) / timeDelta) / 1048576)
                        k8sOutMBps = Math.max(0, ((k8sOut - lastK8sOut) / timeDelta) / 1048576)
                        
                        wanInHistory.push(wanInMBps)
                        wanOutHistory.push(wanOutMBps)
                        vpnInHistory.push(vpnInMBps)
                        vpnOutHistory.push(vpnOutMBps)
                        wgOtherInHistory.push(wgOtherInMBps)
                        wgOtherOutHistory.push(wgOtherOutMBps)
                        k8sInHistory.push(k8sInMBps)
                        k8sOutHistory.push(k8sOutMBps)
                        
                        if (wanInHistory.length > 60) wanInHistory.shift()
                        if (wanOutHistory.length > 60) wanOutHistory.shift()
                        if (vpnInHistory.length > 60) vpnInHistory.shift()
                        if (vpnOutHistory.length > 60) vpnOutHistory.shift()
                        if (wgOtherInHistory.length > 60) wgOtherInHistory.shift()
                        if (wgOtherOutHistory.length > 60) wgOtherOutHistory.shift()
                        if (k8sInHistory.length > 60) k8sInHistory.shift()
                        if (k8sOutHistory.length > 60) k8sOutHistory.shift()
                    }
                    
                    lastWanIn = wanIn
                    lastWanOut = wanOut
                    lastVpnIn = vpnIn
                    lastVpnOut = vpnOut
                    lastWgOtherIn = wgOtherIn
                    lastWgOtherOut = wgOtherOut
                    lastK8sIn = k8sIn
                    lastK8sOut = k8sOut
                    lastTime = currentTime
                } catch (e) {
                    console.log("Router parse error:", e)
                }
            }
        }
    }
    
    Timer {
        running: true
        repeat: true
        interval: 5000
        onTriggered: snmpQuery.running = true
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        Text {
            text: "Router Traffic"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Column {
            width: parent.width
            spacing: 10
            
            // Top row
            Row {
                width: parent.width
                spacing: 10
                
                // WAN Graph
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: width
                    color: "#2a2a2a"
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: "WAN + Cellular"
                            color: "#00ff88"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Canvas {
                            id: wanCanvas
                            width: parent.width
                            height: parent.height - 30
                            
                            Timer {
                                interval: 2000
                                running: true
                                repeat: true
                                onTriggered: wanCanvas.requestPaint()
                            }
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                if (wanInHistory.length < 2) return
                                
                                var maxVal = Math.max(...wanInHistory, ...wanOutHistory, 1)
                                
                                // Draw horizontal grid lines with labels
                                ctx.strokeStyle = "#333"
                                ctx.lineWidth = 1
                                ctx.fillStyle = "#888"
                                ctx.font = "10px sans-serif"
                                for (var i = 0; i <= 4; i++) {
                                    var y = (i / 4) * height
                                    ctx.beginPath()
                                    ctx.moveTo(0, y)
                                    ctx.lineTo(width, y)
                                    ctx.stroke()
                                    
                                    var value = maxVal * (1 - i / 4)
                                    ctx.fillText(value.toFixed(1) + " MB/s", 5, y - 2)
                                }
                                
                                // Draw download line
                                ctx.strokeStyle = "#00ff88"
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                for (var i = 0; i < wanInHistory.length; i++) {
                                    var x = (i / (wanInHistory.length - 1)) * width
                                    var y = height - (wanInHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                                
                                // Draw upload line
                                ctx.strokeStyle = "#ffaa00"
                                ctx.beginPath()
                                for (var i = 0; i < wanOutHistory.length; i++) {
                                    var x = (i / (wanOutHistory.length - 1)) * width
                                    var y = height - (wanOutHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                            }
                        }
                    }
                    
                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 2
                        Text {
                            text: "↓ " + formatBytes(totalWanInGB)
                            color: "#00ff88"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: "↑ " + formatBytes(totalWanOutGB)
                            color: "#ffaa00"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
                
                // VPN Graph
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: width
                    color: "#2a2a2a"
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: "WireGuard VPNs"
                            color: "#00ff88"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Canvas {
                            id: vpnCanvas
                            width: parent.width
                            height: parent.height - 30
                            
                            Timer {
                                interval: 2000
                                running: true
                                repeat: true
                                onTriggered: vpnCanvas.requestPaint()
                            }
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                if (vpnInHistory.length < 2) return
                                
                                var maxVal = Math.max(...vpnInHistory, ...vpnOutHistory, 1)
                                
                                // Draw horizontal grid lines with labels
                                ctx.strokeStyle = "#333"
                                ctx.lineWidth = 1
                                ctx.fillStyle = "#888"
                                ctx.font = "10px sans-serif"
                                for (var i = 0; i <= 4; i++) {
                                    var y = (i / 4) * height
                                    ctx.beginPath()
                                    ctx.moveTo(0, y)
                                    ctx.lineTo(width, y)
                                    ctx.stroke()
                                    
                                    var value = maxVal * (1 - i / 4)
                                    ctx.fillText(value.toFixed(1) + " MB/s", 5, y - 2)
                                }
                                
                                // Draw download line
                                ctx.strokeStyle = "#00ff88"
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                for (var i = 0; i < vpnInHistory.length; i++) {
                                    var x = (i / (vpnInHistory.length - 1)) * width
                                    var y = height - (vpnInHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                                
                                // Draw upload line
                                ctx.strokeStyle = "#ffaa00"
                                ctx.beginPath()
                                for (var i = 0; i < vpnOutHistory.length; i++) {
                                    var x = (i / (vpnOutHistory.length - 1)) * width
                                    var y = height - (vpnOutHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                            }
                        }
                    }
                    
                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 2
                        Text {
                            text: "↓ " + formatBytes(totalVpnInGB)
                            color: "#00ff88"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: "↑ " + formatBytes(totalVpnOutGB)
                            color: "#ffaa00"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
            
            // Bottom row
            Row {
                width: parent.width
                spacing: 10
                
                // WG Other Graph
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: width
                    color: "#2a2a2a"
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: "WireGuard Other"
                            color: "#00ff88"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Canvas {
                            id: wgOtherCanvas
                            width: parent.width
                            height: parent.height - 30
                            
                            Timer {
                                interval: 2000
                                running: true
                                repeat: true
                                onTriggered: wgOtherCanvas.requestPaint()
                            }
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                if (wgOtherInHistory.length < 2) return
                                
                                var maxVal = Math.max(...wgOtherInHistory, ...wgOtherOutHistory, 1)
                                
                                // Draw horizontal grid lines with labels
                                ctx.strokeStyle = "#333"
                                ctx.lineWidth = 1
                                ctx.fillStyle = "#888"
                                ctx.font = "10px sans-serif"
                                for (var i = 0; i <= 4; i++) {
                                    var y = (i / 4) * height
                                    ctx.beginPath()
                                    ctx.moveTo(0, y)
                                    ctx.lineTo(width, y)
                                    ctx.stroke()
                                    
                                    var value = maxVal * (1 - i / 4)
                                    ctx.fillText(value.toFixed(1) + " MB/s", 5, y - 2)
                                }
                                
                                // Draw download line
                                ctx.strokeStyle = "#00ff88"
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                for (var i = 0; i < wgOtherInHistory.length; i++) {
                                    var x = (i / (wgOtherInHistory.length - 1)) * width
                                    var y = height - (wgOtherInHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                                
                                // Draw upload line
                                ctx.strokeStyle = "#ffaa00"
                                ctx.beginPath()
                                for (var i = 0; i < wgOtherOutHistory.length; i++) {
                                    var x = (i / (wgOtherOutHistory.length - 1)) * width
                                    var y = height - (wgOtherOutHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                            }
                        }
                    }
                    
                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 2
                        Text {
                            text: "↓ " + formatBytes(totalWgOtherInGB)
                            color: "#00ff88"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: "↑ " + formatBytes(totalWgOtherOutGB)
                            color: "#ffaa00"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
                
                // K8s Graph
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: width
                    color: "#2a2a2a"
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: "Kubernetes"
                            color: "#00ff88"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Canvas {
                            id: k8sCanvas
                            width: parent.width
                            height: parent.height - 30
                            
                            Timer {
                                interval: 2000
                                running: true
                                repeat: true
                                onTriggered: k8sCanvas.requestPaint()
                            }
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                if (k8sInHistory.length < 2) return
                                
                                var maxVal = Math.max(...k8sInHistory, ...k8sOutHistory, 1)
                                
                                // Draw horizontal grid lines with labels
                                ctx.strokeStyle = "#333"
                                ctx.lineWidth = 1
                                ctx.fillStyle = "#888"
                                ctx.font = "10px sans-serif"
                                for (var i = 0; i <= 4; i++) {
                                    var y = (i / 4) * height
                                    ctx.beginPath()
                                    ctx.moveTo(0, y)
                                    ctx.lineTo(width, y)
                                    ctx.stroke()
                                    
                                    var value = maxVal * (1 - i / 4)
                                    ctx.fillText(value.toFixed(1) + " MB/s", 5, y - 2)
                                }
                                
                                // Draw download line
                                ctx.strokeStyle = "#00ff88"
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                for (var i = 0; i < k8sInHistory.length; i++) {
                                    var x = (i / (k8sInHistory.length - 1)) * width
                                    var y = height - (k8sInHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                                
                                // Draw upload line
                                ctx.strokeStyle = "#ffaa00"
                                ctx.beginPath()
                                for (var i = 0; i < k8sOutHistory.length; i++) {
                                    var x = (i / (k8sOutHistory.length - 1)) * width
                                    var y = height - (k8sOutHistory[i] / maxVal) * height
                                    if (i === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()
                            }
                        }
                    }
                    
                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 2
                        Text {
                            text: "↓ " + formatBytes(totalK8sInGB)
                            color: "#00ff88"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                        Text {
                            text: "↑ " + formatBytes(totalK8sOutGB)
                            color: "#ffaa00"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
    }
}
