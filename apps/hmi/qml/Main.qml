import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1280
    height: 720
    visible: true
    title: "ohayessOS"
    color: "#0b0f14"

    // VehicleStateBridge owns decoding the length-prefixed protobuf stream.
    // Until the platform adapter is installed, the production HMI stays empty.
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 48
        spacing: 24

        Label { text: "DRIVE BRIEF"; color: "#61d7ff"; font.pixelSize: 18 }
        Label { text: "Vehicle state unavailable"; color: "#f1f5f9"; font.pixelSize: 48 }
        Label {
            text: "A trusted VehicleState stream is required before driving data is displayed."
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
