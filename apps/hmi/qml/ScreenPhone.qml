import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 09 Phone. The dial pad is the second text input that stays locked while moving.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    signal notify(string message, string iconName)

    readonly property var phone: Providers.phone

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.gutter

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true

            EmptyState {
                anchors.centerIn: parent
                width: Math.min(parent.width - Tokens.s8, 480)
                visible: !screen.phone.connected
                iconName: "phone"
                title: "연결된 기기 없음"
                detail: "블루투스로 휴대폰을 연결하면 최근 통화와 즐겨찾기가 이 화면에 표시됩니다."
                badge: "페어링 필요"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s4
                visible: screen.phone.connected

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Tokens.s1
                        Text {
                            text: screen.phone.device
                            color: Tokens.textPrimary
                            font.pixelSize: Tokens.titleSection
                            font.weight: Tokens.weightMedium
                        }
                        Text {
                            text: "신호 " + screen.phone.signalBars + "/5 · 배터리 " + screen.phone.batteryPercent + "%"
                            color: Tokens.textTertiary
                            font.pixelSize: Tokens.label
                        }
                    }

                    Item { Layout.fillWidth: true }

                    StatusBadge { text: "연결됨"; tone: Tokens.success }
                }

                Divider { Layout.fillWidth: true }

                Caption { text: "최근 통화" }

                Repeater {
                    model: screen.phone.recents

                    delegate: NotificationItem {
                        required property var modelData
                        Layout.fillWidth: true
                        title: modelData.name
                        detail: modelData.detail
                        iconName: modelData.icon
                        tone: modelData.missed ? Tokens.critical : Tokens.textSecondary
                        unread: modelData.missed

                        MouseArea {
                            anchors.fill: parent
                            onClicked: screen.notify(modelData.name + " 발신 — 통화 공급자 연결 전", "phone")
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s3

                    OasButton {
                        Layout.fillWidth: true
                        size: Tokens.touchLarge
                        text: screen.driving ? "주행 중 다이얼 잠금" : "다이얼 패드"
                        iconName: "phone"
                        enabled: !screen.driving
                        lockReason: "주행 중에는 번호 입력을 사용할 수 없습니다"
                        onClicked: screen.notify("통화 공급자 연결 전", "phone")
                    }

                    OasButton {
                        Layout.fillWidth: true
                        size: Tokens.touchLarge
                        text: "음성으로 전화"
                        iconName: "mic"
                        variant: "primary"
                        onClicked: screen.notify("음성 인식 공급자 연결 전", "mic")
                    }
                }
            }
        }

        Panel {
            visible: Tokens.showSideColumns && screen.phone.connected
            Layout.preferredWidth: Tokens.sideColumn
            Layout.maximumWidth: Tokens.sideColumn
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s3

                Caption { text: "즐겨찾기" }

                Repeater {
                    model: screen.phone.favorites

                    delegate: OasButton {
                        required property var modelData
                        Layout.fillWidth: true
                        size: Tokens.touchLarge
                        text: modelData.name
                        iconName: modelData.icon
                        variant: "secondary"
                        onClicked: screen.notify(modelData.name + " 발신 — 통화 공급자 연결 전", "phone")
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "즐겨찾기는 주행 중에도 한 번의 터치로 발신할 수 있습니다."
                    color: Tokens.textTertiary
                    font.pixelSize: Tokens.label
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}
