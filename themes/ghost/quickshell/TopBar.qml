import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Stripped-down Ghost Mode TopBar: Workspaces | Time | VPN | IP
Panel {
    id: topBar
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: 32
    color: "#e6000000"

    // VPN status
    property string vpnStatus: "DISCONNECTED"
    property bool vpnConnected: false
    property string ipAddress: "0.0.0.0"

    // Workspace names for Ghost mode
    property var workspaceNames: {
        1: "TERM",
        2: "WEB",
        3: "DEV",
        4: "MEDIA",
        5: "5",
        6: "6",
        7: "7",
        8: "8",
        9: "9"
    }

    Process {
        id: vpnProc
        command: ["/bin/sh", "-c", "ip link show proton0 2>/dev/null || ip link show tun0 2>/dev/null || ip link show wg0 2>/dev/null"]
        stdout: StdioCollector {
            onContentChanged: {
                topBar.vpnConnected = content.trim().length > 0
                topBar.vpnStatus = topBar.vpnConnected ? "CONNECTED" : "DISCONNECTED"
            }
        }
    }

    Process {
        id: ipProc
        command: ["/bin/sh", "-c", "ip -4 addr show $(ip route | grep default | awk '{print $5}' | head -1) 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 | head -1"]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    topBar.ipAddress = content.trim()
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            vpnProc.running = false
            vpnProc.running = true
            ipProc.running = false
            ipProc.running = true
        }
        Component.onCompleted: {
            vpnProc.running = true
            ipProc.running = true
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        // Workspaces with named badges
        Row {
            Layout.alignment: Qt.AlignLeft
            spacing: 4

            Repeater {
                model: Hyprland.workspaces
                delegate: Rectangle {
                    width: wsLabel.width + 16
                    height: 24
                    radius: 2
                    property bool isActive: modelData.id === Hyprland.focusedWorkspace?.id
                    color: isActive ? "#00ff00" : "transparent"
                    border.color: "#00ff00"
                    border.width: 1

                    Text {
                        id: wsLabel
                        anchors.centerIn: parent
                        text: topBar.workspaceNames[modelData.id] || modelData.id.toString()
                        color: isActive ? "#000000" : "#00ff00"
                        font.family: "Monospace"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace", modelData.id)
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // VPN Status (prominent)
        Rectangle {
            width: vpnText.width + 16
            height: 24
            radius: 2
            color: topBar.vpnConnected ? "#00ff00" : "#ff3333"

            Text {
                id: vpnText
                anchors.centerIn: parent
                text: "VPN: " + topBar.vpnStatus
                color: "#000000"
                font.family: "Monospace"
                font.bold: true
                font.pixelSize: 11
            }
        }

        // IP Address
        Text {
            text: "IP: " + topBar.ipAddress
            color: "#00ffff"
            font.family: "Monospace"
            font.pixelSize: 11
        }

        // Date/Time
        Text {
            id: clock
            text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
            color: "#00ff00"
            font.family: "Monospace"
            font.bold: true
            font.pixelSize: 12

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
            }
        }
    }
}
