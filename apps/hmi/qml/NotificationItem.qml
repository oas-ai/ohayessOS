import QtQuick
import OAS.HMI

Item {
    id: item

    property string title: ""
    property string detail: ""
    property string timestamp: ""
    property string iconName: "pulse"
    property color tone: Tokens.textSecondary
    property bool unread: false

    implicitHeight: Tokens.touchLarge
    implicitWidth: 320

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: parent.height - Tokens.s4
        radius: 2
        color: Tokens.accent
        visible: item.unread
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: Tokens.s4
        anchors.verticalCenter: parent.verticalCenter
        name: item.iconName
        size: Tokens.iconMd
        tone: item.tone
    }

    Column {
        anchors.left: glyph.right
        anchors.leftMargin: Tokens.s4
        anchors.right: time.left
        anchors.rightMargin: Tokens.s3
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: item.title
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.textPrimary
            font.pixelSize: Tokens.bodyMd
            font.weight: item.unread ? Tokens.weightMedium : Tokens.weightRegular
        }

        Text {
            text: item.detail
            visible: text.length > 0
            width: parent.width
            elide: Text.ElideRight
            color: Tokens.textTertiary
            font.pixelSize: Tokens.label
        }
    }

    Text {
        id: time
        anchors.right: parent.right
        anchors.rightMargin: Tokens.s4
        anchors.verticalCenter: parent.verticalCenter
        text: item.timestamp
        color: Tokens.textTertiary
        font.pixelSize: Tokens.caption
    }
}
