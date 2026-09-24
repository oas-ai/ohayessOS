import QtQuick
import OAS.HMI

// Transient confirmation above the dock. Never used for safety information.
Rectangle {
    id: toast

    property string message: ""
    property string iconName: "check"
    property color tone: Tokens.accent

    function show(text, icon, toneColor) {
        message = text
        iconName = icon === undefined ? "check" : icon
        tone = toneColor === undefined ? Tokens.accent : toneColor
        opacity = 1
        shown = true
        life.restart()
    }

    property bool shown: false

    implicitWidth: Math.min(480, row.implicitWidth + Tokens.s6)
    implicitHeight: Tokens.touchBase
    radius: Tokens.rPill
    color: Tokens.surfaceRaised
    border.width: 1
    border.color: Tokens.borderStrong
    opacity: 0
    visible: opacity > 0
    y: shown ? 0 : Tokens.s2

    Behavior on opacity { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
    Behavior on y { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Tokens.s3

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: toast.iconName
            size: Tokens.iconMd
            tone: toast.tone
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: toast.message
            color: Tokens.textPrimary
            font.pixelSize: Tokens.bodyMd
            font.weight: Tokens.weightMedium
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { toast.shown = false; toast.opacity = 0; life.stop() }
    }

    Timer {
        id: life
        interval: 3000
        onTriggered: { toast.shown = false; toast.opacity = 0 }
    }
}
