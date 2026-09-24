import QtQuick
import QtQuick.Layouts
import OAS.HMI

// Appears with no delay and cannot be dismissed; only the condition clearing
// removes it. It never changes which screen the driver is on.
Rectangle {
    id: overlay

    property string title: ""
    property string detail: ""
    property string recovery: ""
    property color tone: Tokens.critical

    visible: opacity > 0
    opacity: 0
    color: Tokens.surface

    // Safety information appears instantly and fades only on the way out.
    Behavior on opacity { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    // The full-height bar is the alarm; the panel behind it stays plain.
    Rectangle {
        id: mark
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Tokens.s2
        color: overlay.tone
    }

    Divider { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.s6
        anchors.rightMargin: Tokens.s6
        anchors.topMargin: Tokens.s4
        anchors.bottomMargin: Tokens.s4
        spacing: Tokens.s5

        Icon {
            name: "warning"
            size: Tokens.iconXl
            tone: overlay.tone
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
                text: overlay.title
                color: Tokens.ink
                font.pixelSize: Tokens.titleMd
                font.weight: Tokens.weightDemi
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: overlay.detail
                visible: text.length > 0
                color: Tokens.inkSecondary
                font.pixelSize: Tokens.bodyMd
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Text {
            text: overlay.recovery
            visible: text.length > 0
            color: Tokens.inkTertiary
            font.pixelSize: Tokens.label
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
            Layout.maximumWidth: 320
        }
    }
}
