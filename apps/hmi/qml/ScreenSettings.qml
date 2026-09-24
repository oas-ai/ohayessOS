import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 10 Settings. Every preference has exactly one owner; nothing here is also
// togglable from another screen.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    property int appearanceMode: 0   // 0 auto · 1 light · 2 dark
    property bool allowMediaInDriveWhenStopped: false
    signal appearanceSelected(int mode)
    signal navigate(int destination)
    signal notify(string message, string iconName)

    property int section: 0

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
                spacing: Tokens.s2

                Caption { text: "설정" }

                Repeater {
                    model: [
                        { label: "화면", icon: "settings" },
                        { label: "오디오", icon: "volume" },
                        { label: "안전", icon: "warning" },
                        { label: "단위", icon: "pulse" },
                        { label: "정보", icon: "vehicle" }
                    ]

                    delegate: OasButton {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        text: modelData.label
                        iconName: modelData.icon
                        variant: screen.section === index ? "primary" : "ghost"
                        onClicked: screen.section = index
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                currentIndex: screen.section

                // ── Display ───────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "화면" }

                    Text {
                        text: "테마"
                        color: Tokens.textPrimary
                        font.pixelSize: Tokens.bodyLg
                        font.weight: Tokens.weightMedium
                    }

                    OasSegmented {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 520
                        model: ["자동", "밝은 화면", "어두운 화면"]
                        currentIndex: screen.appearanceMode
                        onActivated: function (i) { screen.appearanceSelected(i) }
                    }

                    Text {
                        text: "자동은 차량의 nightMode 신호를 우선합니다. 신호가 없으면 시스템 테마를 따릅니다."
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 520
                    }

                    Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

                    OasSlider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 520
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

                    Caption { text: "오디오" }

                    OasSlider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 520
                        label: "미디어 볼륨"
                        iconName: "volume"
                        from: 0; to: 1
                        value: Providers.media.volume
                        displayText: Math.round(Providers.media.volume * 100) + "%"
                        enabled: Providers.media.connected
                        onMoved: function (v) { Providers.media.volume = v }
                    }

                    Text {
                        text: "내비게이션 안내음, 통화 볼륨, 이퀄라이저는 오디오 공급자가 연결된 뒤 제공합니다."
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 520
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Safety ────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "안전" }

                    OasToggle {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
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

                    Text {
                        text: "재생 허용 여부는 Runtime이 결정합니다. 이 화면은 정책을 다시 계산하지 않고 결과만 표시합니다."
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                    }

                    Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

                    Readout {
                        label: "현재 재생 권한"
                        value: screen.vehicle && screen.vehicle.mediaPlaybackAllowed ? "허용" : "잠김"
                        valueSize: Tokens.titleSection
                        tone: screen.vehicle && screen.vehicle.mediaPlaybackAllowed ? Tokens.success : Tokens.warning
                    }

                    Text {
                        text: screen.vehicle ? Tokens.playbackReason(screen.vehicle.mediaPlaybackReason) : ""
                        color: Tokens.textSecondary
                        font.pixelSize: Tokens.bodyMd
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── Units ─────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "단위" }

                    Text {
                        text: "이 설치 환경은 SI 단위를 사용합니다: 속도 km/h, 온도 °C, 압력 kPa, 거리 km."
                        color: Tokens.textSecondary
                        font.pixelSize: Tokens.bodyMd
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                    }

                    Text {
                        text: "단위 전환은 표시 계층의 변환만으로 처리하며, Runtime이 전달하는 정규 상태는 항상 SI로 유지합니다."
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.maximumWidth: 560
                    }

                    Item { Layout.fillHeight: true }
                }

                // ── About ─────────────────────────────────────────────────
                ColumnLayout {
                    spacing: Tokens.s4

                    Caption { text: "정보" }

                    Readout { label: "소프트웨어"; value: Providers.update.currentVersion; valueSize: Tokens.titleSection }
                    Readout {
                        label: "상태 스트림"
                        value: screen.vehicle ? screen.vehicle.streamPath : "—"
                        valid: screen.vehicle !== null
                        valueSize: Tokens.bodyLg
                    }
                    Readout {
                        label: "연결"
                        value: screen.vehicle ? screen.vehicle.freshness : "—"
                        valueSize: Tokens.bodyLg
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
