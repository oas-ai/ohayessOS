import QtQuick
import QtQuick.Layouts
import OAS.HMI

// Rendered wherever a provider reports connected == false. A disconnected area
// always says what it is waiting for; it is never left blank.
ColumnLayout {
    id: empty

    property string iconName: "pulse"
    property string title: ""
    property string detail: ""
    property string badge: ""

    spacing: Tokens.s3

    Icon {
        name: empty.iconName
        size: Tokens.iconXl
        tone: Tokens.textTertiary
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Tokens.s1
    }

    Text {
        text: empty.title
        color: Tokens.textSecondary
        font.pixelSize: Tokens.bodyLg
        font.weight: Tokens.weightMedium
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    Text {
        text: empty.detail
        visible: empty.detail.length > 0
        color: Tokens.textTertiary
        font.pixelSize: Tokens.label
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: 420
    }

    StatusBadge {
        text: empty.badge
        visible: empty.badge.length > 0
        tone: Tokens.textTertiary
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Tokens.s1
    }
}
