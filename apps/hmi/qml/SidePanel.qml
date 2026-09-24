import QtQuick
import OAS.HMI

// Right slide-over for secondary detail. Replaces a modal wherever the driver
// must still see the screen behind it.
Rectangle {
    id: panel

    property string title: ""
    property bool open: false
    default property alias content: body.data

    anchors.top: parent ? parent.top : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    width: Tokens.breakpoint === "compact" ? 380 : 440
    visible: parent !== null && x < parent.width
    x: parent === null ? 0 : (open ? parent.width - width : parent.width)
    color: Tokens.surface

    Behavior on x { NumberAnimation { duration: Tokens.mSlow; easing.type: Tokens.easeInOut } }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Tokens.hairline
        color: Tokens.lineStrong
    }

    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Tokens.railHeight

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Tokens.s6
            anchors.verticalCenter: parent.verticalCenter
            text: panel.title
            color: Tokens.ink
            font.pixelSize: Tokens.titleMd
            font.weight: Tokens.weightDemi
        }

        OasIconButton {
            anchors.right: parent.right
            anchors.rightMargin: Tokens.s4
            anchors.verticalCenter: parent.verticalCenter
            iconName: "close"
            variant: "ghost"
            text: "닫기"
            onClicked: panel.open = false
        }

        Divider { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right }
    }

    Item {
        id: body
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s6
    }
}
