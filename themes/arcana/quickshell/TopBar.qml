import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: topBar
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.left: 64  // Space for left Dock
    implicitHeight: 36
    color: "#D91a1025"
    
    signal wallpaperToggle()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // Workspaces
        Row {
            Layout.alignment: Qt.AlignLeft
            spacing: 8
            
            Repeater {
                model: Hyprland.workspaces
                delegate: Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    property bool isActive: modelData.id === Hyprland.focusedWorkspace?.id
                    color: isActive ? "#bd93f9" : "#44475a"
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData.id
                        color: isActive ? "#1a1025" : "#e0d0f5"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace", modelData.id)
                    }
                }
            }
        }
        
        // System Stats (CPU/RAM)
        SystemStats {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 16
        }
        
        // Window Title
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Hyprland.focusedWindow ? Hyprland.focusedWindow.title : "✨"
            color: "#f8f8f2"
            elide: Text.ElideRight
            font.family: "Sans Serif" 
            font.pixelSize: 13
        }
        
        // Weather
        WeatherWidget {
            Layout.alignment: Qt.AlignRight
        }

        // System Tray
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            
            Repeater {
                model: SystemTray.items
                
                delegate: Rectangle {
                    width: 24
                    height: 24
                    color: "transparent"
                    
                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: modelData.icon
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                modelData.activate();
                            } else if (mouse.button === Qt.RightButton) {
                                modelData.menu.open();
                            }
                        }
                    }
                }
            }
        }
        
        // Right controls
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 12
            
            // Wallpaper Button (Font Awesome)
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: wpHover.hovered ? "#bd93f9" : "transparent"
                border.color: "#bd93f9"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "\uf03e"  // image icon
                    color: wpHover.hovered ? "#1a1025" : "#bd93f9"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 12
                }
                
                HoverHandler { id: wpHover }
                TapHandler {
                    onTapped: topBar.wallpaperToggle()
                }
            }
            
            Text {
                id: clock
                text: Qt.formatDateTime(new Date(), "hh:mm A")
                color: "#bd93f9"
                font.bold: true
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm A")
                }
            }
        }
    }
}

