import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Panel {
    id: dock
    anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
    }
    width: layout.implicitWidth + 40
    height: 64
    color: "transparent"

    // Font Awesome loader
    FontLoader {
        id: fontAwesome
        source: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-solid-900.woff2"
    }

    // Helper component for dock items
    component DockItem: Rectangle {
        id: dockBtn
        width: 48; height: 48; radius: 8
        color: "transparent"
        border.color: itemHover.hovered ? "#bd93f9" : "transparent"
        border.width: 2
        
        property string icon: ""
        property string command: ""
        
        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: itemHover.hovered ? "#bd93f9" : "#f8f8f2"
            font.family: fontAwesome.name
            font.pixelSize: 22
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
        radius: 16
        
        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 16
            
            DockItem { icon: "\uf120"; command: "kitty" }           // Terminal
            DockItem { icon: "\uf0ac"; command: "firefox" }         // Globe/Browser
            DockItem { icon: "\uf07b"; command: "thunar" }          // Folder/Files
            DockItem { icon: "\uf1bc"; command: "spotify" }         // Spotify
            DockItem { icon: "\uf302"; command: "discord" }         // Discord
        }
    }
}
