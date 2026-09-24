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

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.gutter

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true

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
                anchors.margins: Tokens.s5
                spacing: Tokens.s5
                visible: screen.energy.connected

                RowLayout {
                    Layout.fillWidth: true
                    Caption { text: screen.energy.kind === "battery" ? "고전압 배터리" : "연료" }
                    Item { Layout.fillWidth: true }
                    StatusBadge {
                        text: screen.energy.charging ? "충전 중" : "충전 안 함"
                        tone: screen.energy.charging ? Tokens.success : Tokens.textTertiary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s8

                    Readout {
                        label: "잔량"
                        value: Math.round(screen.energy.level * 100)
                        unit: "%"
                        valueSize: Tokens.speedLarge
                    }

                    Readout {
                        label: "주행 가능"
                        value: Math.round(screen.energy.rangeKm)
                        unit: "km"
                        valueSize: Tokens.displayMd
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    radius: 10
                    color: Tokens.surfaceAlt

                    Rectangle {
                        width: parent.width * screen.energy.level
                        height: parent.height
                        radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Tokens.accentDeep }
                            GradientStop { position: 1; color: Tokens.accent }
                        }
                        Behavior on width { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                    }
                }

                Divider { Layout.fillWidth: true }

                Caption { text: "전비" }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s5

                    Repeater {
                        model: screen.energy.recent

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 104
                            radius: Tokens.rLg
                            color: Tokens.surfaceAlt

                            Readout {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Tokens.s4
                                label: modelData.label
                                value: modelData.value.toFixed(1)
                                unit: "kWh/100km"
                                valueSize: Tokens.titleSection
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        Panel {
            Layout.preferredWidth: Tokens.sideColumn
            Layout.maximumWidth: Tokens.sideColumn
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s4

                Caption { text: "타이어 공기압" }

                EmptyState {
                    Layout.fillWidth: true
                    visible: !screen.tires.connected
                    iconName: "vehicle"
                    title: "TPMS 연결 전"
                    detail: "타이어 공기압 센서가 연결되면 네 바퀴 값이 표시됩니다."
                }

                GridLayout {
                    visible: screen.tires.connected
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Tokens.s3
                    rowSpacing: Tokens.s3

                    Repeater {
                        model: screen.tires.pressures

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 96
                            radius: Tokens.rLg
                            color: modelData.state === "warn" ? Tokens.wash(Tokens.warning) : Tokens.surfaceAlt
                            border.width: 1
                            border.color: modelData.state === "warn" ? Tokens.wash(Tokens.warning, 0.3) : "transparent"

                            Column {
                                anchors.centerIn: parent
                                spacing: Tokens.s1

                                Caption {
                                    text: modelData.label
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.kpa + " kPa"
                                    color: modelData.state === "warn" ? Tokens.warning : Tokens.textPrimary
                                    font.pixelSize: Tokens.bodyLg
                                    font.weight: Tokens.weightMedium
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: screen.tires.connected && screen.tires.anyWarning
                    text: "뒤 좌측 공기압이 권장값보다 낮습니다. 가까운 정비소에서 점검하세요."
                    color: Tokens.warning
                    font.pixelSize: Tokens.label
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
