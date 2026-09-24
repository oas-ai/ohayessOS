import QtQuick
import QtQuick.Controls
import OAS.HMI

Button {
    id: control

    property string iconName: ""
    property int size: Tokens.touchBase
    property bool active: false
    property int badge: 0
    property string variant: "secondary"

    implicitWidth: Math.max(size, Tokens.touchMin)
    implicitHeight: Math.max(size, Tokens.touchMin)
    Accessible.name: text
    hoverEnabled: true

    readonly property color _fg: !enabled ? Tokens.inkDisabled
        : (variant === "primary" || active) ? Tokens.onInk : Tokens.ink

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            name: control.iconName
            size: Math.round(control.size * 0.38)
            tone: control._fg
        }
    }

    background: Rectangle {
        color: !control.enabled ? Tokens.surfaceAlt
            : (control.variant === "primary" || control.active) ? (control.down ? Tokens.inkSecondary : Tokens.ink)
            : control.down ? Tokens.surfaceInk
            : control.variant === "ghost" ? "transparent" : Tokens.surfaceAlt
        border.width: control.activeFocus ? 2 : Tokens.hairline
        border.color: control.activeFocus ? Tokens.ink
            : control.variant === "ghost" ? Tokens.line : "transparent"

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

        Rectangle {
            visible: control.badge > 0
            anchors.right: parent.right
            anchors.top: parent.top
            width: Math.max(18, badgeText.implicitWidth + Tokens.s2)
            height: 18
            color: Tokens.ink

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: control.badge > 99 ? "99+" : control.badge
                color: Tokens.onInk
                font.pixelSize: Tokens.caption
                font.weight: Tokens.weightDemi
            }
        }
    }
}
