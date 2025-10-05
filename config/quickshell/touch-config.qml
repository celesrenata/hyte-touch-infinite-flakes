import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 1.0

ShellRoot {
    id: root
    
    property int currentPage: 0
    property int totalPages: 4
    
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
                        
                        onCurrentIndexChanged: root.currentPage = currentIndex
                        
                        // Page 1: Overview - Temperature + Usage
                        Item {
                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                TemperatureWidget {
                                    width: parent.width * 0.5
                                    height: parent.height
                                }
                                
                                SystemUsageWidget {
                                    width: parent.width * 0.5
                                    height: parent.height
                                }
                            }
                        }
                        
                        // Page 2: Detailed Temperature Graphs
                        Item {
                            TemperatureDetailWidget {
                                anchors.fill: parent
                                anchors.margins: 10
                            }
                        }
                        
                        // Page 3: Detailed System Usage
                        Item {
                            SystemUsageDetailWidget {
                                anchors.fill: parent
                                anchors.margins: 10
                            }
                        }
                        
                        // Page 4: Music Visualizer + Settings
                        Item {
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                MusicVisualizerWidget {
                                    width: parent.width
                                    height: parent.height * 0.6
                                }
                                
                                SettingsWidget {
                                    width: parent.width
                                    height: parent.height * 0.4
                                }
                            }
                        }
                    }
                    
                    // Page indicator
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.margins: 15
                        spacing: 8
                        z: 100
                        
                        Repeater {
                            model: root.totalPages
                            
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: index === root.currentPage ? "#4ecdc4" : "#666666"
                                opacity: 0.8
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                        }
                    }
                    
                    // Touch gesture handling
                    MouseArea {
                        anchors.fill: parent
                        z: -10
                        
                        property real startX: 0
                        property real threshold: 100
                        
                        onPressed: startX = mouse.x
                        
                        onReleased: {
                            var deltaX = mouse.x - startX
                            
                            if (Math.abs(deltaX) > threshold) {
                                if (deltaX > 0 && root.currentPage > 0) {
                                    // Swipe right - previous page
                                    swipeView.currentIndex = root.currentPage - 1
                                } else if (deltaX < 0 && root.currentPage < root.totalPages - 1) {
                                    // Swipe left - next page
                                    swipeView.currentIndex = root.currentPage + 1
                                }
                            }
                        }
                    }
                }
            }
        ]
    }
}
                        
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
