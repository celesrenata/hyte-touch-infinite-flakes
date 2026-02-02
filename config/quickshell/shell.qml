import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
    id: root
    
    property int currentPage: 0
    property int totalPages: 4
    
    Component.onCompleted: {
        console.log("QuickShell started, screens:", Quickshell.screens.length)
        for (var i = 0; i < Quickshell.screens.length; i++) {
            console.log("Screen", i, ":", Quickshell.screens[i].name, Quickshell.screens[i].width, "x", Quickshell.screens[i].height)
        }
    }
    
    Variants {
        model: Quickshell.screens.filter(screen => screen.name === "DP-3")
        
        PanelWindow {
            property var modelData
            screen: modelData
            id: touchPanel
            implicitWidth: screen.width
            implicitHeight: screen.height
            color: "transparent"  // Transparent so visualizer shows through
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        opacity: 0.3  // Very transparent background
                    }
                    
                    // Main swipe container
                    SwipeView {
                        id: swipeView
                        anchors.fill: parent
                        currentIndex: root.currentPage
                        opacity: 0.85  // Widgets more opaque for readability
                        
                        onCurrentIndexChanged: root.currentPage = currentIndex
                        
                        // Page 1: Overview - Temperature + Usage + Network
                        Item {
                            Row {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.topMargin: 0
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                height: parent.height * 0.15
                                spacing: 10
                                
                                Column {
                                    width: parent.width * 0.5
                                    spacing: 5
                                    
                                    TemperatureWidget {
                                        width: parent.width
                                        height: parent.parent.height * 0.65
                                    }
                                    
                                    PowerWidget {
                                        width: parent.width
                                        height: parent.parent.height * 0.35
                                    }
                                }
                                
                                SystemUsageWidget {
                                    width: parent.width * 0.5
                                    height: parent.height
                                }
                            }
                            
                            NetworkWidget {
                                anchors.top: parent.top
                                anchors.topMargin: parent.height * 0.15 + 5
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                height: parent.height * 0.125
                            }
                            
                            GrafanaWidget {
                                id: grafanaWidget
                                anchors.top: parent.top
                                anchors.topMargin: parent.height * 0.275 + 5
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                height: parent.height * 0.13
                            }
                            
                            NasWidget {
                                id: nasWidget
                                anchors.top: grafanaWidget.bottom
                                anchors.topMargin: 5
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                height: parent.height * 0.08
                            }
                            
                            RouterWidget {
                                anchors.top: nasWidget.bottom
                                anchors.topMargin: 5
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 10
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
                        
                        // Page 4: Music Visualizer
                        Item {
                            MusicVisualizerWidget {
                                anchors.fill: parent
                                anchors.margins: 10
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
                        z: 1000
                        propagateComposedEvents: true
                        
                        property real startX: 0
                        property real threshold: 100
                        
                        onPressed: function(mouse) {
                            startX = mouse.x
                            mouse.accepted = false
                        }
                        
                        onReleased: function(mouse) {
                            var deltaX = mouse.x - startX
                            
                            if (Math.abs(deltaX) > threshold) {
                                if (deltaX > 0 && root.currentPage > 0) {
                                    // Swipe right - previous page
                                    swipeView.currentIndex = root.currentPage - 1
                                } else if (deltaX < 0 && root.currentPage < root.totalPages - 1) {
                                    // Swipe left - next page
                                    swipeView.currentIndex = root.currentPage + 1
                                }
                                mouse.accepted = true
                            } else {
                                mouse.accepted = false
                            }
                        }
                    }
                    
                    // NixOS logo in empty space below widgets
                    Image {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: parent.height * 0.04
                        source: "file:///home/celes/.config/quickshell/touch/nixos-logo.png"
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.7
                        opacity: 0.7
                    }
                }
        }
    }
