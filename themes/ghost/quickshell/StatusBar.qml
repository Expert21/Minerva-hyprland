import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Panel {
    id: statusBar
    anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
    }
    height: 32
    color: "#e6000000"
    
    signal toggleCommandCenter()
    signal wallpaperToggle()

    // System stats
    property var statsOutput: {"cpu": "0", "mem_used": "0", "mem_total": "0"}
    
    // VPN status
    property string vpnStatus: "DISCONNECTED"
    property bool vpnConnected: false

    Process {
        id: statProc
        command: ["/home/isaiah/hyprland rice/scripts/get_stats.sh"]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    try {
                        statusBar.statsOutput = JSON.parse(content.trim())
                    } catch(e) {}
                }
            }
        }
    }

    Process {
        id: vpnProc
        command: ["/home/isaiah/hyprland rice/scripts/get_vpn_status.sh"]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    try {
                        var result = JSON.parse(content.trim())
                        statusBar.vpnConnected = (result.connected === "Connected")
                        statusBar.vpnStatus = result.connected.toUpperCase()
                    } catch(e) {}
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            statProc.running = false
            statProc.running = true
            vpnProc.running = false
            vpnProc.running = true
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 20

        // Ghost Mode Label
        Text {
            text: "[ GHOST MODE ]"
            color: "#00ff00"
            font.family: "Monospace"
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        // VPN Status
        Text {
            text: "VPN: " + statusBar.vpnStatus
            color: statusBar.vpnConnected ? "#00ff00" : "#ff3333"
            font.family: "Monospace"
            font.bold: true
        }

        // CPU
        Text {
            text: "CPU: " + statsOutput.cpu + "%"
            color: "#00ff00"
            font.family: "Monospace"
        }

        // MEM
        Text {
            text: "MEM: " + statsOutput.mem_used + "M / " + statsOutput.mem_total + "M"
            color: "#00ff00"
            font.family: "Monospace"
        }
        
        // Command Center Button
        Rectangle {
            width: 100
            height: 24
            color: ccHover.hovered ? "#00ff00" : "transparent"
            border.color: "#00ff00"
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: "COMMANDS"
                color: ccHover.hovered ? "#000000" : "#00ff00"
                font.family: "Monospace"
                font.bold: true
            }
            
            HoverHandler { id: ccHover }
            TapHandler {
                onTapped: statusBar.toggleCommandCenter()
            }
        }
        
        // Wallpaper Button
        Rectangle {
            width: 80
            height: 24
            color: wpHover.hovered ? "#00ff00" : "transparent"
            border.color: "#00ff00"
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: "WALLPAPER"
                color: wpHover.hovered ? "#000000" : "#00ff00"
                font.family: "Monospace"
                font.bold: true
                font.pixelSize: 10
            }
            
            HoverHandler { id: wpHover }
            TapHandler {
                onTapped: statusBar.wallpaperToggle()
            }
        }

        // Time
        Text {
            id: clock
            text: Qt.formatDateTime(new Date(), "HH:mm:ss")
            color: "#00ff00"
            font.family: "Monospace"
            font.bold: true
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm:ss")
            }
        }
    }
}

