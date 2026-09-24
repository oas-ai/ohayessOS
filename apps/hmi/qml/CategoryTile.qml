import QtQuick
import QtQuick.Layouts
import OAS.HMI

// Vehicle hub entry. A locked tile is dimmed with its reason, never hidden —
// a driver who cannot find a feature searches longer than one who sees it locked.
Cell {
    id: tile

    property string title: ""
    property string iconName: ""
    property string summary: ""
    property string lockReason: ""
    property bool active: false
    signal activated()

    implicitHeight: 150
    color: tile.active ? Tokens.surfaceAlt : Tokens.surface
    activeFocusOnTab: enabled
    Accessible.name: title
    Accessible.description: enabled ? summary : lockReason
    Accessible.role: Accessible.Button
    spacing: Tokens.s3

    Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

    RowLayout {
        Layout.fillWidth: true

        Icon {
            name: tile.iconName
            size: Tokens.iconLg
            tone: tile.enabled ? Tokens.ink : Tokens.inkDisabled
        }

        Item { Layout.fillWidth: true }

        Icon {
            name: "chevronRight"
            size: Tokens.iconSm
            tone: Tokens.inkTertiary
            visible: tile.enabled
        }
    }

    Text {
        text: tile.title
        Layout.fillWidth: true
        elide: Text.ElideRight
        color: tile.enabled ? Tokens.ink : Tokens.inkDisabled
        font.pixelSize: Tokens.bodyLg
        font.weight: Tokens.weightDemi
    }

    Text {
        text: tile.enabled ? tile.summary : tile.lockReason
        visible: text.length > 0
        Layout.fillWidth: true
        elide: Text.ElideRight
        color: Tokens.inkTertiary
        font.pixelSize: Tokens.label
    }

    Item { Layout.fillHeight: true }

    overlay: [
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: tile.activeFocus ? 2 : 0
            border.color: Tokens.ink
        },
        MouseArea {
            anchors.fill: parent
            enabled: tile.enabled
            onClicked: { tile.forceActiveFocus(); tile.activated() }
        }
    ]

    Keys.onSpacePressed: if (enabled) tile.activated()
    Keys.onReturnPressed: if (enabled) tile.activated()
}
