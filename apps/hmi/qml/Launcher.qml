import QtQuick
import OAS.HMI

// The single point of navigation: one button in the bottom-left corner that
// names where you are. Pressing it floats the destination menu out.
//
// This trades one extra touch for a screen that is otherwise undivided, so the
// menu items are oversized and the current screen is always labelled — a
// driver never has to open the menu to find out where they are.
Rectangle {
    id: launcher

    property int current: Nav.home
    property bool open: false
    signal toggled()

    implicitHeight: Tokens.launcherHeight
    implicitWidth: Math.max(240, row.implicitWidth + Tokens.s6 * 2)
    color: launcher.open ? Tokens.ink : Tokens.surface
    activeFocusOnTab: true
    Accessible.name: "메뉴 · 현재 화면 " + Nav.title(launcher.current)
    Accessible.role: Accessible.Button

    Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: launcher.activeFocus ? 2 : Tokens.hairline
        border.color: launcher.activeFocus ? Tokens.ink : Tokens.line
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: Tokens.s6
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s4

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Repeater {
                model: 3
                delegate: Rectangle {
                    width: 20
                    height: 2
                    color: launcher.open ? Tokens.onInk : Tokens.ink
                    Behavior on color { ColorAnimation { duration: Tokens.mFast } }
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: "메뉴"
                color: launcher.open ? Tokens.wash(Tokens.onInk, 0.6) : Tokens.inkTertiary
                font.pixelSize: Tokens.caption
            }

            Text {
                text: Nav.title(launcher.current)
                color: launcher.open ? Tokens.onInk : Tokens.ink
                font.pixelSize: Tokens.bodyLg
                font.weight: Tokens.weightDemi
                Behavior on color { ColorAnimation { duration: Tokens.mFast } }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { launcher.forceActiveFocus(); launcher.toggled() }
    }

    Keys.onSpacePressed: launcher.toggled()
    Keys.onReturnPressed: launcher.toggled()
}
