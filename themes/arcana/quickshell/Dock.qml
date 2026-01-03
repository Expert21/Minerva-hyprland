import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Arcana Dock - Left side vertical layout
Panel {
    id: dock
    anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
    }
    topMargin: 44
    bottomMargin: 8
    leftMargin: 8
    width: 56
    color: "transparent"

    // Font Awesome loader
    FontLoader {
        id: fontAwesome
        source: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-solid-900.woff2"
    }

    // Helper component for dock items
    component DockItem: Rectangle {
        id: dockBtn
        width: 44; height: 44; radius: 8
        color: itemHover.hovered ? "#bd93f922" : "transparent"
        border.color: itemHover.hovered ? "#bd93f9" : "transparent"
        border.width: 2
        
        property string icon: ""
        property string command: ""
        property string tooltip: ""
        
        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: itemHover.hovered ? "#bd93f9" : "#f8f8f2"
            font.family: fontAwesome.name
            font.pixelSize: 20
        }
        
        HoverHandler { id: itemHover }
        
        Process {
            id: launcher
            command: ["/bin/sh", "-c", dockBtn.command]
        }
        
        TapHandler {
            onTapped: launcher.running = true
        }
        
        // Hover scale animation
        scale: itemHover.hovered ? 1.1 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    Rectangle {
        anchors.fill: parent
        color: "#cc1a1025"
        border.color: "#bd93f9"
        border.width: 1
        radius: 12
        
        ColumnLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 8
            
            DockItem { icon: "\uf120"; command: "kitty"; tooltip: "Terminal" }
            DockItem { icon: "\uf0ac"; command: "firefox"; tooltip: "Browser" }
            DockItem { icon: "\uf07b"; command: "kitty -e ranger"; tooltip: "Files" }
            DockItem { icon: "\uf1bc"; command: "spotify"; tooltip: "Spotify" }
            DockItem { icon: "\uf302"; command: "discord"; tooltip: "Discord" }
            
            // Separator
            Rectangle { width: 32; height: 1; color: "#bd93f944"; Layout.alignment: Qt.AlignHCenter }
            
            DockItem { icon: "\uf085"; command: "~/.config/hypr/scripts/switch-mode.sh"; tooltip: "Ghost Mode" }
        }
    }
}

