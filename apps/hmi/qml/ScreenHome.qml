import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 01 Home / Vehicle. Left column holds driving data nearest the driver, the
// stage holds the vehicle state surface, the right column holds next actions.
Item {
    id: screen

    property var vehicle: null
    signal navigate(int destination)
    signal notify(string message, string iconName)

    readonly property var nav: Providers.navigation
    readonly property var climate: Providers.climate
    readonly property var media: Providers.media
    readonly property var energy: Providers.energy

    component GearStrip: Row {
        id: strip
        property string gear: "—"
        property bool valid: false
        spacing: Tokens.s4

        Repeater {
            model: ["P", "R", "N", "D"]
            delegate: Text {
                required property string modelData
                readonly property bool on: strip.valid && strip.gear === modelData
                text: modelData
                color: on ? Tokens.accent : Tokens.textTertiary
                font.pixelSize: Tokens.bodyLg
                font.weight: on ? Tokens.weightDemi : Tokens.weightRegular
                Behavior on color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.gutter

        // ── Driving data ──────────────────────────────────────────────────
        ColumnLayout {
            visible: Tokens.showSideColumns
            Layout.preferredWidth: Tokens.sideColumn
            Layout.maximumWidth: Tokens.sideColumn
            Layout.fillHeight: true
            spacing: Tokens.gutter

            Panel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 360

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.s5
                    spacing: Tokens.s3

                    Caption { text: "주행" }

                    Readout {
                        value: Math.round(screen.vehicle ? screen.vehicle.speedKph : 0)
                        unit: "km/h"
                        valid: screen.vehicle ? screen.vehicle.speedValid : false
                        valueSize: Tokens.speedLarge
                    }

                    GearStrip {
                        Layout.topMargin: Tokens.s2
                        gear: screen.vehicle ? screen.vehicle.gear : "—"
                        valid: screen.vehicle ? screen.vehicle.gearValid : false
                    }

                    Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

                    Readout {
                        label: "가속"
                        value: screen.vehicle && screen.vehicle.accelerationValid
                            ? screen.vehicle.accelerationMps2.toFixed(1) : ""
                        unit: "m/s²"
                        valid: screen.vehicle ? screen.vehicle.accelerationValid : false
                        valueSize: Tokens.titleSection
                    }

                    Readout {
                        label: "조향"
                        value: screen.vehicle && screen.vehicle.steeringValid
                            ? Math.round(screen.vehicle.steeringAngleDeg) + "°" : ""
                        valid: screen.vehicle ? screen.vehicle.steeringValid : false
                        valueSize: Tokens.titleSection
                    }

                    Item { Layout.fillHeight: true }

                    StatusBadge {
                        text: screen.vehicle && screen.vehicle.cruiseValid && screen.vehicle.cruiseEnabled
                            ? "크루즈 작동 중" : "크루즈 꺼짐"
                        tone: screen.vehicle && screen.vehicle.cruiseValid && screen.vehicle.cruiseEnabled
                            ? Tokens.accent : Tokens.textTertiary
                    }
                }
            }

            Panel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 220

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.s5
                    spacing: Tokens.s3

                    Caption { text: "에너지" }

                    Readout {
                        value: screen.energy.connected ? Math.round(screen.energy.level * 100) : ""
                        unit: "%"
                        valid: screen.energy.connected
                        valueSize: Tokens.displaySm
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        radius: 5
                        color: Tokens.surfaceAlt

                        Rectangle {
                            width: parent.width * (screen.energy.connected ? screen.energy.level : 0)
                            height: parent.height
                            radius: parent.radius
                            color: Tokens.accent
                            Behavior on width { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                        }
                    }

                    Text {
                        text: screen.energy.connected
                            ? "주행 가능 " + Math.round(screen.energy.rangeKm) + " km"
                            : "에너지 공급자 연결 전"
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }

        // ── Vehicle state surface ─────────────────────────────────────────
        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 420
            Layout.preferredWidth: 640

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s3

                // Compact folds the driving readout into the stage header.
                RowLayout {
                    visible: !Tokens.showSideColumns
                    Layout.fillWidth: true
                    spacing: Tokens.s5

                    Readout {
                        value: Math.round(screen.vehicle ? screen.vehicle.speedKph : 0)
                        unit: "km/h"
                        valid: screen.vehicle ? screen.vehicle.speedValid : false
                        valueSize: Tokens.displayMd
                    }

                    Item { Layout.fillWidth: true }

                    GearStrip {
                        gear: screen.vehicle ? screen.vehicle.gear : "—"
                        valid: screen.vehicle ? screen.vehicle.gearValid : false
                    }
                }

                RowLayout {
                    visible: Tokens.showSideColumns
                    Layout.fillWidth: true

                    Caption { text: "차량 상태" }
                    Item { Layout.fillWidth: true }
                    StatusBadge {
                        text: screen.vehicle && screen.vehicle.doorsValid ? "도어 신호 수신" : "도어 신호 없음"
                        tone: screen.vehicle && screen.vehicle.doorsValid ? Tokens.success : Tokens.textTertiary
                    }
                }

                VehicleVisual {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 200

                    gear: screen.vehicle ? screen.vehicle.gear : "—"
                    gearValid: screen.vehicle ? screen.vehicle.gearValid : false
                    speedKph: screen.vehicle ? screen.vehicle.speedKph : 0
                    speedValid: screen.vehicle ? screen.vehicle.speedValid : false
                    steeringAngleDeg: screen.vehicle ? screen.vehicle.steeringAngleDeg : 0
                    steeringValid: screen.vehicle ? screen.vehicle.steeringValid : false
                    doors: screen.vehicle ? screen.vehicle.doors : []
                    doorsValid: screen.vehicle ? screen.vehicle.doorsValid : false
                    seatbelts: screen.vehicle ? screen.vehicle.seatbelts : []
                    seatbeltsValid: screen.vehicle ? screen.vehicle.seatbeltsValid : false
                    lightsOn: Providers.lights.lit
                    turnSignal: Providers.lights.turnSignal
                    charging: screen.energy.connected && screen.energy.charging
                }

                Divider { Layout.fillWidth: true }

                VehicleStatusIndicator {
                    Layout.fillWidth: true
                    items: {
                        const list = []
                        const doors = screen.vehicle ? screen.vehicle.doors : []
                        for (let i = 0; i < doors.length; i++) {
                            list.push({ label: doors[i].label, valid: doors[i].valid,
                                        state: doors[i].open ? "open" : "ok" })
                        }
                        return list
                    }
                }
            }
        }

        // ── Persistent map on ultra-wide displays ─────────────────────────
        MapSurface {
            visible: Tokens.showPersistentMap
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 960
            available: screen.nav.connected
            routeActive: screen.nav.routeActive
            traffic: screen.nav.traffic
        }

        // ── Next actions ──────────────────────────────────────────────────
        ColumnLayout {
            Layout.preferredWidth: Tokens.sideColumn
            Layout.maximumWidth: Tokens.sideColumn
            Layout.fillHeight: true
            spacing: Tokens.gutter

            Panel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 260

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.s5
                    spacing: Tokens.s3

                    RowLayout {
                        Layout.fillWidth: true
                        Caption { text: "다음 안내" }
                        Item { Layout.fillWidth: true }
                        StatusBadge {
                            visible: screen.nav.connected
                            text: screen.nav.traffic === "heavy" ? "정체" : screen.nav.traffic === "moderate" ? "서행" : "원활"
                            tone: screen.nav.traffic === "heavy" ? Tokens.critical
                                : screen.nav.traffic === "moderate" ? Tokens.warning : Tokens.success
                        }
                    }

                    NavInstruction {
                        Layout.fillWidth: true
                        available: screen.nav.connected
                        turnIcon: screen.nav.nextTurnIcon
                        distanceM: screen.nav.nextTurnDistanceM
                        road: screen.nav.nextTurnRoad
                        detail: screen.nav.nextTurnDetail
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        visible: screen.nav.connected
                        Layout.fillWidth: true
                        spacing: Tokens.s4

                        Readout { label: "도착"; value: screen.nav.eta; valueSize: Tokens.titleSection }
                        Readout { label: "남은 거리"; value: screen.nav.remainingKm.toFixed(1); unit: "km"; valueSize: Tokens.titleSection }
                        Item { Layout.fillWidth: true }
                    }

                    OasButton {
                        Layout.fillWidth: true
                        text: "내비게이션 열기"
                        iconName: "navigation"
                        onClicked: screen.navigate(Nav.navigation)
                    }
                }
            }

            Panel {
                visible: Tokens.showSideColumns
                Layout.fillWidth: true
                Layout.preferredHeight: 156

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.s5
                    spacing: Tokens.s2

                    Caption { text: "미디어" }

                    MediaMiniPlayer {
                        Layout.fillWidth: true
                        available: screen.media.connected && (screen.vehicle ? screen.vehicle.mediaPlaybackAllowed : false)
                        lockReason: screen.vehicle ? Tokens.playbackReason(screen.vehicle.mediaPlaybackReason) : ""
                        track: screen.media.track
                        artist: screen.media.artist
                        playing: screen.media.playing
                        onToggled: {
                            screen.media.playing = !screen.media.playing
                            screen.notify(screen.media.playing ? "재생" : "일시정지", screen.media.playing ? "play" : "pause")
                        }
                        onExpand: screen.navigate(Nav.media)
                        onPrevious: screen.notify("이전 곡", "prev")
                        onNext: screen.notify("다음 곡", "next")
                    }
                }
            }

            Panel {
                Layout.fillWidth: true
                Layout.preferredHeight: 176

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.s5
                    spacing: Tokens.s3

                    Caption { text: "공조" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.s4

                        Readout {
                            label: "운전석"
                            value: screen.climate.driverTemp.toFixed(1)
                            unit: "°C"
                            valid: screen.climate.connected
                            valueSize: Tokens.titleSection
                        }

                        Item { Layout.fillWidth: true }

                        Readout {
                            label: "동승석"
                            value: screen.climate.passengerTemp.toFixed(1)
                            unit: "°C"
                            valid: screen.climate.connected
                            valueSize: Tokens.titleSection
                        }
                    }

                    Item { Layout.fillHeight: true }

                    OasButton {
                        Layout.fillWidth: true
                        text: "공조 열기"
                        iconName: "climate"
                        variant: "ghost"
                        onClicked: screen.navigate(Nav.climate)
                    }
                }
            }
        }
    }
}
