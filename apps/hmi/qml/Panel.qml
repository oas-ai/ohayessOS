import QtQuick
import OAS.HMI

// Level 1 surface container. Panels are never nested; use a Divider or a
// surfaceAlt block to separate regions inside one panel.
Rectangle {
    property int padding: Tokens.s5
    property bool emphasised: false

    radius: Tokens.rXl
    color: Tokens.surface
    border.width: 1
    border.color: emphasised ? Tokens.accent : Tokens.borderSubtle

    Behavior on border.color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
}
