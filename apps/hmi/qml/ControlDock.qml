import QtQuick
import OAS.HMI

// Floating, always present. Screen changes never remove it.
Item {
    id: dock

    property int selected: Nav.home
    signal navigate(int destination)

    implicitHeight: Tokens.dockHeight

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rDock
        color: Tokens.surface
        border.width: 1
        border.color: Tokens.borderStrong

        // Level 3 lift without a blur shader, so software and embedded
        // renderers produce the same result.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Tokens.wash(Tokens.textPrimary, 0.03) }
                GradientStop { position: 0.6; color: "transparent" }
            }
        }
    }

    readonly property real _itemWidth: (width - Tokens.s2 * 2) / Nav.dock.length

    Rectangle {
        id: indicator
        x: Tokens.s2 + dock.selected * dock._itemWidth + Tokens.s1
        y: Tokens.s2
        width: dock._itemWidth - Tokens.s1 * 2
        height: dock.height - Tokens.s2 * 2
        radius: Tokens.rLg
        color: Tokens.accentWash
        border.width: 1
        border.color: Tokens.wash(Tokens.accent, 0.3)
        visible: dock.selected < Nav.dock.length

        Behavior on x { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
        Behavior on width { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
    }

    Row {
        x: Tokens.s2
        y: Tokens.s2
        width: parent.width - Tokens.s2 * 2
        height: parent.height - Tokens.s2 * 2

        Repeater {
            model: Nav.dock

            delegate: Item {
                id: entry
                required property int index
                required property var modelData
                readonly property bool selected: dock.selected === index

                width: dock._itemWidth
                height: parent.height
                activeFocusOnTab: true
                Accessible.name: modelData.label
                Accessible.role: Accessible.Button

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Tokens.s1
                    radius: Tokens.rLg
                    color: hover.hovered && !entry.selected ? Tokens.wash(Tokens.textSecondary, 0.08) : "transparent"
                    border.width: entry.activeFocus ? 2 : 0
                    border.color: Tokens.accent

                    Behavior on color { ColorAnimation { duration: Tokens.mFast } }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Tokens.s1

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: entry.modelData.icon
                        size: Tokens.iconLg
                        tone: Tokens.textSecondary
                        active: entry.selected
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: entry.modelData.label
                        color: entry.selected ? Tokens.textPrimary : Tokens.textSecondary
                        font.pixelSize: Tokens.label
                        font.weight: entry.selected ? Tokens.weightDemi : Tokens.weightRegular

                        Behavior on color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                    }
                }

                HoverHandler { id: hover }

                MouseArea {
                    anchors.fill: parent
                    onClicked: { entry.forceActiveFocus(); dock.navigate(entry.index) }
                }

                Keys.onSpacePressed: dock.navigate(entry.index)
                Keys.onReturnPressed: dock.navigate(entry.index)
            }
        }
    }
}
