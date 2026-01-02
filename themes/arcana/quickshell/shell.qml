import Quickshell
import Quickshell.Wayland
import QtQuick
import "../shared"

ShellRoot {
    id: root
    property bool wallpaperVisible: false

    // Arcana Mode Shell
    TopBar {
        onWallpaperToggle: root.wallpaperVisible = !root.wallpaperVisible
    }
    Dock {}
    
    WallpaperWidget {
        themeMode: "arcana"
        visible: root.wallpaperVisible
    }
}
