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

    // The hit area never drops below the touch minimum even when the visual is small.
    implicitWidth: Math.max(size, Tokens.touchMin)
    implicitHeight: Math.max(size, Tokens.touchMin)
    Accessible.name: text
    hoverEnabled: true

    readonly property color _fg: !enabled ? Tokens.textDisabled
        : variant === "primary" ? Tokens.accentHi
        : active ? Tokens.accent : Tokens.textPrimary

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            name: control.iconName
            size: Math.round(control.size * 0.42)
            tone: control._fg
        }
    }

    background: Rectangle {
        radius: Tokens.rMd
        color: !control.enabled ? Tokens.surfaceAlt
            : control.variant === "primary" ? (control.down ? Tokens.accentDeep : Tokens.accent)
            : control.active ? Tokens.accentWash
            : control.down ? Tokens.surfaceRaised
            : control.variant === "ghost" ? "transparent" : Tokens.surfaceAlt
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Tokens.accent
            : control.active ? Tokens.wash(Tokens.accent, 0.3) : "transparent"
        scale: control.down ? 0.97 : 1.0

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
        Behavior on scale { NumberAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

        Rectangle {
            visible: control.badge > 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Tokens.s1
            width: Math.max(20, badgeText.implicitWidth + Tokens.s2)
            height: 20
            radius: Tokens.rPill
            color: Tokens.accent

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: control.badge > 99 ? "99+" : control.badge
                color: Tokens.onAccent
                font.pixelSize: Tokens.caption
                font.weight: Tokens.weightDemi
            }
        }
    }
}
