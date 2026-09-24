import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 03 Media, expanded. The global transport is suppressed here to avoid two
// copies of the same controls on one screen.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    signal notify(string message, string iconName)

    readonly property var media: Providers.media
    readonly property bool allowed: media.connected && (vehicle ? vehicle.mediaPlaybackAllowed : false)
    // Driving trims the queue instead of removing it.
    readonly property int queueLimit: driving ? 3 : 8

    function timeText(seconds) {
        const total = Math.max(0, Math.round(seconds))
        return Math.floor(total / 60) + ":" + ("0" + (total % 60)).slice(-2)
    }

    EmptyState {
        anchors.centerIn: parent
        width: Math.min(parent.width - Tokens.s8, 480)
        visible: !screen.media.connected
        iconName: "media"
        title: "재생 소스 연결 전"
        detail: "미디어 소스가 연결되면 앨범 아트, 진행률, 오디오 소스와 사운드 설정이 이 화면에 표시됩니다."
        badge: "소스 없음"
    }

    GridBoard {
        anchors.fill: parent
        columns: Tokens.showSideColumns ? 3 : 1
        visible: screen.media.connected

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            spacing: Tokens.s4

            RowLayout {
                Layout.fillWidth: true
                Caption { text: "재생 중" }
                Item { Layout.fillWidth: true }
                StatusBadge {
                    text: screen.allowed ? "재생 허용" : "재생 잠김"
                    tone: screen.allowed ? Tokens.success : Tokens.warning
                }
            }

            // Artwork placeholder: there is no artwork source yet, so this
            // stays an explicit surface rather than a fabricated image.
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 120
                color: Tokens.surfaceAlt

                Icon {
                    anchors.centerIn: parent
                    name: "media"
                    size: Tokens.iconXl
                    tone: screen.allowed ? Tokens.ink : Tokens.inkTertiary
                }
            }

            Text {
                text: screen.media.track
                color: Tokens.ink
                font.pixelSize: Tokens.titleLg
                font.weight: Tokens.weightDemi
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: screen.media.artist + " · " + screen.media.album
                color: Tokens.inkSecondary
                font.pixelSize: Tokens.bodyMd
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            OasSlider {
                Layout.fillWidth: true
                label: screen.timeText(screen.media.positionSec)
                from: 0
                to: screen.media.durationSec
                value: screen.media.positionSec
                displayText: screen.timeText(screen.media.durationSec)
                enabled: screen.allowed
                onMoved: function (v) { screen.media.positionSec = v }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.hairline

                OasIconButton {
                    iconName: "prev"
                    size: Tokens.touchLarge
                    text: "이전 곡"
                    enabled: screen.allowed
                    onClicked: screen.notify("이전 곡", "prev")
                }

                OasIconButton {
                    iconName: screen.media.playing ? "pause" : "play"
                    size: Tokens.touchLarge
                    variant: "primary"
                    text: screen.media.playing ? "일시정지" : "재생"
                    enabled: screen.allowed
                    onClicked: {
                        screen.media.playing = !screen.media.playing
                        screen.notify(screen.media.playing ? "재생" : "일시정지", screen.media.playing ? "play" : "pause")
                    }
                }

                OasIconButton {
                    iconName: "next"
                    size: Tokens.touchLarge
                    text: "다음 곡"
                    enabled: screen.allowed
                    onClicked: screen.notify("다음 곡", "next")
                }

                OasSlider {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.touchLarge
                    label: "볼륨"
                    iconName: "volume"
                    from: 0
                    to: 1
                    value: screen.media.volume
                    displayText: Math.round(screen.media.volume * 100) + "%"
                    onMoved: function (v) { screen.media.volume = v }
                }
            }

            Text {
                visible: !screen.allowed
                text: screen.vehicle ? Tokens.playbackReason(screen.vehicle.mediaPlaybackReason) : ""
                color: Tokens.warning
                font.pixelSize: Tokens.label
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Cell {
            visible: Tokens.showSideColumns
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            spacing: Tokens.s4

            Caption { text: "오디오 소스" }

            OasSegmented {
                Layout.fillWidth: true
                model: screen.media.sources
                currentIndex: screen.media.sourceIndex
                onActivated: function (i) {
                    screen.media.sourceIndex = i
                    screen.notify(screen.media.sources[i] + " 선택", "media")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Tokens.s2
                Caption { text: "재생 목록" }
                Item { Layout.fillWidth: true }
                Caption { text: screen.driving ? "주행 중 축약" : ""; color: Tokens.warning }
            }

            Repeater {
                model: Math.min(screen.queueLimit, screen.media.queue.length)

                delegate: Item {
                    required property int index
                    readonly property var entry: screen.media.queue[index]
                    Layout.fillWidth: true
                    implicitHeight: Tokens.touchBase

                    Rectangle {
                        anchors.fill: parent
                        color: index === 0 ? Tokens.surfaceAlt : "transparent"
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: index === 0 ? Tokens.s3 : 0
                        anchors.right: duration.left
                        anchors.rightMargin: Tokens.s3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            text: entry.track
                            width: parent.width
                            elide: Text.ElideRight
                            color: index === 0 ? Tokens.ink : Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyMd
                            font.weight: index === 0 ? Tokens.weightDemi : Tokens.weightRegular
                        }

                        Text {
                            text: entry.artist
                            width: parent.width
                            elide: Text.ElideRight
                            color: Tokens.inkTertiary
                            font.pixelSize: Tokens.caption
                        }
                    }

                    Text {
                        id: duration
                        anchors.right: parent.right
                        anchors.rightMargin: index === 0 ? Tokens.s3 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: entry.duration
                        color: Tokens.inkTertiary
                        font.pixelSize: Tokens.label
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                visible: screen.driving && screen.media.queue.length > screen.queueLimit
                text: "주행 중에는 최근 항목만 표시합니다. 정차하면 전체 목록이 열립니다."
                color: Tokens.inkTertiary
                font.pixelSize: Tokens.label
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
