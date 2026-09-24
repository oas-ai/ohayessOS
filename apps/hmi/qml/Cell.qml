import QtQuick
import QtQuick.Layouts
import OAS.HMI

// One field of the grid. Square corners, no shadow: the rule around it is the
// only separation it gets.
Rectangle {
    id: cell

    property int padding: Tokens.cellPadding
    property alias spacing: body.spacing
    property alias body: body
    // Overlay children anchor to the whole cell instead of joining the column;
    // anchoring inside the layout is undefined behaviour.
    property alias overlay: overlaySlot.data
    default property alias content: body.data

    color: Tokens.surface
    implicitWidth: body.implicitWidth + padding * 2
    implicitHeight: body.implicitHeight + padding * 2

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: cell.padding
        spacing: Tokens.s2
    }

    Item {
        id: overlaySlot
        anchors.fill: parent
    }
}
