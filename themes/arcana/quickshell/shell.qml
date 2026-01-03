import Quickshell
import Quickshell.Wayland
import QtQuick

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
