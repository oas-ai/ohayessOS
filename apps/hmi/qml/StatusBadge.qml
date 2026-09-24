import QtQuick
import OAS.HMI

// A square mark and a word. No pill, no tint block — colour here always means
// a safety state, so it stays as plain as possible.
Row {
    id: badge

    property string text: ""
    property color tone: Tokens.inkSecondary

    spacing: Tokens.s2

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        color: badge.tone
        Behavior on color { ColorAnimation { duration: Tokens.mBase } }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: badge.text
        color: badge.tone === Tokens.inkSecondary ? Tokens.inkSecondary : badge.tone
        font.pixelSize: Tokens.caption
        font.weight: Tokens.weightMedium
    }
}
