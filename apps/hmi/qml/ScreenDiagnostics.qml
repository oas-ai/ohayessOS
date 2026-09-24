import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 12 Diagnostics. Raw CAN values are for inspection; they are never a basis for
// a safety decision or a control action.
Item {
    id: screen

    property var vehicle: null
    signal notify(string message, string iconName)

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.gutter

        Panel {
            Layout.preferredWidth: Tokens.sideColumn
            Layout.maximumWidth: Tokens.sideColumn
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s4

                Caption { text: "런타임" }

                Readout {
                    label: "상태 신선도"
                    value: screen.vehicle ? ({ fresh: "정상", stale: "지연", waiting: "대기" }[screen.vehicle.freshness] || "—") : "—"
                    valueSize: Tokens.displaySm
                    tone: screen.vehicle && screen.vehicle.freshness === "fresh" ? Tokens.success : Tokens.warning
                }

                Divider { Layout.fillWidth: true }

                Readout {
                    label: "스트림 경로"
                    value: screen.vehicle ? screen.vehicle.streamPath : "—"
                    valueSize: Tokens.bodyLg
                }

                Readout {
                    label: "진단 권한"
                    value: screen.vehicle && screen.vehicle.diagnosticsAvailable ? "허용" : "없음"
                    valueSize: Tokens.bodyLg
                }

                Readout {
                    label: "차량 제어 권한"
                    value: screen.vehicle && screen.vehicle.vehicleControlsAllowed ? "허용" : "없음"
                    valueSize: Tokens.bodyLg
                }

                Divider { Layout.fillWidth: true }

                Caption { text: "주행 신호" }

                VehicleStatusIndicator {
                    Layout.fillWidth: true
                    items: [
                        { label: "속도", valid: screen.vehicle ? screen.vehicle.speedValid : false, state: "ok" },
                        { label: "기어", valid: screen.vehicle ? screen.vehicle.gearValid : false, state: "ok" },
                        { label: "조향", valid: screen.vehicle ? screen.vehicle.steeringValid : false, state: "ok" },
                        { label: "브레이크", valid: screen.vehicle ? screen.vehicle.brakeValid : false, state: "ok" },
                        { label: "가속", valid: screen.vehicle ? screen.vehicle.acceleratorValid : false, state: "ok" },
                        { label: "크루즈", valid: screen.vehicle ? screen.vehicle.cruiseValid : false, state: "ok" },
                        { label: "도어", valid: screen.vehicle ? screen.vehicle.doorsValid : false, state: "ok" },
                        { label: "안전벨트", valid: screen.vehicle ? screen.vehicle.seatbeltsValid : false, state: "ok" }
                    ]
                }

                Item { Layout.fillHeight: true }

                OasButton {
                    Layout.fillWidth: true
                    text: "로그 내보내기"
                    iconName: "download"
                    variant: "ghost"
                    onClicked: screen.notify("로그 내보내기 대상이 설정되지 않았습니다", "warning")
                }
            }
        }

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s3

                RowLayout {
                    Layout.fillWidth: true
                    Caption { text: "원시 CAN 신호" }
                    Item { Layout.fillWidth: true }
                    StatusBadge {
                        text: screen.vehicle ? screen.vehicle.rawSignals.length + "개" : "0개"
                        tone: Tokens.textTertiary
                    }
                }

                EmptyState {
                    Layout.fillWidth: true
                    Layout.topMargin: Tokens.s8
                    visible: !screen.vehicle || screen.vehicle.rawSignals.length === 0
                    iconName: "pulse"
                    title: "표시할 신호가 없습니다"
                    detail: "Runtime이 진단 권한을 허용하고 최신 상태가 도착하면 DBC 물리값이 정렬되어 표시됩니다."
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: screen.vehicle && screen.vehicle.rawSignals.length > 0
                    model: screen.vehicle ? screen.vehicle.rawSignals : []
                    clip: true
                    spacing: 0

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: Tokens.touchMin

                        Rectangle {
                            anchors.fill: parent
                            color: index % 2 === 0 ? "transparent" : Tokens.wash(Tokens.textSecondary, 0.04)
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Tokens.s3
                            anchors.right: valueText.left
                            anchors.rightMargin: Tokens.s4
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.key
                            elide: Text.ElideMiddle
                            color: Tokens.textSecondary
                            font.pixelSize: Tokens.label
                            font.family: "Menlo, monospace"
                        }

                        Text {
                            id: valueText
                            anchors.right: parent.right
                            anchors.rightMargin: Tokens.s3
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.value.toFixed(2)
                            color: Tokens.textPrimary
                            font.pixelSize: Tokens.bodyMd
                            font.weight: Tokens.weightMedium
                            font.family: "Menlo, monospace"
                        }
                    }
                }

                Text {
                    text: "원시 값은 의미 해석 없이 보존된 물리값입니다. 안전 판단이나 제어 근거로 사용하지 않습니다."
                    color: Tokens.textTertiary
                    font.pixelSize: Tokens.label
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}
