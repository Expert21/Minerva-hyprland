import Quickshell
import Quickshell.Wayland
import QtQuick
import "../shared"

ShellRoot {
    id: root
    property bool wallpaperVisible: false

    // Ghost Mode Shell - TopBar at top, PentestDock on right
    TopBar {}
    
    PentestDock {}
    
    WallpaperWidget {
        themeMode: "ghost"
        visible: root.wallpaperVisible
    }
}
