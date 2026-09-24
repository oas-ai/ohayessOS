import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 11 Software update. Installing is the one action that asks for confirmation.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    signal notify(string message, string iconName)

    readonly property var update: Providers.update
    property bool installing: false
    property real progress: 0

    Panel {
        anchors.fill: parent

        EmptyState {
            anchors.centerIn: parent
            width: Math.min(parent.width - Tokens.s8, 480)
            visible: !screen.update.connected
            iconName: "download"
            title: "업데이트 서버 연결 전"
            detail: "네트워크가 연결되면 사용 가능한 소프트웨어 버전과 변경 사항이 여기에 표시됩니다."
            badge: Providers.update.currentVersion
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.s6
            spacing: Tokens.s5
            visible: screen.update.connected

            Caption { text: "소프트웨어" }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.s8

                Readout { label: "설치됨"; value: screen.update.currentVersion; valueSize: Tokens.titleSection }
                Readout {
                    label: "사용 가능"
                    value: screen.update.availableVersion
                    valueSize: Tokens.titleSection
                    tone: Tokens.accent
                }
                Readout { label: "크기"; value: screen.update.sizeMb; unit: "MB"; valueSize: Tokens.titleSection }
                Item { Layout.fillWidth: true }
            }

            Divider { Layout.fillWidth: true }

            Caption { text: "변경 사항" }

            Repeater {
                model: screen.update.notes

                delegate: RowLayout {
                    required property string modelData
                    Layout.fillWidth: true
                    spacing: Tokens.s3

                    Icon {
                        name: "check"
                        size: Tokens.iconSm
                        tone: Tokens.accent
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 2
                    }

                    Text {
                        text: modelData
                        color: Tokens.textSecondary
                        font.pixelSize: Tokens.bodyMd
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            Item { Layout.fillHeight: true }

            ColumnLayout {
                visible: screen.installing
                Layout.fillWidth: true
                spacing: Tokens.s2

                Text {
                    text: "설치 중 " + Math.round(screen.progress * 100) + "%"
                    color: Tokens.textPrimary
                    font.pixelSize: Tokens.bodyLg
                    font.weight: Tokens.weightMedium
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 12
                    radius: 6
                    color: Tokens.surfaceAlt

                    Rectangle {
                        width: parent.width * screen.progress
                        height: parent.height
                        radius: parent.radius
                        color: Tokens.accent
                        Behavior on width { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.s3

                Text {
                    text: screen.driving
                        ? "설치는 정차 후 P 기어에서만 시작할 수 있습니다."
                        : "설치 중에는 차량을 사용할 수 없습니다."
                    color: screen.driving ? Tokens.warning : Tokens.textTertiary
                    font.pixelSize: Tokens.label
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                OasButton {
                    text: screen.installing ? "설치 중" : "지금 설치"
                    iconName: "download"
                    variant: "primary"
                    size: Tokens.touchLarge
                    enabled: !screen.driving && !screen.installing && screen.update.updateAvailable
                    lockReason: "주행 중에는 설치할 수 없습니다"
                    onClicked: confirm.open = true
                }
            }
        }
    }

    OasModal {
        id: confirm
        title: "소프트웨어를 설치할까요?"
        detail: screen.update.availableVersion + " 설치를 시작하면 차량을 약 25분간 사용할 수 없습니다. 설치 중에는 전원을 끄지 마세요."
        confirmText: "설치 시작"
        destructive: true
        onAccepted: {
            screen.installing = true
            screen.progress = 0
            tick.start()
            screen.notify("업데이트 설치를 시작했습니다", "download")
        }
    }

    Timer {
        id: tick
        interval: 300
        repeat: true
        onTriggered: {
            screen.progress = Math.min(1, screen.progress + 0.04)
            if (screen.progress >= 1) { stop(); screen.installing = false; screen.notify("설치가 완료되었습니다", "check") }
        }
    }
}
