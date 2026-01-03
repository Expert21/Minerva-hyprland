import Quickshell
import Quickshell.Io
import QtQuick

// Weather Widget - wttr.in for Sherman, TX
Item {
    id: weatherWidget
    implicitWidth: weatherRow.implicitWidth
    implicitHeight: parent.height

    property color accentColor: "#bd93f9"
    property string fontFamily: "Sans Serif"
    
    property string temperature: "--"
    property string condition: ""
    property string icon: "\uf185"  // default sun

    // Weather icon mapping
    property var weatherIcons: {
        "Clear": "\uf185",           // sun
        "Sunny": "\uf185",           // sun
        "Partly cloudy": "\uf6c4",   // cloud-sun
        "Cloudy": "\uf0c2",          // cloud
        "Overcast": "\uf0c2",        // cloud
        "Mist": "\uf75f",            // smog
        "Fog": "\uf75f",             // smog
        "Rain": "\uf73d",            // cloud-rain
        "Light rain": "\uf73d",      // cloud-rain
        "Heavy rain": "\uf740",      // cloud-showers-heavy
        "Thunderstorm": "\uf76c",    // bolt
        "Snow": "\uf2dc",            // snowflake
        "Light snow": "\uf2dc",      // snowflake
        "Heavy snow": "\uf2dc"       // snowflake
    }

    Process {
        id: weatherProc
        command: ["/bin/sh", "-c", "curl -s 'wttr.in/Sherman+TX?format=%t|%C' 2>/dev/null"]
        stdout: StdioCollector {
            onTextChanged: {
                if (text.trim() !== "" && !text.includes("Unknown")) {
                    var parts = text.trim().split("|")
                    if (parts.length >= 2) {
                        weatherWidget.temperature = parts[0].replace("+", "")
                        weatherWidget.condition = parts[1]
                        
                        // Find matching icon
                        for (var key in weatherWidget.weatherIcons) {
                            if (parts[1].toLowerCase().includes(key.toLowerCase())) {
                                weatherWidget.icon = weatherWidget.weatherIcons[key]
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 600000  // Update every 10 minutes
        running: true
        repeat: true
        onTriggered: {
            weatherProc.running = false
            weatherProc.running = true
        }
        Component.onCompleted: weatherProc.running = true
    }

    Row {
        id: weatherRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        
        Text {
            text: weatherWidget.icon
            color: weatherWidget.accentColor
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: weatherWidget.temperature
            color: "#e0e0e0"
            font.family: weatherWidget.fontFamily
            font.bold: true
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
