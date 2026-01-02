import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Panel {
    id: topBar
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: 36
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
                    
                    // Glow effect for active workspace
                    layer.enabled: isActive
                    
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
        
        // Window Title
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Hyprland.focusedWindow ? Hyprland.focusedWindow.title : "..."
            color: "#f8f8f2"
            elide: Text.ElideRight
            font.family: "Sans Serif" 
            font.pixelSize: 14
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
        
        // Time & Date
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 12
            
            // Wallpaper Button
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: wpHover.hovered ? "#bd93f9" : "transparent"
                border.color: "#bd93f9"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "🖼"
                    font.pixelSize: 14
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
