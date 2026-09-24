import QtQuick
import QtQuick.Layouts
import OAS.HMI

// Floats out of the launcher. Every destination in the system is here, so any
// screen is two touches from any other, and each target is oversized.
Item {
    id: menu

    property bool open: false
    property int current: Nav.home
    property int anchorHeight: Tokens.launcherHeight
    property var lockedReasons: ({})
    signal navigate(int destination)
    signal dismissed()

    anchors.fill: parent ? parent : undefined
    visible: opacity > 0
    opacity: open ? 1 : 0
    enabled: open

    Behavior on opacity { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    Rectangle {
        anchors.fill: parent
        color: Tokens.scrim
        MouseArea { anchors.fill: parent; onClicked: menu.dismissed() }
    }

    GridBoard {
        id: board
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: menu.anchorHeight
        width: Math.min(parent.width, Tokens.breakpoint === "compact" ? 3 * 200 : 4 * 240)
        columns: Tokens.breakpoint === "compact" ? 3 : 4

        // Slides up out of the launcher rather than fading in place.
        y: parent.height - menu.anchorHeight - height + (menu.open ? 0 : Tokens.s5)
        Behavior on y { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

        Repeater {
            model: Nav.all

            delegate: Cell {
                id: entry
                required property int index
                required property var modelData
                readonly property bool selected: menu.current === modelData.page
                readonly property string lockReason: menu.lockedReasons[modelData.page] === undefined
                    ? "" : menu.lockedReasons[modelData.page]
                readonly property bool available: lockReason.length === 0

                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.touchHero + Tokens.s5
                color: entry.selected ? Tokens.ink : Tokens.surface
                activeFocusOnTab: entry.available
                Accessible.name: modelData.label
                Accessible.description: entry.lockReason
                Accessible.role: Accessible.Button
                spacing: Tokens.s3

                Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

                Icon {
                    name: entry.modelData.icon
                    size: Tokens.iconLg
                    tone: !entry.available ? Tokens.inkDisabled
                        : entry.selected ? Tokens.onInk : Tokens.ink
                }

                Text {
                    text: entry.modelData.label
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: !entry.available ? Tokens.inkDisabled
                        : entry.selected ? Tokens.onInk : Tokens.ink
                    font.pixelSize: Tokens.bodyMd
                    font.weight: entry.selected ? Tokens.weightDemi : Tokens.weightMedium
                }

                Text {
                    text: entry.lockReason
                    visible: !entry.available
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Tokens.inkTertiary
                    font.pixelSize: Tokens.caption
                }

                overlay: [
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: entry.activeFocus ? 2 : 0
                        border.color: Tokens.ink
                    },
                    MouseArea {
                        anchors.fill: parent
                        enabled: entry.available
                        onClicked: menu.navigate(entry.modelData.page)
                    }
                ]

                Keys.onSpacePressed: if (entry.available) menu.navigate(entry.modelData.page)
                Keys.onReturnPressed: if (entry.available) menu.navigate(entry.modelData.page)
            }
        }
    }
}
