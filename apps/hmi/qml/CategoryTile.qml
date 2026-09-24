import QtQuick
import OAS.HMI

// Vehicle hub entry. A locked tile is dimmed with its reason, never hidden —
// a driver who cannot find a feature searches longer than one who sees it locked.
Item {
    id: tile

    property string title: ""
    property string iconName: ""
    property string summary: ""
    property string lockReason: ""
    property bool active: false
    signal activated()

    implicitHeight: 148
    implicitWidth: 240
    activeFocusOnTab: enabled
    Accessible.name: title
    Accessible.description: enabled ? summary : lockReason
    Accessible.role: Accessible.Button

    Panel {
        anchors.fill: parent
        color: tile.active ? Tokens.accentWash : Tokens.surface
        border.width: tile.activeFocus ? 2 : 1
        border.color: tile.activeFocus ? Tokens.accent
            : tile.active ? Tokens.wash(Tokens.accent, 0.3)
            : hover.hovered && tile.enabled ? Tokens.borderStrong : Tokens.borderSubtle

        Behavior on color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Tokens.s5
        name: tile.iconName
        size: Tokens.iconXl
        tone: tile.enabled ? Tokens.textSecondary : Tokens.textDisabled
        active: tile.active
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s5
        spacing: Tokens.s1

        Text {
            text: tile.title
            width: parent.width
            elide: Text.ElideRight
            color: tile.enabled ? Tokens.textPrimary : Tokens.textDisabled
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightMedium
        }

        Text {
            text: tile.enabled ? tile.summary : tile.lockReason
            visible: text.length > 0
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.textTertiary
            font.pixelSize: Tokens.label
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        enabled: tile.enabled
        onClicked: { tile.forceActiveFocus(); tile.activated() }
    }

    Keys.onSpacePressed: if (enabled) tile.activated()
    Keys.onReturnPressed: if (enabled) tile.activated()
}
