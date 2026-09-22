import QtQuick
import OAS.HMI
Rectangle {
    property string text: ""
    property color tone: Theme.cyan
    implicitWidth: label.implicitWidth + 40
    implicitHeight: 34
    radius: 17
    color: Qt.rgba(tone.r, tone.g, tone.b, 0.10)
    border.color: Qt.rgba(tone.r, tone.g, tone.b, 0.25)
    Text { id: label; anchors.centerIn: parent; text: parent.text; color: parent.tone; font.pixelSize: 12; font.weight: Font.DemiBold; font.letterSpacing: 1.3 }
}
