import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OAS.HMI

ApplicationWindow {
    id: window
    width: 1440; height: 810
    minimumWidth: 1280; minimumHeight: 720
    visible: true
    title: "OAS · Calm Future Mobility"
    color: Theme.background
    property int page: 0
    readonly property bool hasState: vehicleState.available
    readonly property string connection: vehicleState.freshness === "fresh" ? "Connected" : vehicleState.freshness === "stale" ? "Update delayed" : "Waiting for connection"
    readonly property color stateColor: vehicleState.freshness === "fresh" ? Theme.success : Theme.warning

    Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: Theme.horizon } GradientStop { position: 1; color: Theme.background } } }

    component Caption: Text { color: Theme.muted; font.pixelSize: 12; font.letterSpacing: 2; font.weight: Font.Medium }
    component Body: Text { color: Theme.muted; font.pixelSize: 16; wrapMode: Text.WordWrap; Layout.fillWidth: true }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 32; spacing: 24
        RowLayout {
            Layout.fillWidth: true; Layout.preferredHeight: 42; spacing: 20
            Text { text: "o a s"; color: Theme.text; font.pixelSize: 27; font.weight: Font.Medium }
            Rectangle { width: 1; height: 20; color: Theme.border }
            Caption { text: "CALM FUTURE MOBILITY" }
            Item { Layout.fillWidth: true }
            StatusPill { text: vehicleState.demo ? "DEMO · SYNTHETIC" : "READ ONLY"; tone: Theme.cyan }
            Text { text: connection; color: stateColor; font.pixelSize: 14 }
        }

        StackLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; currentIndex: page
            Item {
                RowLayout {
                    anchors.fill: parent; spacing: 24
                    ColumnLayout {
                        Layout.minimumWidth: 240; Layout.maximumWidth: 240; Layout.preferredWidth: 240; Layout.fillHeight: true; spacing: 16
                        Caption { text: "YOUR DRIVE" }
                        Text { text: hasState ? "In the moment." : "Ready when you are."; color: Theme.text; font.pixelSize: 27; font.weight: Font.Light; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                        Text { text: hasState ? Math.round(vehicleState.speedKph) : "—"; color: Theme.text; font.pixelSize: 136; font.weight: Font.Light; font.letterSpacing: -7 }
                        Caption { text: "KILOMETRES / HOUR" }
                        Item { Layout.preferredHeight: 12 }
                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: ["P", "R", "N", "D"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 46; height: 46; radius: 15
                                    color: hasState && vehicleState.gear === modelData ? "#264251" : "transparent"
                                    border.color: hasState && vehicleState.gear === modelData ? "#467586" : "transparent"
                                    Text { anchors.centerIn: parent; text: modelData; color: hasState && vehicleState.gear === modelData ? Theme.cyan : Theme.muted; font.pixelSize: 21 }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                        Caption { text: "PALISADE / 2020" }
                        Body { text: "A quieter connection\nto your journey." }
                    }

                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        Column {
                            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; spacing: 12
                            Caption { text: "VEHICLE OVERVIEW"; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "Room to breathe."; color: Theme.text; font.pixelSize: 34; font.weight: Font.Light; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                        VehicleVisual { anchors.centerIn: parent; anchors.verticalCenterOffset: 10; width: parent.width; height: Math.min(parent.height - 120, width * 0.78) }
                        Column {
                            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                            StatusPill { anchors.horizontalCenter: parent.horizontalCenter; text: vehicleState.freshness === "fresh" ? "STATE RECEIVED" : vehicleState.freshness === "stale" ? "SIGNAL STALE" : "AWAITING SIGNAL"; tone: stateColor }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Concept illustration · surroundings are not sensed"; color: Theme.muted; font.pixelSize: 11 }
                        }
                    }

                    ColumnLayout {
                        Layout.minimumWidth: 288; Layout.maximumWidth: 288; Layout.preferredWidth: 288; Layout.fillHeight: true; spacing: 16
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "CONNECTION" }
                                Text { text: connection; color: Theme.text; font.pixelSize: 25; font.weight: Font.Light; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                Body { text: vehicleState.freshness === "fresh" ? "Vehicle data is available.\nControls remain read-only." : "Driving values stay hidden until fresh data arrives." }
                                Item { Layout.fillHeight: true }
                                StatusPill { text: "VEHICLE CONTROL OFF"; tone: Theme.muted }
                            }
                        }
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "MEDIA / VIDEO" }
                                Text { text: vehicleState.mediaPlaybackAllowed ? "Make yourself\nat home." : "Enjoy the\njourney."; color: Theme.text; font.pixelSize: 29; font.weight: Font.Light }
                                Body { text: Theme.reason(vehicleState.mediaPlaybackReason) }
                                Item { Layout.fillHeight: true }
                                StatusPill { text: vehicleState.mediaPlaybackAllowed ? "PERMITTED · NO PLAYER" : "PLAYBACK UNAVAILABLE"; tone: vehicleState.mediaPlaybackAllowed ? Theme.cyan : Theme.muted }
                            }
                        }
                    }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "YOUR SPACE / MEDIA" }
                    Text { text: "A pause in the journey."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: vehicleState.mediaPlaybackAllowed ? "PERMISSION GRANTED" : "PLAYBACK LOCKED"; tone: vehicleState.mediaPlaybackAllowed ? Theme.success : Theme.warning }
                    Body { text: Theme.reason(vehicleState.mediaPlaybackReason) }
                    Item { Layout.fillHeight: true }
                    Body { text: "No media player is installed. Playback and audio controls will appear when a source is connected." }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "VEHICLE / SIGNALS" }
                    Text { text: "A closer look."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: vehicleState.diagnosticsAvailable ? "READ-ONLY DBC SIGNALS" : "SIGNALS UNAVAILABLE"; tone: vehicleState.diagnosticsAvailable ? Theme.cyan : Theme.warning }
                    Body { text: vehicleState.diagnosticsAvailable ? vehicleState.diagnosticsSummary : "Fresh vehicle data is needed to display signal values."; font.pixelSize: 23 }
                    Item { Layout.fillHeight: true }
                    Body { text: "Raw DBC values. These readings do not indicate vehicle health and are not used for vehicle control." }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "PALISADE / 2020" }
                    Text { text: "Connected. Read-only."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: "VEHICLE CONTROLS UNAVAILABLE"; tone: Theme.muted }
                    Body { text: "This installation displays vehicle information. Climate, locks, steering and driving controls are not connected." }
                    Item { Layout.fillHeight: true }
                    Body { text: "Range, fuel level and cabin temperature are not available in the current display contract." }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 24
            Caption { text: "OAS / 01"; Layout.preferredWidth: 160 }
            NavDock { Layout.fillWidth: true; Layout.preferredHeight: 76; selected: page; onNavigate: function(destination) { page = destination } }
            Text { text: "READ-ONLY\nVEHICLE PLATFORM"; color: Theme.muted; font.pixelSize: 11; font.letterSpacing: 1.2; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 160 }
        }
    }
}
