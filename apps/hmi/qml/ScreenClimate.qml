import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 04 Climate. Everything the driver touches often is reachable without
// scrolling, including the seat controls.
Item {
    id: screen

    property var vehicle: null
    signal notify(string message, string iconName)

    readonly property var climate: Providers.climate

    EmptyState {
        anchors.centerIn: parent
        width: Math.min(parent.width - Tokens.s8, 480)
        visible: !screen.climate.connected
        iconName: "climate"
        title: "공조 공급자 연결 전"
        detail: "실내 온도, 풍량, 시트 열선과 통풍은 공조 데이터가 연결되면 이 화면에서 직접 조절합니다."
        badge: "제어 전송 없음"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.hairline
        visible: screen.climate.connected

        // ── Dual zone temperature ─────────────────────────────────────────
        GridBoard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: Tokens.breakpoint === "compact" ? 280 : 360
            columns: 3

            TempZone {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 5
                label: "운전석"
                value: screen.climate.driverTemp
                from: screen.climate.minTemp
                to: screen.climate.maxTemp
                onMoved: function (v) {
                    screen.climate.driverTemp = v
                    if (screen.climate.sync) screen.climate.passengerTemp = v
                }
            }

            Cell {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: Tokens.touchHero

                Item { Layout.fillHeight: true }

                OasIconButton {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: "sync"
                    size: Tokens.touchLarge
                    active: screen.climate.sync
                    text: "좌우 온도 동기화"
                    onClicked: {
                        screen.climate.sync = !screen.climate.sync
                        if (screen.climate.sync) screen.climate.passengerTemp = screen.climate.driverTemp
                        screen.notify(screen.climate.sync ? "좌우 온도 동기화" : "동기화 해제", "check")
                    }
                }

                Caption { text: "SYNC"; Layout.alignment: Qt.AlignHCenter }

                Item { Layout.fillHeight: true }
            }

            TempZone {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 5
                label: "동승석"
                value: screen.climate.passengerTemp
                from: screen.climate.minTemp
                to: screen.climate.maxTemp
                enabled: !screen.climate.sync
                onMoved: function (v) { screen.climate.passengerTemp = v }
            }
        }

        // ── Fan ───────────────────────────────────────────────────────────
        OasSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.touchLarge
            label: "풍량"
            iconName: "fan"
            from: 0
            to: screen.climate.maxFan
            stepSize: 1
            value: screen.climate.fanLevel
            displayText: screen.climate.fanLevel + " / " + screen.climate.maxFan
            onMoved: function (v) { screen.climate.fanLevel = v; if (v > 0) screen.climate.auto = false }
        }

        // ── Seats ─────────────────────────────────────────────────────────
        GridBoard {
            Layout.fillWidth: true
            columns: 2

            Repeater {
                model: [
                    { zone: "운전석 시트", heat: "driverSeatHeat", vent: "driverSeatVent" },
                    { zone: "동승석 시트", heat: "passengerSeatHeat", vent: "passengerSeatVent" }
                ]

                delegate: Cell {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Tokens.s3

                    Caption { text: modelData.zone }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.s5

                        Icon {
                            name: "seatHeat"
                            size: Tokens.iconMd
                            active: screen.climate[modelData.heat] > 0
                            Layout.alignment: Qt.AlignVCenter
                        }

                        OasSegmented {
                            Layout.fillWidth: true
                            model: ["0", "1", "2", "3"]
                            currentIndex: screen.climate[modelData.heat]
                            onActivated: function (i) {
                                screen.climate[modelData.heat] = i
                                if (i > 0) screen.climate[modelData.vent] = 0
                            }
                        }

                        Icon {
                            name: "seatVent"
                            size: Tokens.iconMd
                            active: screen.climate[modelData.vent] > 0
                            Layout.alignment: Qt.AlignVCenter
                        }

                        OasSegmented {
                            Layout.fillWidth: true
                            model: ["0", "1", "2", "3"]
                            currentIndex: screen.climate[modelData.vent]
                            onActivated: function (i) {
                                screen.climate[modelData.vent] = i
                                if (i > 0) screen.climate[modelData.heat] = 0
                            }
                        }
                    }
                }
            }
        }

        // ── Modes ─────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.touchLarge + Tokens.s5 * 2
            color: Tokens.surface

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Tokens.cellPadding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Tokens.hairline

                OasIconButton {
                    iconName: "defrostFront"
                    size: Tokens.touchLarge
                    active: screen.climate.defrostFront
                    text: "앞유리 성에 제거"
                    onClicked: {
                        screen.climate.defrostFront = !screen.climate.defrostFront
                        screen.notify(screen.climate.defrostFront ? "앞유리 성에 제거 켜짐" : "앞유리 성에 제거 꺼짐", "defrostFront")
                    }
                }

                OasIconButton {
                    iconName: "defrostRear"
                    size: Tokens.touchLarge
                    active: screen.climate.defrostRear
                    text: "뒷유리 열선"
                    onClicked: {
                        screen.climate.defrostRear = !screen.climate.defrostRear
                        screen.notify(screen.climate.defrostRear ? "뒷유리 열선 켜짐" : "뒷유리 열선 꺼짐", "defrostRear")
                    }
                }

                OasButton {
                    text: "A/C"
                    variant: screen.climate.ac ? "primary" : "secondary"
                    size: Tokens.touchLarge
                    onClicked: { screen.climate.ac = !screen.climate.ac; screen.notify(screen.climate.ac ? "A/C 켜짐" : "A/C 꺼짐", "climate") }
                }

                OasButton {
                    text: "AUTO"
                    variant: screen.climate.auto ? "primary" : "secondary"
                    size: Tokens.touchLarge
                    onClicked: { screen.climate.auto = !screen.climate.auto; screen.notify(screen.climate.auto ? "자동 공조" : "수동 공조", "climate") }
                }

                OasButton {
                    text: "내기 순환"
                    variant: screen.climate.recirculate ? "primary" : "secondary"
                    size: Tokens.touchLarge
                    onClicked: { screen.climate.recirculate = !screen.climate.recirculate; screen.notify(screen.climate.recirculate ? "내기 순환" : "외기 유입", "fan") }
                }
            }

            Column {
                anchors.right: parent.right
                anchors.rightMargin: Tokens.cellPadding
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Caption { text: "실외"; anchors.right: parent.right }

                Text {
                    anchors.right: parent.right
                    text: screen.climate.outsideValid ? screen.climate.outsideTemp.toFixed(1) + " °C" : "—"
                    color: Tokens.ink
                    font.pixelSize: Tokens.titleMd
                    font.weight: Tokens.weightDemi
                }
            }
        }
    }
}
