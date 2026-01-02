import Quickshell
import Quickshell.Wayland
import QtQuick
import "../shared"

ShellRoot {
    id: root
    property bool cmdVisible: false
    property bool wallpaperVisible: false

    // Ghost Mode Shell
    StatusBar {
        onToggleCommandCenter: root.cmdVisible = !root.cmdVisible
        onWallpaperToggle: root.wallpaperVisible = !root.wallpaperVisible
    }
    
    CommandCenter {
        visible: root.cmdVisible
    }
    
    WallpaperWidget {
        themeMode: "ghost"
        visible: root.wallpaperVisible
    }
}
