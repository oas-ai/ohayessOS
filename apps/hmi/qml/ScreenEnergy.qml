import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 07 Energy.
Item {
    id: screen

    property var vehicle: null
    signal notify(string message, string iconName)

    readonly property var energy: Providers.energy
    readonly property var tires: Providers.tires

    EmptyState {
        anchors.centerIn: parent
        width: Math.min(parent.width - Tokens.s8, 480)
        visible: !screen.energy.connected
        iconName: "battery"
        title: "에너지 공급자 연결 전"
        detail: "배터리 잔량, 주행 가능 거리, 전비와 충전 상태는 에너지 데이터가 연결되면 표시됩니다."
        badge: "잔량 데이터 없음"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.hairline
        visible: screen.energy.connected

        GridBoard {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.breakpoint === "compact" ? 200 : 240
            columns: 1

            Cell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.s4

                RowLayout {
                    Layout.fillWidth: true
                    Caption { text: screen.energy.kind === "battery" ? "고전압 배터리" : "연료" }
                    Item { Layout.fillWidth: true }
                    StatusBadge {
                        text: screen.energy.charging ? "충전 중" : "충전 안 함"
                        tone: screen.energy.charging ? Tokens.success : Tokens.inkTertiary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s8

                    Row {
                        spacing: Tokens.s2

                        Text {
                            id: levelValue
                            text: Math.round(screen.energy.level * 100)
                            color: Tokens.ink
                            font.pixelSize: Tokens.dataHero
                            font.weight: Tokens.weightDemi
                            font.letterSpacing: -3
                        }

                        Text {
                            anchors.baseline: levelValue.baseline
                            text: "%"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.titleLg
                            font.weight: Tokens.weightMedium
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: Tokens.s4

                        Caption { text: "주행 가능" }
                        Text {
                            text: Math.round(screen.energy.rangeKm) + " km"
                            color: Tokens.ink
                            font.pixelSize: Tokens.titleLg
                            font.weight: Tokens.weightDemi
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: Tokens.s4

                        Caption { text: "총 용량" }
                        Text {
                            text: screen.energy.capacityKwh.toFixed(1) + " kWh"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.titleLg
                            font.weight: Tokens.weightMedium
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                MeterBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    value: screen.energy.level
                    target: 0.8
                }
            }
        }

        GridBoard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: Tokens.breakpoint === "compact" ? 2 : 3

            Repeater {
                model: screen.energy.recent

                delegate: Metric {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: modelData.label
                    value: modelData.value.toFixed(1)
                    unit: "kWh/100km"
                    valueSize: Tokens.dataLg
                }
            }
        }

        GridBoard {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.breakpoint === "compact" ? 140 : 160
            columns: Tokens.breakpoint === "compact" ? 2 : 4

            Repeater {
                model: screen.tires.connected ? screen.tires.pressures : []

                delegate: Metric {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "타이어 " + modelData.label
                    value: modelData.kpa
                    unit: "kPa"
                    valueTone: modelData.state === "warn" ? Tokens.warning : Tokens.ink
                    delta: modelData.state === "warn" ? "점검 필요" : ""
                    deltaTone: Tokens.warning
                    valueSize: Tokens.dataMd
                }
            }

            Cell {
                visible: !screen.tires.connected
                Layout.fillWidth: true
                Layout.fillHeight: true

                EmptyState {
                    Layout.fillWidth: true
                    iconName: "vehicle"
                    title: "TPMS 연결 전"
                    detail: "타이어 공기압 센서가 연결되면 네 바퀴 값이 표시됩니다."
                }
            }
        }
    }
}
