import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 01 Home / Vehicle. Identity block, then the measured values as a grid, then
// the two things the driver acts on next.
Item {
    id: screen

    property var vehicle: null
    signal navigate(int destination)
    signal notify(string message, string iconName)

    readonly property var nav: Providers.navigation
    readonly property var climate: Providers.climate
    readonly property var energy: Providers.energy

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.hairline

        // ── Identity ──────────────────────────────────────────────────────
        GridBoard {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.breakpoint === "compact" ? 216 : 312
            columns: 2

            Cell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 3
                spacing: Tokens.s4

                Caption { text: "9NXR472" }

                Text {
                    text: "팰리세이드 2020"
                    color: Tokens.ink
                    font.pixelSize: Tokens.titleLg
                    font.weight: Tokens.weightDemi
                    font.letterSpacing: -0.5
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s8

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "기어" }
                        Text {
                            text: screen.vehicle && screen.vehicle.gearValid ? screen.vehicle.gear : "—"
                            color: Tokens.ink
                            font.pixelSize: Tokens.bodyLg
                            font.weight: Tokens.weightDemi
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "상태 스트림" }
                        Text {
                            text: screen.vehicle ? screen.vehicle.freshness : "—"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyLg
                            font.weight: Tokens.weightMedium
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "제어 권한" }
                        Text {
                            text: screen.vehicle && screen.vehicle.vehicleControlsAllowed ? "허용" : "없음"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyLg
                            font.weight: Tokens.weightMedium
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            Cell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.maximumWidth: Tokens.breakpoint === "compact" ? 260 : 420
                padding: 0

                VehicleVisual {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

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
            }
        }

        // ── Measured values ───────────────────────────────────────────────
        GridBoard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: Tokens.metricColumns

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "속도"
                value: Math.round(screen.vehicle ? screen.vehicle.speedKph : 0)
                unit: "km/h"
                valid: screen.vehicle ? screen.vehicle.speedValid : false
                valueSize: Tokens.dataLg

                BarSeries {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    values: [32, 54, 68, 80, 74, 80]
                    highlight: 3
                    visible: screen.vehicle && screen.vehicle.speedValid
                }
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "에너지"
                value: screen.energy.connected ? Math.round(screen.energy.level * 100) : ""
                unit: "%"
                valid: screen.energy.connected
                valueSize: Tokens.dataLg

                MeterBar {
                    Layout.fillWidth: true
                    value: screen.energy.connected ? screen.energy.level : 0
                    visible: screen.energy.connected
                }
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "주행 가능 거리"
                value: screen.energy.connected ? Math.round(screen.energy.rangeKm) : ""
                unit: "km"
                valid: screen.energy.connected
                valueSize: Tokens.dataLg
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "실내 온도"
                value: screen.climate.connected ? screen.climate.driverTemp.toFixed(1) : ""
                unit: "°C"
                delta: screen.climate.connected ? "동승석 " + screen.climate.passengerTemp.toFixed(1) : ""
                valid: screen.climate.connected
                valueSize: Tokens.dataLg
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "조향각"
                value: screen.vehicle && screen.vehicle.steeringValid
                    ? Math.round(screen.vehicle.steeringAngleDeg) + "°" : ""
                valid: screen.vehicle ? screen.vehicle.steeringValid : false
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "가속도"
                value: screen.vehicle && screen.vehicle.accelerationValid
                    ? screen.vehicle.accelerationMps2.toFixed(1) : ""
                unit: "m/s²"
                valid: screen.vehicle ? screen.vehicle.accelerationValid : false
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "크루즈"
                value: screen.vehicle && screen.vehicle.cruiseValid
                    ? (screen.vehicle.cruiseEnabled ? "작동" : "꺼짐") : ""
                valid: screen.vehicle ? screen.vehicle.cruiseValid : false
            }

            Metric {
                Layout.fillWidth: true; Layout.fillHeight: true
                label: "브레이크"
                value: screen.vehicle && screen.vehicle.brakeValid
                    ? (screen.vehicle.brakePressed ? "밟음" : "해제") : ""
                valid: screen.vehicle ? screen.vehicle.brakeValid : false
            }
        }

        // ── Next actions ──────────────────────────────────────────────────
        GridBoard {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.breakpoint === "compact" ? 150 : 172
            columns: 2

            Cell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.s3

                RowLayout {
                    Layout.fillWidth: true
                    Caption { text: "도어 · 안전벨트" }
                    Item { Layout.fillWidth: true }
                    StatusBadge {
                        text: screen.vehicle && screen.vehicle.doorsValid ? "신호 수신" : "신호 없음"
                        tone: screen.vehicle && screen.vehicle.doorsValid ? Tokens.success : Tokens.inkTertiary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s4

                    Text {
                        text: "도어"
                        Layout.preferredWidth: 72
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                    }

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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s4

                    Text {
                        text: "안전벨트"
                        Layout.preferredWidth: 72
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                    }

                    VehicleStatusIndicator {
                        Layout.fillWidth: true
                        items: {
                            const list = []
                            const belts = screen.vehicle ? screen.vehicle.seatbelts : []
                            for (let i = 0; i < belts.length; i++) {
                                list.push({ label: belts[i].label, valid: belts[i].valid,
                                            state: belts[i].latched ? "ok" : "critical" })
                            }
                            return list
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            Cell {
                id: nextTurn
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.s2
                Accessible.name: "내비게이션 열기"

                RowLayout {
                    Layout.fillWidth: true
                    Caption { text: "다음 안내" }
                    Icon { name: "chevronRight"; size: Tokens.iconSm; tone: Tokens.inkTertiary }
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
                    Layout.fillHeight: true
                    available: screen.nav.connected
                    turnIcon: screen.nav.nextTurnIcon
                    distanceM: screen.nav.nextTurnDistanceM
                    road: screen.nav.nextTurnRoad
                    detail: screen.nav.connected
                        ? "도착 " + screen.nav.eta + " · " + screen.nav.remainingKm.toFixed(1) + " km"
                        : ""
                }

                overlay: MouseArea { anchors.fill: parent; onClicked: screen.navigate(Nav.navigation) }
            }
        }
    }
}
