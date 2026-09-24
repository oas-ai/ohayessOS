import QtQuick
import OAS.HMI

// Artwork, track, artist and three transport controls. Nothing else — the rest
// is one destination away.
Item {
    id: player

    property string track: ""
    property string artist: ""
    property bool playing: false
    property bool available: false
    property string lockReason: ""
    signal toggled()
    signal previous()
    signal next()
    signal expand()

    implicitHeight: Tokens.touchHero
    readonly property bool _roomForSkip: width >= 420
    readonly property bool _roomForArt: width >= 360

    Rectangle {
        id: art
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: player._roomForArt
        width: player._roomForArt ? 64 : 0
        height: 64
        color: Tokens.surfaceAlt
        border.width: Tokens.hairline
        border.color: Tokens.line

        Icon {
            anchors.centerIn: parent
            name: "media"
            size: Tokens.iconLg
            tone: player.available ? Tokens.ink : Tokens.inkTertiary
        }

        MouseArea { anchors.fill: parent; onClicked: player.expand() }
    }

    Column {
        anchors.left: art.right
        anchors.leftMargin: player._roomForArt ? Tokens.s4 : 0
        anchors.right: transport.left
        anchors.rightMargin: Tokens.s3
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: player.available ? player.track : "재생 소스 연결 전"
            width: parent.width
            elide: Text.ElideRight
            color: player.available ? Tokens.ink : Tokens.inkSecondary
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightDemi
        }

        Text {
            text: player.available ? player.artist : player.lockReason
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.inkTertiary
            font.pixelSize: Tokens.label
        }
    }

    Row {
        id: transport
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.hairline

        OasIconButton {
            iconName: "prev"
            variant: "secondary"
            size: Tokens.touchLarge
            text: "이전 곡"
            visible: player._roomForSkip
            enabled: player.available
            onClicked: player.previous()
        }

        OasIconButton {
            iconName: player.playing ? "pause" : "play"
            variant: player.available ? "primary" : "secondary"
            size: Tokens.touchLarge
            text: player.playing ? "일시정지" : "재생"
            enabled: player.available
            onClicked: player.toggled()
        }

        OasIconButton {
            iconName: "next"
            variant: "secondary"
            size: Tokens.touchLarge
            text: "다음 곡"
            visible: player._roomForSkip
            enabled: player.available
            onClicked: player.next()
        }
    }
}
