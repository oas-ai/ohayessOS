import QtQuick
import QtQuick.Controls
import OAS.HMI

Button {
    id: control

    // primary · secondary · ghost · danger
    property string variant: "secondary"
    property string iconName: ""
    property int size: Tokens.touchBase
    property string lockReason: ""

    implicitHeight: size
    implicitWidth: Math.max(size, row.implicitWidth + Tokens.s6)
    Accessible.name: text
    Accessible.description: enabled ? "" : lockReason
    hoverEnabled: true

    readonly property color _fg: !enabled ? Tokens.inkDisabled
        : variant === "primary" ? Tokens.onInk
        : variant === "danger" ? Tokens.critical
        : Tokens.ink
    readonly property color _bg: !enabled ? Tokens.surfaceAlt
        : variant === "primary" ? (down ? Tokens.inkSecondary : Tokens.ink)
        : variant === "ghost" ? "transparent"
        : down ? Tokens.surfaceInk : Tokens.surfaceAlt

    contentItem: Item {
        Row {
            id: row
            anchors.centerIn: parent
            spacing: Tokens.s2

            Icon {
                name: control.iconName
                visible: control.iconName.length > 0
                size: Tokens.iconMd
                tone: control._fg
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                visible: control.text.length > 0
                color: control._fg
                font.pixelSize: Tokens.bodyMd
                font.weight: Tokens.weightMedium
            }
        }
    }

    background: Rectangle {
        color: control._bg
        border.width: control.activeFocus ? 2 : Tokens.hairline
        border.color: control.activeFocus ? Tokens.ink
            : control.variant === "ghost" ? Tokens.lineStrong
            : control.variant === "danger" ? Tokens.critical
            : "transparent"

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
    }
}
