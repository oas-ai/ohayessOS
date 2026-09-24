import QtQuick
import QtQuick.Layouts
import OAS.HMI

// The grid itself. The board is drawn in rule colour and the cells sit on it
// with a hairline gap, so every separator is exactly one pixel and no cell has
// to know where it is in the layout.
Rectangle {
    id: board

    property int columns: 1
    property alias grid: grid
    default property alias content: grid.data

    color: Tokens.line
    implicitWidth: grid.implicitWidth + Tokens.hairline * 2
    implicitHeight: grid.implicitHeight + Tokens.hairline * 2

    GridLayout {
        id: grid
        anchors.fill: parent
        anchors.margins: Tokens.hairline
        columns: board.columns
        columnSpacing: Tokens.hairline
        rowSpacing: Tokens.hairline
    }
}
