import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Reusable theme-aware wallpaper selector widget with Local + Wallpaper Engine support
Panel {
    id: wallpaperWidget
    anchors.centerIn: parent
    width: 750
    height: 550
    color: "transparent"
    visible: false

    // Theme mode determines which wallpaper directory to use
    property string themeMode: "arcana"
    property string wallpaperDir: "/home/isaiah/hyprland rice/wallpapers/" + themeMode
    property string weDir: Qt.resolvedUrl("file://" + Qt.application.arguments[0]).toString().startsWith("file://") 
        ? "/home/isaiah/.local/share/Steam/steamapps/workshop/content/431960" 
        : "/home/isaiah/.local/share/Steam/steamapps/workshop/content/431960"
    
    property var localWallpapers: []
    property var weWallpapers: []  // Array of {id, title, preview}
    property int activeTab: 0  // 0 = Local, 1 = Wallpaper Engine

    // Color scheme based on theme
    property color accentColor: themeMode === "ghost" ? "#00ff00" : "#bd93f9"
    property color bgColor: themeMode === "ghost" ? "#e6050505" : "#e61a1025"
    property string fontFamily: themeMode === "ghost" ? "Monospace" : "Sans Serif"

    Keys.onEscapePressed: wallpaperWidget.visible = false
    focus: visible

    // Scan local wallpaper directory
    Process {
        id: scanLocalProc
        command: ["/bin/sh", "-c", "ls -1 '" + wallpaperDir + "' 2>/dev/null"]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    wallpaperWidget.localWallpapers = content.trim().split("\n")
                }
            }
        }
    }

    // Scan Wallpaper Engine directory and parse project.json for each
    Process {
        id: scanWeProc
        command: ["/bin/sh", "-c", 
            "for dir in " + weDir + "/*/; do " +
            "  id=$(basename \"$dir\"); " +
            "  if [ -f \"$dir/project.json\" ]; then " +
            "    title=$(cat \"$dir/project.json\" | grep -o '\"title\"[[:space:]]*:[[:space:]]*\"[^\"]*\"' | head -1 | sed 's/.*\"title\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/'); " +
            "    preview=$(cat \"$dir/project.json\" | grep -o '\"preview\"[[:space:]]*:[[:space:]]*\"[^\"]*\"' | head -1 | sed 's/.*\"preview\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/'); " +
            "    echo \"$id|$title|$preview\"; " +
            "  fi; " +
            "done"
        ]
        stdout: StdioCollector {
            onContentChanged: {
                if (content.trim() !== "") {
                    var lines = content.trim().split("\n")
                    var items = []
                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split("|")
                        if (parts.length >= 3) {
                            items.push({
                                id: parts[0],
                                title: parts[1] || parts[0],
                                preview: parts[2] || "preview.jpg"
                            })
                        }
                    }
                    wallpaperWidget.weWallpapers = items
                }
            }
        }
    }

    // Apply local wallpaper
    Process {
        id: applyLocalProc
        property string selectedWallpaper: ""
        command: {
            var ext = selectedWallpaper.split('.').pop().toLowerCase()
            var fullPath = wallpaperDir + "/" + selectedWallpaper
            if (["mp4", "webm", "mkv", "gif"].includes(ext)) {
                return ["mpvpaper", "-o", "loop", "*", fullPath]
            } else {
                return ["swww", "img", fullPath, "--transition-type", "fade"]
            }
        }
    }

    // Apply Wallpaper Engine wallpaper
    Process {
        id: applyWeProc
        property string workshopId: ""
        command: ["/home/isaiah/hyprland rice/scripts/apply_we_wallpaper.sh", workshopId]
    }

    onVisibleChanged: {
        if (visible) {
            scanLocalProc.running = true
            scanWeProc.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: bgColor
        border.color: accentColor
        border.width: 2
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Tab Bar
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                component TabButton: Rectangle {
                    property string label: ""
                    property bool active: false
                    width: 150
                    height: 36
                    color: active ? accentColor : "transparent"
                    border.color: accentColor
                    border.width: 1
                    radius: active ? 8 : 0

                    Text {
                        anchors.centerIn: parent
                        text: parent.label
                        color: parent.active ? (themeMode === "ghost" ? "#000000" : "#1a1025") : accentColor
                        font.family: fontFamily
                        font.bold: true
                        font.pixelSize: 14
                    }

                    HoverHandler { id: tabHover }
                    TapHandler {
                        onTapped: {
                            if (label === "LOCAL") activeTab = 0
                            else activeTab = 1
                        }
                    }

                    opacity: tabHover.hovered && !active ? 0.7 : 1.0
                }

                TabButton { label: "LOCAL"; active: activeTab === 0 }
                TabButton { label: "WALLPAPER ENGINE"; active: activeTab === 1 }
            }

            // Content Area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Local Wallpapers Grid
                GridView {
                    id: localGrid
                    anchors.fill: parent
                    visible: activeTab === 0
                    cellWidth: 160
                    cellHeight: 120
                    clip: true
                    model: localWallpapers

                    delegate: Rectangle {
                        width: 150
                        height: 110
                        color: "transparent"
                        border.color: localHover.hovered ? accentColor : "#333333"
                        border.width: 2
                        radius: 8

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: "file://" + wallpaperDir + "/" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true

                            Rectangle {
                                visible: ["mp4", "webm", "mkv", "gif"].includes(modelData.split('.').pop().toLowerCase())
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.margins: 4
                                width: 24; height: 24; radius: 4
                                color: "#80000000"
                                Text { anchors.centerIn: parent; text: "▶"; color: "white"; font.pixelSize: 12 }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 20
                            color: "#cc000000"
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: modelData.length > 18 ? modelData.substring(0, 15) + "..." : modelData
                                color: accentColor
                                font.pixelSize: 10
                                font.family: fontFamily
                            }
                        }

                        HoverHandler { id: localHover }
                        TapHandler {
                            onTapped: {
                                applyLocalProc.selectedWallpaper = modelData
                                applyLocalProc.running = true
                                wallpaperWidget.visible = false
                            }
                        }
                        scale: localHover.hovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }
                }

                // Wallpaper Engine Grid
                GridView {
                    id: weGrid
                    anchors.fill: parent
                    visible: activeTab === 1
                    cellWidth: 160
                    cellHeight: 130
                    clip: true
                    model: weWallpapers

                    delegate: Rectangle {
                        width: 150
                        height: 120
                        color: "transparent"
                        border.color: weHover.hovered ? accentColor : "#333333"
                        border.width: 2
                        radius: 8

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: "file://" + weDir + "/" + modelData.id + "/" + modelData.preview
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true

                            // WE badge
                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 4
                                width: 24; height: 16; radius: 3
                                color: "#ff6600"
                                Text {
                                    anchors.centerIn: parent
                                    text: "WE"
                                    color: "white"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 24
                            color: "#cc000000"
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: modelData.title.length > 16 ? modelData.title.substring(0, 14) + "..." : modelData.title
                                color: accentColor
                                font.pixelSize: 10
                                font.family: fontFamily
                            }
                        }

                        HoverHandler { id: weHover }
                        TapHandler {
                            onTapped: {
                                applyWeProc.workshopId = modelData.id
                                applyWeProc.running = true
                                wallpaperWidget.visible = false
                            }
                        }
                        scale: weHover.hovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }
                }

                // Empty state for WE tab
                Text {
                    anchors.centerIn: parent
                    visible: activeTab === 1 && weWallpapers.length === 0
                    text: "No Wallpaper Engine wallpapers found.\nCheck: ~/.local/share/Steam/steamapps/workshop/content/431960/"
                    color: "#666666"
                    font.family: fontFamily
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Hint
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: activeTab === 0 ? "CLICK TO APPLY • ESC TO CLOSE" : "CLICK TO APPLY WE WALLPAPER • ESC TO CLOSE"
                color: "#555555"
                font.family: fontFamily
                font.pixelSize: 10
            }
        }
    }
}

