import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 1.0

ShellRoot {
    id: root
    
    property int currentPage: 0
    
    Variants {
        variants: [
            Variant {
                name: "touch-display"
                
                PanelWindow {
                    id: touchPanel
                    anchors.fill: true
                    color: "transparent"
                    
                    // Background layer
                    BackgroundWidget {
                        anchors.fill: parent
                        z: -1
                    }
                    
                    // Main swipe container
                    SwipeView {
                        id: swipeView
                        anchors.fill: parent
                        currentIndex: root.currentPage
                        
                        // Overview page
                        Item {
                            Row {
                                anchors.fill: parent
                                
                                Column {
                                    width: parent.width * 0.7
                                    height: parent.height
                                    
                                    TemperatureWidget {
                                        width: parent.width
                                        height: parent.height * 0.5
                                    }
                                    
                                    SystemUsageWidget {
                                        width: parent.width
                                        height: parent.height * 0.5
                                    }
                                }
                                
                                MusicVisualizerWidget {
                                    width: parent.width * 0.3
                                    height: parent.height
                                }
                            }
                        }
                        
                        TemperatureDetailWidget {}
                        SystemUsageDetailWidget {}
                        SettingsWidget {}
                    }
                    
                    PageIndicator {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.margins: 10
                        count: swipeView.count
                        currentIndex: swipeView.currentIndex
                        delegate: Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: index === swipeView.currentIndex ? "white" : "#666"
                        }
                    }
                    
                    MultiPointTouchArea {
                        anchors.fill: parent
                        
                        property real startX: 0
                        property real threshold: 50
                        
                        onPressed: startX = touchPoints[0].x
                        
                        onReleased: {
                            let deltaX = touchPoints[0].x - startX
                            if (Math.abs(deltaX) > threshold) {
                                if (deltaX > 0 && swipeView.currentIndex > 0) {
                                    swipeView.currentIndex--
                                } else if (deltaX < 0 && swipeView.currentIndex < swipeView.count - 1) {
                                    swipeView.currentIndex++
                                }
                            }
                        }
                    }
                }
            }
        ]
    }
}
