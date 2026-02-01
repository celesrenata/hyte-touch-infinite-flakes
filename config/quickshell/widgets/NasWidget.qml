import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    color: "#1a1a1a"
    
    property real storageTotal: 0
    property real storageUsed: 0
    property real storagePercent: 0
    property string nasName: ""
    property int uptime: 0
    property real diskReadMBps: 0
    property real diskWriteMBps: 0
    
    property var lastReadBytes: 0
    property var lastWriteBytes: 0
    property var lastTime: 0
    
    Process {
        id: snmpQuery
        running: true
        command: ["/run/current-system/sw/bin/sh", "-c",
            "nix-shell -p net-snmp --run \"snmpget -v2c -c public 192.168.42.8 " +
            "SNMPv2-MIB::sysName.0 " +
            "DISMAN-EVENT-MIB::sysUpTimeInstance " +
            "HOST-RESOURCES-MIB::hrStorageSize.56 " +
            "HOST-RESOURCES-MIB::hrStorageUsed.56 && " +
            "snmpwalk -v2c -c public 192.168.42.8 .1.3.6.1.4.1.6574.101.1.1.3 && " +
            "snmpwalk -v2c -c public 192.168.42.8 .1.3.6.1.4.1.6574.101.1.1.4\""]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var lines = text.split('\n')
                    var totalRead = 0
                    var totalWrite = 0
                    var currentTime = Date.now()
                    
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].includes('sysName')) {
                            nasName = lines[i].split('STRING: ')[1] || "NAS"
                        } else if (lines[i].includes('sysUpTimeInstance')) {
                            var match = lines[i].match(/\((\d+)\)/)
                            if (match) uptime = parseInt(match[1]) / 8640000
                        } else if (lines[i].includes('hrStorageSize.56')) {
                            var size = parseInt(lines[i].split('INTEGER: ')[1])
                            storageTotal = size * 32768 / 1099511627776
                        } else if (lines[i].includes('hrStorageUsed.56')) {
                            var used = parseInt(lines[i].split('INTEGER: ')[1])
                            storageUsed = used * 32768 / 1099511627776
                        } else if (lines[i].includes('.101.1.1.3.')) {
                            var readMatch = lines[i].match(/Counter32: (\d+)/)
                            if (readMatch) totalRead += parseInt(readMatch[1])
                        } else if (lines[i].includes('.101.1.1.4.')) {
                            var writeMatch = lines[i].match(/Counter32: (\d+)/)
                            if (writeMatch) totalWrite += parseInt(writeMatch[1])
                        }
                    }
                    
                    if (storageTotal > 0) {
                        storagePercent = (storageUsed / storageTotal) * 100
                    }
                    
                    if (lastTime > 0) {
                        var timeDelta = (currentTime - lastTime) / 1000
                        diskReadMBps = ((totalRead - lastReadBytes) / timeDelta) / 1048576
                        diskWriteMBps = ((totalWrite - lastWriteBytes) / timeDelta) / 1048576
                    }
                    
                    lastReadBytes = totalRead
                    lastWriteBytes = totalWrite
                    lastTime = currentTime
                } catch (e) {
                    console.log("NAS parse error:", e)
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
        spacing: 15
        
        Text {
            text: nasName + " NAS"
            color: "#00ff88"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
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
                    width: parent.width * (storagePercent / 100)
                    height: parent.height
                    color: storagePercent > 90 ? "#ff4444" : storagePercent > 70 ? "#ffaa00" : "#00ff88"
                    radius: 9
                }
            }
            Text {
                text: storagePercent.toFixed(1) + "%"
                color: storagePercent > 90 ? "#ff4444" : "white"
                font.pixelSize: 16
                font.bold: storagePercent > 90
                width: 60
                horizontalAlignment: Text.AlignRight
            }
        }
        
        Row {
            spacing: 20
            Column {
                spacing: 3
                Text {
                    text: "Used"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: storageUsed.toFixed(1) + " TB"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Total"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: storageTotal.toFixed(1) + " TB"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Read"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: diskReadMBps.toFixed(1) + " MB/s"
                    color: "#00ff88"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Write"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: diskWriteMBps.toFixed(1) + " MB/s"
                    color: "#ffaa00"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
            
            Column {
                spacing: 3
                Text {
                    text: "Uptime"
                    color: "#888"
                    font.pixelSize: 14
                }
                Text {
                    text: uptime.toFixed(0) + " days"
                    color: "#888"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
        }
    }
}
