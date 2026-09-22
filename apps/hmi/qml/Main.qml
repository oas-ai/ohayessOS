import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1280
    height: 720
    visible: true
    title: "ohayessOS"
    color: "#0b0f14"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 48
        spacing: 24

        Label { text: "DRIVE BRIEF"; color: "#61d7ff"; font.pixelSize: 18 }
        Label {
            text: vehicleState.available ? Math.round(vehicleState.speedKph) + " km/h" : "Vehicle state unavailable"
            color: "#f1f5f9"
            font.pixelSize: 48
        }
        Label {
            text: vehicleState.available ? "Gear " + vehicleState.gear : "Waiting for " + vehicleState.streamPath
            color: "#a6b2c2"
            font.pixelSize: 22
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: ["Media", "Vehicle", "Diagnostics"]
                delegate: Button { text: modelData; enabled: false; Layout.fillWidth: true }
            }
        }
    }
}
