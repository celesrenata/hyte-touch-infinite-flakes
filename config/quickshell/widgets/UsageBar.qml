import QtQuick 2.15

Item {
    property string label: ""
    property real value: 0
    property color color: "#ffffff"
    
    height: 30
    width: parent.width
    
    Text {
        id: labelText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: label
        color: "white"
        font.pixelSize: 12
        width: 40
    }
    
    Rectangle {
        id: background
        anchors.left: labelText.right
        anchors.right: valueText.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        height: 8
        color: "#404040"
        radius: 4
        
        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (value / 100)
            color: parent.parent.color
            radius: 4
            
            Behavior on width {
                NumberAnimation { duration: 300 }
            }
        }
    }
    
    Text {
        id: valueText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(value) + "%"
        color: "white"
        font.pixelSize: 12
        width: 35
    }
}
