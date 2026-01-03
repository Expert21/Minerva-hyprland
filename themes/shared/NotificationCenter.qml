import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Notification Center - Dunst history panel
PanelWindow {
    id: notificationCenter
    // Fullscreen overlay with centered content
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    visible: false
    focusable: true

    property color accentColor: "#bd93f9"
    property color bgColor: "#e61a1025"
    property string fontFamily: "Sans Serif"
    property var notifications: []

    Keys.onEscapePressed: notificationCenter.visible = false

    // Fetch dunst history
    Process {
        id: historyProc
        command: ["/bin/sh", "-c", "dunstctl history | jq -c '.data[0][]' 2>/dev/null"]
        stdout: StdioCollector {
            onTextChanged: {
                if (text.trim() !== "") {
                    var lines = text.trim().split("\n")
                    var items = []
                    for (var i = 0; i < Math.min(lines.length, 20); i++) {
                        try {
                            var item = JSON.parse(lines[i])
                            items.push({
                                summary: item.summary?.data || "Notification",
                                body: item.body?.data || "",
                                appname: item.appname?.data || "",
                                id: item.id?.data || i
                            })
                        } catch(e) {}
                    }
                    notificationCenter.notifications = items
                }
            }
        }
    }

    // Clear all notifications
    Process {
        id: clearProc
        command: ["dunstctl", "history-clear"]
    }

    onVisibleChanged: {
        if (visible) {
            historyProc.running = true
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 500
        color: bgColor
        border.color: accentColor
        border.width: 2
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "\uf0f3"  // bell icon
                    color: accentColor
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 18
                }
                
                Text {
                    text: "NOTIFICATIONS"
                    color: accentColor
                    font.family: fontFamily
                    font.bold: true
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
                
                // Clear all button
                Rectangle {
                    width: 80
                    height: 28
                    radius: 6
                    color: clearHover.hovered ? "#ff6b6b" : "transparent"
                    border.color: "#ff6b6b"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "CLEAR ALL"
                        color: clearHover.hovered ? "#1a1025" : "#ff6b6b"
                        font.family: fontFamily
                        font.bold: true
                        font.pixelSize: 10
                    }
                    
                    HoverHandler { id: clearHover }
                    TapHandler {
                        onTapped: {
                            clearProc.running = true
                            notificationCenter.notifications = []
                        }
                    }
                }
            }

            // Notification list
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: notificationCenter.notifications

                delegate: Rectangle {
                    width: parent.width
                    height: notifContent.height + 16
                    color: notifHover.hovered ? "#ffffff11" : "transparent"
                    border.color: "#333333"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        id: notifContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: modelData.appname
                                color: accentColor
                                font.family: fontFamily
                                font.pixelSize: 10
                                opacity: 0.7
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        Text {
                            text: modelData.summary
                            color: "#e0e0e0"
                            font.family: fontFamily
                            font.bold: true
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        
                        Text {
                            visible: modelData.body !== ""
                            text: modelData.body
                            color: "#aaaaaa"
                            font.family: fontFamily
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    HoverHandler { id: notifHover }
                }
            }

            // Empty state
            Text {
                visible: notificationCenter.notifications.length === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No notifications"
                color: "#666666"
                font.family: fontFamily
                font.pixelSize: 12
            }

            // Close hint
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "ESC TO CLOSE"
                color: "#555555"
                font.family: fontFamily
                font.pixelSize: 10
            }
        }
    }
}
