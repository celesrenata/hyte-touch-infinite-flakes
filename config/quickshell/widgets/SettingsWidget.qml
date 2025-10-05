import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: "#1a1a1a"
    radius: 8
    
    property real brightness: 1.0
    property int dimTimeout: 30
    property bool dimEnabled: true
    
    Timer {
        id: dimTimer
        interval: dimTimeout * 1000
        running: dimEnabled
        repeat: false
        onTriggered: dimScreen()
    }
    
    function dimScreen() {
        brightness = 0.3
        SystemMonitor.exec("echo " + Math.round(brightness * 100) + " > /sys/class/backlight/*/brightness 2>/dev/null || true", function() {})
    }
    
    function resetBrightness() {
        brightness = 1.0
        dimTimer.restart()
        SystemMonitor.exec("echo 100 > /sys/class/backlight/*/brightness 2>/dev/null || true", function() {})
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: resetBrightness()
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "Display Settings"
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
        
        // Brightness control
        Row {
            width: parent.width
            spacing: 10
            
            Text {
                text: "Brightness:"
                color: "white"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Slider {
                id: brightnessSlider
                width: parent.width - 100
                from: 0.1
                to: 1.0
                value: brightness
                
                onValueChanged: {
                    brightness = value
                    resetBrightness()
                }
                
                background: Rectangle {
                    color: "#333333"
                    radius: 4
                }
                
                handle: Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#4ecdc4"
                }
            }
        }
        
        // Dim timeout control
        Row {
            width: parent.width
            spacing: 10
            
            Text {
                text: "Dim Timeout:"
                color: "white"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Slider {
                id: timeoutSlider
                width: parent.width - 120
                from: 10
                to: 120
                value: dimTimeout
                stepSize: 5
                
                onValueChanged: {
                    dimTimeout = value
                    dimTimer.interval = dimTimeout * 1000
                    if (dimEnabled) dimTimer.restart()
                }
                
                background: Rectangle {
                    color: "#333333"
                    radius: 4
                }
                
                handle: Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#ff9f43"
                }
            }
            
            Text {
                text: dimTimeout + "s"
                color: "white"
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Dim enable toggle
        Row {
            spacing: 10
            
            Switch {
                id: dimSwitch
                checked: dimEnabled
                
                onCheckedChanged: {
                    dimEnabled = checked
                    if (dimEnabled) {
                        dimTimer.restart()
                    } else {
                        dimTimer.stop()
                        resetBrightness()
                    }
                }
            }
            
            Text {
                text: "Auto-dim enabled"
                color: "white"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Current status
        Text {
            text: "Status: " + (brightness < 1.0 ? "Dimmed" : "Normal")
            color: brightness < 1.0 ? "#ff9f43" : "#4ecdc4"
            font.pixelSize: 10
        }
    }
        
        // Brightness Control
        Rectangle {
            width: parent.width
            height: 80
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Brightness: " + Math.round(brightness * 100) + "%"
                    color: "white"
                }
                
                Slider {
                    width: parent.width - 20
                    from: 0.1
                    to: 1.0
                    value: brightness
                    onValueChanged: {
                        brightness = value
                        setBrightness(value)
                    }
                }
            }
        }
        
        // Auto-dim Settings
        Rectangle {
            width: parent.width
            height: 80
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Auto-dim timeout: " + dimTimeout + "s"
                    color: "white"
                }
                
                Slider {
                    width: parent.width - 20
                    from: 10
                    to: 300
                    stepSize: 10
                    value: dimTimeout
                    onValueChanged: dimTimeout = value
                }
            }
        }
    }
    
    function setBrightness(value) {
        Process {
            program: "sh"
            arguments: ["-c", "echo " + Math.round(value * 255) + " > /sys/class/backlight/*/brightness"]
        }
    }
}
