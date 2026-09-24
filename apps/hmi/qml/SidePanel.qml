import QtQuick
import OAS.HMI

// Right slide-over for secondary detail. Replaces a modal wherever the driver
// must still see the screen behind it.
Item {
    id: panel

    property string title: ""
    property bool open: false
    default property alias content: body.data

    // Position is driven by x alone; a right anchor would pin it open.
    anchors.top: parent ? parent.top : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    width: Tokens.breakpoint === "compact" ? 360 : 420
    visible: parent !== null && x < parent.width
    x: parent === null ? 0 : (open ? parent.width - width : parent.width)

    Behavior on x { NumberAnimation { duration: Tokens.mSlow; easing.type: Tokens.easeInOut } }

    Panel {
        anchors.fill: parent
        border.color: Tokens.borderStrong

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Tokens.s5
            height: Tokens.touchBase

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: panel.title
                color: Tokens.textPrimary
                font.pixelSize: Tokens.titleSection
                font.weight: Tokens.weightMedium
            }

            OasIconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "close"
                variant: "ghost"
                text: "닫기"
                onClicked: panel.open = false
            }
        }

        Item {
            id: body
            anchors.top: header.bottom
            anchors.topMargin: Tokens.s4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Tokens.s5
        }
    }
}
