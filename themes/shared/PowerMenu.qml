import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Power Menu - Arcana styled logout/reboot/shutdown
PanelWindow {
    id: powerMenu
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

    Keys.onEscapePressed: powerMenu.visible = false

    // Power actions
    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }

    Rectangle {
        anchors.centerIn: parent
        width: 450
        height: 200
        color: bgColor
        border.color: accentColor
        border.width: 2
        radius: 16

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Header
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "⚡ POWER MENU"
                color: accentColor
                font.family: fontFamily
                font.bold: true
                font.pixelSize: 16
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // Lock
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: lockHover.hovered ? "#bd93f933" : "transparent"
                    border.color: accentColor
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uf023"  // lock icon
                            color: accentColor
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 32
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "LOCK"
                            color: accentColor
                            font.family: fontFamily
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    HoverHandler { id: lockHover }
                    TapHandler {
                        onTapped: {
                            lockProc.running = true
                            powerMenu.visible = false
                        }
                    }
                }

                // Logout
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: logoutHover.hovered ? "#ffd93d33" : "transparent"
                    border.color: "#ffd93d"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uf2f5"  // sign-out icon
                            color: "#ffd93d"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 32
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "LOGOUT"
                            color: "#ffd93d"
                            font.family: fontFamily
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    HoverHandler { id: logoutHover }
                    TapHandler {
                        onTapped: logoutProc.running = true
                    }
                }

                // Reboot
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: rebootHover.hovered ? "#4ecdc433" : "transparent"
                    border.color: "#4ecdc4"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uf2f1"  // sync icon
                            color: "#4ecdc4"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 32
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "REBOOT"
                            color: "#4ecdc4"
                            font.family: fontFamily
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    HoverHandler { id: rebootHover }
                    TapHandler {
                        onTapped: rebootProc.running = true
                    }
                }

                // Shutdown
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: shutdownHover.hovered ? "#ff6b6b33" : "transparent"
                    border.color: "#ff6b6b"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uf011"  // power icon
                            color: "#ff6b6b"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 32
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SHUTDOWN"
                            color: "#ff6b6b"
                            font.family: fontFamily
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    HoverHandler { id: shutdownHover }
                    TapHandler {
                        onTapped: shutdownProc.running = true
                    }
                }
            }

            // Hint
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "ESC TO CANCEL"
                color: "#555555"
                font.family: fontFamily
                font.pixelSize: 10
            }
        }
    }
}
