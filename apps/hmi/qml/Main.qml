import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1280
    height: 720
    visible: true
    title: "ohayessOS"
    color: "#0b0f14"

    readonly property bool hasVehicleState: vehicleState.available

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 48
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            Label { text: "DRIVE BRIEF"; color: "#61d7ff"; font.pixelSize: 18; font.bold: true }
            Item { Layout.fillWidth: true }
            Label {
                text: hasVehicleState ? "LIVE" : "WAITING"
                color: hasVehicleState ? "#5eea9a" : "#ffcf70"
                font.pixelSize: 18
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: vehicleState.nightMode ? "#111b27" : "#172433"
            radius: 28

            RowLayout {
                anchors.fill: parent
                anchors.margins: 40

                ColumnLayout {
                    Layout.fillWidth: true
                    Label { text: "현재 속도"; color: "#a6b2c2"; font.pixelSize: 22 }
                    Label {
                        text: hasVehicleState ? Math.round(vehicleState.speedKph) : "—"
                        color: "#f1f5f9"
                        font.pixelSize: 152
                        font.weight: Font.DemiBold
                    }
                    Label { text: "km/h"; color: "#a6b2c2"; font.pixelSize: 28 }
                }

                Rectangle {
                    Layout.preferredWidth: 210
                    Layout.fillHeight: true
                    color: "#0b0f14"
                    radius: 20
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        Label { text: "GEAR"; color: "#a6b2c2"; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter }
                        Label {
                            text: hasVehicleState ? vehicleState.gear : "—"
                            color: "#61d7ff"
                            font.pixelSize: 88
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: hasVehicleState ? "Media: " + vehicleState.mediaPlaybackReason + " · Vehicle controls remain unavailable." : "Waiting for a fresh HmiState stream: " + vehicleState.streamPath
            color: "#a6b2c2"
            font.pixelSize: 18
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: ["Media", "Vehicle", "Diagnostics"]
                delegate: Button {
                    text: modelData
                    enabled: modelData === "Media" ? vehicleState.mediaPlaybackAllowed : modelData === "Diagnostics" ? vehicleState.diagnosticsAvailable : false
                    Layout.fillWidth: true
                    Layout.minimumHeight: 72
                }
            }
        }
    }
}
