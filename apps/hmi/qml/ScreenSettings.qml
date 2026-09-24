import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 10 Settings. Every preference has exactly one owner; nothing here is also
// togglable from another screen.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    property int appearanceMode: 1   // 0 auto · 1 light · 2 dark
    property bool allowMediaInDriveWhenStopped: false
    signal appearanceSelected(int mode)
    signal navigate(int destination)
    signal notify(string message, string iconName)

    property int section: 0

    GridBoard {
        anchors.fill: parent
        columns: 2

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.maximumWidth: Tokens.breakpoint === "compact" ? 220 : 300
            padding: 0
            spacing: 0

            Repeater {
                model: ["화면", "오디오", "안전", "단위", "정보"]

                delegate: Rectangle {
                    id: row
                    required property int index
                    required property string modelData
                    readonly property bool selected: screen.section === index

                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.touchLarge
                    color: selected ? Tokens.ink : "transparent"
                    activeFocusOnTab: true
                    Accessible.name: modelData
                    Accessible.role: Accessible.Button

                    Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Tokens.cellPadding
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData
                        color: row.selected ? Tokens.onInk : Tokens.ink
                        font.pixelSize: Tokens.bodyLg
                        font.weight: row.selected ? Tokens.weightDemi : Tokens.weightRegular
                    }

                    Divider { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right }

                    MouseArea { anchors.fill: parent; onClicked: { row.forceActiveFocus(); screen.section = row.index } }
                    Keys.onSpacePressed: screen.section = row.index
                }
            }

            Item { Layout.fillHeight: true }
        }

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
            padding: Tokens.s6

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: screen.section

                // ── Display ───────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "테마" }

                    OasSegmented {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                        model: ["자동", "밝은 화면", "어두운 화면"]
                        currentIndex: screen.appearanceMode
                        onActivated: function (i) { screen.appearanceSelected(i) }
                    }

                    Text {
                        text: "자동은 차량의 nightMode 신호를 우선합니다. 신호가 없으면 밝은 화면을 유지합니다."
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                    }

                    Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

                    OasSlider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                        label: "실내 앰비언트"
                        from: 0
                        to: Providers.lights.maxAmbient
                        stepSize: 1
                        value: Providers.lights.ambientLevel
                        displayText: Providers.lights.ambientLevel + " / " + Providers.lights.maxAmbient
                        enabled: Providers.lights.connected
                        onMoved: function (v) { Providers.lights.ambientLevel = v }
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Audio ─────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "볼륨" }

                    OasSlider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                        label: "미디어"
                        iconName: "volume"
                        from: 0; to: 1
                        value: Providers.media.volume
                        displayText: Math.round(Providers.media.volume * 100) + "%"
                        enabled: Providers.media.connected
                        onMoved: function (v) { Providers.media.volume = v }
                    }

                    Text {
                        text: "내비게이션 안내음, 통화 볼륨, 이퀄라이저는 오디오 공급자가 연결된 뒤 제공합니다."
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Safety ────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    OasToggle {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 620
                        text: "정차 중 D 기어에서 미디어 허용"
                        detail: "기본값은 꺼짐입니다. 켜도 주행, 상태 불명, stale은 항상 차단됩니다."
                        checked: screen.allowMediaInDriveWhenStopped
                        enabled: !screen.driving
                        lockReason: "주행 중에는 변경할 수 없습니다"
                        onToggled: function (v) {
                            screen.allowMediaInDriveWhenStopped = v
                            screen.notify("이 설정은 Runtime 시작 옵션으로만 적용됩니다", "warning")
                        }
                    }

                    Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

                    Caption { text: "현재 재생 권한" }

                    Text {
                        text: screen.vehicle && screen.vehicle.mediaPlaybackAllowed ? "허용" : "잠김"
                        color: screen.vehicle && screen.vehicle.mediaPlaybackAllowed ? Tokens.success : Tokens.warning
                        font.pixelSize: Tokens.titleMd
                        font.weight: Tokens.weightDemi
                    }

                    Text {
                        text: screen.vehicle ? Tokens.playbackReason(screen.vehicle.mediaPlaybackReason) : ""
                        color: Tokens.inkSecondary
                        font.pixelSize: Tokens.bodyMd
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "재생 허용 여부는 Runtime이 결정합니다. 이 화면은 정책을 다시 계산하지 않고 결과만 표시합니다."
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 620
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Units ─────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "표시 단위" }

                    Text {
                        text: "속도 km/h · 온도 °C · 압력 kPa · 거리 km"
                        color: Tokens.ink
                        font.pixelSize: Tokens.titleMd
                        font.weight: Tokens.weightDemi
                    }

                    Text {
                        text: "단위 전환은 표시 계층의 변환만으로 처리하며, Runtime이 전달하는 정규 상태는 항상 SI로 유지합니다."
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 620
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── About ─────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s5

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "소프트웨어" }
                        Text {
                            text: Providers.update.currentVersion
                            color: Tokens.ink
                            font.pixelSize: Tokens.titleMd
                            font.weight: Tokens.weightDemi
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "상태 스트림" }
                        Text {
                            text: screen.vehicle ? screen.vehicle.streamPath : "—"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyLg
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Caption { text: "연결" }
                        Text {
                            text: screen.vehicle ? screen.vehicle.freshness : "—"
                            color: Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyLg
                        }
                    }

                    OasButton {
                        Layout.topMargin: Tokens.s2
                        text: "소프트웨어 업데이트 열기"
                        iconName: "download"
                        enabled: !screen.driving
                        lockReason: "주행 중에는 열 수 없습니다"
                        onClicked: screen.navigate(Nav.software)
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
