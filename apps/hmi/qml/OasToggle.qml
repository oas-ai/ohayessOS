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
    implicitWidth: 320
    activeFocusOnTab: enabled
    Accessible.name: toggle.text
    Accessible.role: Accessible.CheckBox

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: toggle.activeFocus ? 2 : 0
        border.color: Tokens.ink
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
            color: toggle.enabled ? Tokens.ink : Tokens.inkDisabled
            font.pixelSize: Tokens.bodyMd
            font.weight: Tokens.weightMedium
        }

        Text {
            text: toggle.enabled ? toggle.detail : toggle.lockReason
            visible: text.length > 0
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.inkTertiary
            font.pixelSize: Tokens.label
        }
    }

    Rectangle {
        id: track
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 64
        height: 32
        color: !toggle.enabled ? Tokens.surfaceAlt : toggle.checked ? Tokens.ink : Tokens.surfaceInk
        border.width: Tokens.hairline
        border.color: toggle.checked ? Tokens.ink : Tokens.lineStrong

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

        Rectangle {
            width: 24
            height: 24
            y: 4
            x: toggle.checked ? track.width - width - 4 : 4
            color: !toggle.enabled ? Tokens.inkDisabled : toggle.checked ? Tokens.onInk : Tokens.surface

            Behavior on x { NumberAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
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
