import QtQuick
import OAS.HMI

// Turn arrow, distance, road. Sits over the map as a single layer — never a
// stack of cards.
Item {
    id: instruction

    property string turnIcon: "turnStraight"
    property int distanceM: 0
    property string road: ""
    property string detail: ""
    property bool available: false
    property bool overlay: false

    implicitHeight: 112
    implicitWidth: 360

    readonly property string _distance: distanceM >= 1000
        ? (distanceM / 1000).toFixed(1) + " km"
        : distanceM + " m"

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rXl
        color: instruction.overlay ? Tokens.wash(Tokens.surface, 0.92) : "transparent"
        border.width: instruction.overlay ? 1 : 0
        border.color: Tokens.borderStrong
    }

    Icon {
        id: arrow
        anchors.left: parent.left
        anchors.leftMargin: instruction.overlay ? Tokens.s5 : 0
        anchors.verticalCenter: parent.verticalCenter
        name: instruction.available ? instruction.turnIcon : "navigation"
        size: Tokens.iconXl
        tone: instruction.available ? Tokens.accent : Tokens.textTertiary
    }

    Column {
        anchors.left: arrow.right
        anchors.leftMargin: Tokens.s4
        anchors.right: parent.right
        anchors.rightMargin: instruction.overlay ? Tokens.s5 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: instruction.available ? instruction._distance : "경로 없음"
            color: Tokens.textPrimary
            font.pixelSize: Tokens.displaySm
            font.weight: Tokens.weightLight
            font.letterSpacing: -1
        }

        Text {
            text: instruction.available ? instruction.road : "목적지를 설정하면 안내가 표시됩니다"
            width: parent.width
            elide: Text.ElideRight
            color: instruction.available ? Tokens.textSecondary : Tokens.textTertiary
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightMedium
        }

        Text {
            text: instruction.detail
            visible: instruction.available && text.length > 0
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.textTertiary
            font.pixelSize: Tokens.label
        }
    }
}
