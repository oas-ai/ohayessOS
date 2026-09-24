import QtQuick
import QtQuick.Controls
import OAS.HMI

Button {
    id: control

    // primary · secondary · ghost · danger
    property string variant: "secondary"
    property string iconName: ""
    property int size: Tokens.touchBase
    // Shown instead of acting when the control is disabled by driving policy.
    property string lockReason: ""

    implicitHeight: size
    implicitWidth: Math.max(size, row.implicitWidth + Tokens.s6)
    Accessible.name: text
    Accessible.description: enabled ? "" : lockReason
    hoverEnabled: true

    readonly property color _fg: !enabled ? Tokens.textDisabled
        : variant === "primary" ? Tokens.accentHi
        : variant === "danger" ? Tokens.critical
        : Tokens.textPrimary
    readonly property color _bg: !enabled ? Tokens.surfaceAlt
        : variant === "primary" ? (down ? Tokens.accentDeep : Tokens.accent)
        : variant === "ghost" ? "transparent"
        : variant === "danger" ? Tokens.wash(Tokens.critical)
        : (down ? Tokens.surfaceRaised : Tokens.surfaceAlt)

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
                font.pixelSize: Tokens.bodyLg
                font.weight: Tokens.weightMedium
            }
        }
    }

    background: Rectangle {
        radius: Tokens.rMd
        color: control._bg
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Tokens.accent
            : control.variant === "ghost" ? Tokens.borderStrong
            : control.variant === "danger" ? Tokens.wash(Tokens.critical, 0.3)
            : "transparent"
        scale: control.down ? 0.97 : 1.0

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
        Behavior on scale { NumberAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
    }
}
