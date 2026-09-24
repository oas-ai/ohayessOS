import QtQuick
import OAS.HMI

// Persistent top strip. No screen draws over it.
Item {
    id: rail

    property string clock: ""
    property string connection: ""
    property color connectionTone: Tokens.textTertiary
    property bool synthetic: false
    property string outsideTemp: ""
    property bool outsideValid: false
    signal appearanceToggled()

    implicitHeight: Tokens.railHeight

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: rail.clock
            color: Tokens.textPrimary
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightMedium
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1; height: Tokens.s5
            color: Tokens.borderStrong
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.s2

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 8; height: 8; radius: 4
                color: rail.connectionTone
                Behavior on color { ColorAnimation { duration: Tokens.mBase } }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rail.connection
                color: rail.connectionTone
                font.pixelSize: Tokens.label
                font.weight: Tokens.weightMedium
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "o a s"
        color: Tokens.textSecondary
        font.pixelSize: Tokens.bodyLg
        font.weight: Tokens.weightMedium
        font.letterSpacing: 2
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s4

        StatusBadge {
            anchors.verticalCenter: parent.verticalCenter
            visible: rail.synthetic
            text: "SYNTHETIC"
            tone: Tokens.warning
            iconName: "warning"
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.s1

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rail.outsideValid ? rail.outsideTemp : "—"
                color: rail.outsideValid ? Tokens.textSecondary : Tokens.textTertiary
                font.pixelSize: Tokens.label
                font.weight: Tokens.weightMedium
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "실외"
                color: Tokens.textTertiary
                font.pixelSize: Tokens.caption
            }
        }

        OasIconButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: Tokens.dark ? "light" : "adas"
            size: Tokens.touchMin
            variant: "ghost"
            text: Tokens.dark ? "밝은 화면으로 전환" : "어두운 화면으로 전환"
            onClicked: rail.appearanceToggled()
        }
    }
}
