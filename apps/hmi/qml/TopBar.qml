import QtQuick
import OAS.HMI

// Masthead. Product mark, current screen, connection and theme — the constants
// that must never be covered by a screen.
Rectangle {
    id: bar

    property string clock: ""
    property string screenTitle: ""
    property string connection: ""
    property color connectionTone: Tokens.inkSecondary
    property bool synthetic: false
    property string outsideTemp: ""
    property bool outsideValid: false
    signal appearanceToggled()

    implicitHeight: Tokens.railHeight
    color: Tokens.surface

    Divider { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Tokens.s6
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s5

        // Product mark: a four-square checker, drawn rather than imported.
        Grid {
            anchors.verticalCenter: parent.verticalCenter
            columns: 2
            spacing: 2

            Repeater {
                model: [true, false, false, true]
                delegate: Rectangle {
                    required property bool modelData
                    width: 9; height: 9
                    color: modelData ? Tokens.ink : Tokens.surfaceInk
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: bar.screenTitle
            color: Tokens.ink
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightDemi
        }

        StatusBadge {
            anchors.verticalCenter: parent.verticalCenter
            text: bar.connection
            tone: bar.connectionTone
        }

        StatusBadge {
            anchors.verticalCenter: parent.verticalCenter
            visible: bar.synthetic
            text: "합성 상태"
            tone: Tokens.warning
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.s6
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s5

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.s2

            Caption { anchors.verticalCenter: parent.verticalCenter; text: "실외" }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: bar.outsideValid ? bar.outsideTemp : "—"
                color: bar.outsideValid ? Tokens.ink : Tokens.inkTertiary
                font.pixelSize: Tokens.bodyMd
                font.weight: Tokens.weightMedium
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: bar.clock
            color: Tokens.ink
            font.pixelSize: Tokens.bodyLg
            font.weight: Tokens.weightDemi
        }

        OasIconButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: Tokens.dark ? "light" : "adas"
            size: Tokens.touchMin
            variant: "ghost"
            text: Tokens.dark ? "밝은 화면으로 전환" : "어두운 화면으로 전환"
            onClicked: bar.appearanceToggled()
        }
    }
}
