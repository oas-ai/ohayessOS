import QtQuick
import OAS.HMI

// Flat bars, one of them inked to mark the current period. No axis, no grid —
// the row of cells already carries the structure.
Item {
    id: series

    property var values: []
    property int highlight: -1
    property int gap: Tokens.s2
    readonly property real maximum: {
        let top = 0
        for (let i = 0; i < values.length; i++) top = Math.max(top, Number(values[i]))
        return top > 0 ? top : 1
    }

    implicitHeight: 48
    implicitWidth: 120

    Row {
        anchors.fill: parent
        spacing: series.gap

        Repeater {
            model: series.values

            delegate: Item {
                required property int index
                required property var modelData
                width: (series.width - series.gap * Math.max(0, series.values.length - 1)) / Math.max(1, series.values.length)
                height: series.height

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(3, parent.height * (Number(modelData) / series.maximum))
                    color: index === series.highlight ? Tokens.ink : Tokens.surfaceInk

                    Behavior on height { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                }
            }
        }
    }
}
