import QtQuick
import OAS.HMI

Rectangle {
    id: badge

    property string text: ""
    property color tone: Tokens.accent
    property string iconName: ""

    implicitWidth: row.implicitWidth + Tokens.s5
    implicitHeight: 34
    radius: Tokens.rPill
    color: Tokens.wash(badge.tone)
    border.width: 1
    border.color: Tokens.wash(badge.tone, 0.25)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Tokens.s2

        Icon {
            name: badge.iconName
            visible: badge.iconName.length > 0
            size: Tokens.iconSm
            tone: badge.tone
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: badge.text
            color: badge.tone
            font.pixelSize: Tokens.caption
            font.weight: Tokens.weightDemi
            font.letterSpacing: 1.2
        }
    }
}
