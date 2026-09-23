import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OAS.HMI
GlassPanel {
    id: dock
    property int selected: 0
    signal navigate(int destination)
    implicitHeight: 76
    radius: 27
    RowLayout {
        anchors.fill: parent; anchors.margins: 9; spacing: 6
        Repeater {
            model: ["주행", "미디어", "신호", "차량"]
            delegate: Button {
                id: entry
                required property string modelData
                required property int index
                Layout.fillWidth: true; Layout.fillHeight: true
                text: modelData
                Accessible.name: modelData
                onClicked: dock.navigate(index)
                contentItem: Text { text: entry.text; color: dock.selected === entry.index ? Theme.text : Theme.muted; font.pixelSize: 16; font.weight: Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle {
                    radius: 19
                    color: dock.selected === entry.index ? "#283c50" : entry.hovered ? "#1c293b" : "transparent"
                    border.color: entry.activeFocus ? Theme.cyan : dock.selected === entry.index ? "#416077" : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motion } }
                }
            }
        }
    }
}
