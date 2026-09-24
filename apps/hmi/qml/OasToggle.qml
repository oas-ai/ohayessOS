import QtQuick
import OAS.HMI

// Full row is the hit area; the track is only the indicator.
Item {
    id: toggle

    property string text: ""
    property string detail: ""
    property bool checked: false
    property string lockReason: ""
    signal toggled(bool value)

    implicitHeight: Math.max(Tokens.touchMin, column.implicitHeight + Tokens.s2)
    // Fixed rather than derived: the label width is anchored to this item, so
    // deriving from it would close a layout loop.
    implicitWidth: 320
    activeFocusOnTab: enabled
    Accessible.name: toggle.text
    Accessible.role: Accessible.CheckBox

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Tokens.s2
        radius: Tokens.rMd
        color: "transparent"
        border.width: toggle.activeFocus ? 2 : 0
        border.color: Tokens.accent
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: track.left
        anchors.rightMargin: Tokens.s4
        spacing: 2

        Text {
            text: toggle.text
            width: parent.width
            elide: Text.ElideRight
            color: toggle.enabled ? Tokens.textPrimary : Tokens.textDisabled
            font.pixelSize: Tokens.bodyMd
            font.weight: Tokens.weightMedium
        }

        Text {
            text: toggle.enabled ? toggle.detail : toggle.lockReason
            visible: text.length > 0
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.textTertiary
            font.pixelSize: Tokens.label
        }
    }

    Rectangle {
        id: track
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 72
        height: 40
        radius: Tokens.rPill
        color: !toggle.enabled ? Tokens.surfaceAlt : toggle.checked ? Tokens.accent : Tokens.surfaceRaised
        border.width: 1
        border.color: toggle.checked ? Tokens.wash(Tokens.accent, 0.4) : Tokens.borderStrong

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

        Rectangle {
            width: 32
            height: 32
            radius: Tokens.rPill
            y: 4
            x: toggle.checked ? track.width - width - 4 : 4
            color: !toggle.enabled ? Tokens.textDisabled : toggle.checked ? Tokens.accentHi : Tokens.textSecondary

            Behavior on x { NumberAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
            Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: toggle.enabled
        onClicked: {
            toggle.forceActiveFocus()
            toggle.checked = !toggle.checked
            toggle.toggled(toggle.checked)
        }
    }

    Keys.onSpacePressed: if (enabled) { checked = !checked; toggled(checked) }
}
