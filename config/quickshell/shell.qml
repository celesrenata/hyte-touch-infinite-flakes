import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
    id: root
    
    property int currentPage: 0
    property int totalPages: 4
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            id: touchPanel
            implicitWidth: screen.width
            implicitHeight: screen.height
            color: "transparent"
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "HYTE TOUCH INTERFACE\nScreen: " + (parent.parent.screen ? parent.parent.screen.name : "Unknown") + "\nSwipe to navigate"
                            color: "#00ff88"
                            font.pixelSize: 32
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    
                    // Background layer
                    // BackgroundWidget {
                    //     anchors.fill: parent
                    //     z: -1
                    // }
                    
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
                            // SystemUsageDetailWidget {
                            //     anchors.fill: parent
                            //     anchors.margins: 10
                            // }
                            Text {
                                anchors.centerIn: parent
                                text: "System Usage Details"
                                color: "white"
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
                                
                                // SettingsWidget {
                                //     width: parent.width
                                //     height: parent.height * 0.4
                                // }
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
    }
