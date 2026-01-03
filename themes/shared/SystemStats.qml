import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Shared System Stats Widget for TopBar
Item {
    id: statsWidget
    implicitWidth: statsLayout.implicitWidth
    implicitHeight: parent.height

    property color accentColor: "#bd93f9"
    property string fontFamily: "Sans Serif"

    // Stats data
    property int cpuUsage: 0
    property int memUsage: 0
    property int memTotal: 0

    Process {
        id: statsProc
        command: ["/bin/sh", "-c", 
            "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'); " +
            "mem=$(free -m | awk '/Mem:/ {print $3}'); " +
            "memtotal=$(free -m | awk '/Mem:/ {print $2}'); " +
            "echo \"$cpu $mem $memtotal\""
        ]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    var parts = content.trim().split(" ")
                    if (parts.length >= 3) {
                        statsWidget.cpuUsage = parseInt(parts[0]) || 0
                        statsWidget.memUsage = parseInt(parts[1]) || 0
                        statsWidget.memTotal = parseInt(parts[2]) || 0
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            statsProc.running = false
            statsProc.running = true
        }
        Component.onCompleted: statsProc.running = true
    }

    RowLayout {
        id: statsLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        // CPU Usage
        Row {
            spacing: 4
            
            Text {
                text: "\uf2db"  // microchip icon
                color: statsWidget.accentColor
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Rectangle {
                width: 50
                height: 8
                radius: 4
                color: "#333333"
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    width: parent.width * (statsWidget.cpuUsage / 100)
                    height: parent.height
                    radius: 4
                    color: statsWidget.cpuUsage > 80 ? "#ff6b6b" : statsWidget.accentColor
                    
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
            
            Text {
                text: statsWidget.cpuUsage + "%"
                color: "#e0e0e0"
                font.family: statsWidget.fontFamily
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Memory Usage
        Row {
            spacing: 4
            
            Text {
                text: "\uf538"  // memory icon
                color: statsWidget.accentColor
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Rectangle {
                width: 50
                height: 8
                radius: 4
                color: "#333333"
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    width: statsWidget.memTotal > 0 ? parent.width * (statsWidget.memUsage / statsWidget.memTotal) : 0
                    height: parent.height
                    radius: 4
                    color: (statsWidget.memUsage / statsWidget.memTotal) > 0.8 ? "#ff6b6b" : statsWidget.accentColor
                    
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
            
            Text {
                text: Math.round(statsWidget.memUsage / 1024 * 10) / 10 + "G"
                color: "#e0e0e0"
                font.family: statsWidget.fontFamily
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
