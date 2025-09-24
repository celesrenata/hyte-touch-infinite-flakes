import QtQuick 2.15

Rectangle {
    color: "#1a1a1a"
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "System Usage Details"
            color: "white"
            font.pixelSize: 18
            font.bold: true
        }
        
        // CPU Details
        Rectangle {
            width: parent.width
            height: 80
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                
                Text {
                    text: "CPU Usage"
                    color: "white"
                    font.bold: true
                }
                
                UsageBar {
                    label: "Total"
                    value: 45
                    color: "#ff9f43"
                }
            }
        }
        
        // Disk Usage
        Rectangle {
            width: parent.width
            height: 120
            color: "#2d2d2d"
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 5
                
                Text {
                    text: "Disk Usage"
                    color: "white"
                    font.bold: true
                }
                
                UsageBar {
                    label: "/"
                    value: 65
                    color: "#10ac84"
                }
                
                UsageBar {
                    label: "/home"
                    value: 32
                    color: "#5f27cd"
                }
            }
        }
    }
}
