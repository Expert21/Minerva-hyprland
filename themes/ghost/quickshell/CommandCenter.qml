import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Panel {
    id: cmdCenter
    anchors.centerIn: parent
    width: 600
    height: 400
    color: "transparent"
    visible: false

    // ESC key handler
    Keys.onEscapePressed: cmdCenter.visible = false
    focus: visible

    Rectangle {
        anchors.fill: parent
        color: "#e6050505"
        border.color: "#00ff00"
        border.width: 2
        radius: 8
        
        Text {
            text: "COMMAND CENTER"
            color: "#00ff00"
            font.family: "Monospace"
            font.bold: true
            font.pixelSize: 24
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
        }

        // Helper Component for Buttons
        component CommandButton: Rectangle {
            id: cmdBtn
            width: 200
            height: 50
            color: btnHover.hovered ? "#00ff00" : "transparent"
            border.color: "#00ff00"
            border.width: 1
            radius: 4
            
            property string label: ""
            property string cmd: ""
            
            Text {
                anchors.centerIn: parent
                text: parent.label
                color: btnHover.hovered ? "#000000" : "#00ff00"
                font.family: "Monospace"
                font.bold: true
            }
            
            HoverHandler { id: btnHover }
            
            Process {
                id: cmdLauncher
                command: ["/bin/sh", "-c", cmdBtn.cmd]
            }
            
            TapHandler {
                onTapped: {
                    cmdLauncher.running = true
                    cmdCenter.visible = false
                }
            }
        }

        GridLayout {
            columns: 2
            anchors.centerIn: parent
            rowSpacing: 20
            columnSpacing: 20

            CommandButton { label: "BURPSUITE"; cmd: "burpsuite" }
            CommandButton { label: "WIRESHARK"; cmd: "wireshark" }
            CommandButton { label: "TERMINAL"; cmd: "kitty" }
            CommandButton { label: "METASPLOIT"; cmd: "kitty -e msfconsole" }
            CommandButton { label: "NMAP"; cmd: "kitty -e nmap --help && read" }
            CommandButton { label: "GOBUSTER"; cmd: "kitty -e gobuster --help && read" }
        }
        
        Text {
            text: "PRESS ESC TO CLOSE"
            color: "#555555"
            font.family: "Monospace"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            font.pixelSize: 10
        }
    }
}

