import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1440
    height: 900
    visible: true
    title: "ohayessOS"
    color: "#070809"

    readonly property bool hasVehicleState: vehicleState.available
    readonly property color ink: "#f5f5f7"
    readonly property color muted: "#8b8f98"
    readonly property color surface: "#111214"
    readonly property color surfaceRaised: "#191a1d"
    property int page: 0

    component NavItem: Rectangle {
        required property string label
        required property int destination
        property bool available: true
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 16
        color: page === destination ? "#303238" : "transparent"
        opacity: available ? 1 : 0.36

        Text {
            anchors.centerIn: parent
            text: label
            color: page === destination ? ink : muted
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
        MouseArea {
            anchors.fill: parent
            enabled: available
            onClicked: page = destination
        }
    }

    component SectionTitle: Text {
        color: muted
        font.pixelSize: 15
        font.weight: Font.DemiBold
        font.letterSpacing: 1.6
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42

            Text {
                text: page === 0 ? "OAS" : "‹  OAS"
                color: ink
                font.pixelSize: 22
                font.weight: Font.DemiBold
                MouseArea { anchors.fill: parent; onClicked: page = 0 }
            }
            Text { text: page === 0 ? "DRIVE" : page === 1 ? "MEDIA" : "DIAGNOSTICS"; color: muted; font.pixelSize: 15; font.letterSpacing: 1.8 }
            Item { Layout.fillWidth: true }
            Rectangle { width: 8; height: 8; radius: 4; color: hasVehicleState ? "#49d17d" : "#e8b254" }
            Text { text: hasVehicleState ? "LIVE" : "WAITING"; color: hasVehicleState ? "#75dfa0" : "#e8b254"; font.pixelSize: 14; font.weight: Font.DemiBold }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: page

            Item {
                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    Rectangle {
                        Layout.preferredWidth: 318
                        Layout.fillHeight: true
                        radius: 28
                        color: surface

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 0
                            SectionTitle { text: "SPEED" }
                            Item { Layout.fillHeight: true }
                            Text { text: hasVehicleState ? Math.round(vehicleState.speedKph) : "—"; color: ink; font.pixelSize: 154; font.weight: Font.Light; Layout.alignment: Qt.AlignHCenter }
                            Text { text: "km/h"; color: muted; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                            Item { Layout.fillHeight: true }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#2a2c31" }
                            Item { Layout.preferredHeight: 22 }
                            SectionTitle { text: "RANGE" }
                            Text { text: "— km"; color: ink; font.pixelSize: 30; font.weight: Font.Light; Layout.topMargin: 6 }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 28
                        color: vehicleState.nightMode ? "#0d1116" : surface

                        Item {
                            anchors.fill: parent
                            anchors.margins: 42

                            SectionTitle { anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; text: "PALISADE · 2020" }

                            Item {
                                anchors.centerIn: parent
                                width: Math.min(parent.width * 0.72, 560)
                                height: 250

                                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; width: parent.width * 0.86; height: 76; radius: 38; color: "#d9dde3" }
                                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 57; width: parent.width * 0.56; height: 100; radius: 45; color: "#d9dde3" }
                                Rectangle { x: parent.width * 0.12; y: parent.height - 20; width: 68; height: 34; radius: 17; color: "#070809" }
                                Rectangle { x: parent.width * 0.72; y: parent.height - 20; width: 68; height: 34; radius: 17; color: "#070809" }
                                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 17; width: parent.width * 0.58; height: 2; color: "#8d939d" }
                            }

                            RowLayout {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                spacing: 28
                                Repeater {
                                    model: ["P", "R", "N", "D"]
                                    delegate: Text {
                                        required property string modelData
                                        text: modelData
                                        color: hasVehicleState && vehicleState.gear === modelData ? ink : "#555961"
                                        font.pixelSize: 26
                                        font.weight: hasVehicleState && vehicleState.gear === modelData ? Font.DemiBold : Font.Normal
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 318
                        Layout.fillHeight: true
                        radius: 28
                        color: surface

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 12
                            SectionTitle { text: "VEHICLE" }
                            Text { text: hasVehicleState ? "All systems normal" : "Awaiting vehicle state"; color: ink; font.pixelSize: 27; font.weight: Font.Light; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            Item { Layout.preferredHeight: 18 }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#2a2c31" }
                            Item { Layout.preferredHeight: 10 }
                            SectionTitle { text: "MEDIA" }
                            Text { text: vehicleState.mediaPlaybackAllowed ? "Available" : vehicleState.mediaPlaybackReason; color: vehicleState.mediaPlaybackAllowed ? "#75dfa0" : muted; font.pixelSize: 18; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            Item { Layout.fillHeight: true }
                            Text { text: "Read-only preview"; color: muted; font.pixelSize: 14 }
                        }
                    }
                }
            }

            Rectangle {
                radius: 28
                color: surface
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 48
                    spacing: 16
                    SectionTitle { text: "MEDIA" }
                    Text { text: vehicleState.mediaPlaybackAllowed ? "Playback is available" : "Playback is unavailable"; color: ink; font.pixelSize: 54; font.weight: Font.Light }
                    Text { text: vehicleState.mediaPlaybackAllowed ? "Select a source when a playback engine is installed." : "Runtime policy: " + vehicleState.mediaPlaybackReason; color: muted; font.pixelSize: 20 }
                    Item { Layout.fillHeight: true }
                    Text { text: "No playback engine is installed in this safety-focused preview."; color: muted; font.pixelSize: 16 }
                }
            }

            Rectangle {
                radius: 28
                color: surface
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 48
                    spacing: 16
                    SectionTitle { text: "DIAGNOSTICS" }
                    Text { text: vehicleState.diagnosticsAvailable ? "Vehicle signals" : "Diagnostics unavailable"; color: ink; font.pixelSize: 54; font.weight: Font.Light }
                    Text { text: vehicleState.diagnosticsSummary; color: muted; font.pixelSize: 20; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    Item { Layout.fillHeight: true }
                    Text { text: "Raw DBC values only. Never used for vehicle control or safety decisions."; color: "#e8b254"; font.pixelSize: 16 }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            radius: 22
            color: surfaceRaised
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                NavItem { label: "Drive"; destination: 0 }
                NavItem { label: "Media"; destination: 1; available: vehicleState.mediaPlaybackAllowed }
                NavItem { label: "Diagnostics"; destination: 2; available: vehicleState.diagnosticsAvailable }
            }
        }
    }
}
