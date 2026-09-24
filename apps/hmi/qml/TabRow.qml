import QtQuick
import OAS.HMI

// Text-only range tabs. The active one is simply inked and heavier; there is
// no pill, no underline, no box.
Row {
    id: tabs

    property var model: []
    property int currentIndex: 0
    signal activated(int index)

    implicitHeight: Tokens.touchMin
    spacing: Tokens.s6

    Repeater {
        model: tabs.model

        delegate: Item {
            id: tab
            required property int index
            required property string modelData
            readonly property bool selected: tabs.currentIndex === index

            width: labelText.implicitWidth
            height: tabs.height
            activeFocusOnTab: true
            Accessible.name: modelData
            Accessible.role: Accessible.PageTab

            Text {
                id: labelText
                anchors.verticalCenter: parent.verticalCenter
                text: tab.modelData
                color: tab.selected ? Tokens.ink : Tokens.inkSecondary
                font.pixelSize: Tokens.bodyMd
                font.weight: tab.selected ? Tokens.weightDemi : Tokens.weightRegular

                Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -Tokens.s2
                color: "transparent"
                border.width: tab.activeFocus ? 2 : 0
                border.color: Tokens.ink
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Tokens.s2
                onClicked: { tab.forceActiveFocus(); tabs.currentIndex = tab.index; tabs.activated(tab.index) }
            }

            Keys.onSpacePressed: { tabs.currentIndex = tab.index; tabs.activated(tab.index) }
        }
    }
}
