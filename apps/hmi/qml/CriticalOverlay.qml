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
    color: Tokens.wash(overlay.tone, Tokens.dark ? 0.14 : 0.10)
    radius: Tokens.rXl
    border.width: 1
    border.color: Tokens.wash(overlay.tone, 0.35)

    // Safety information appears instantly and fades only on the way out.
    Behavior on opacity { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 4
        radius: 2
        color: overlay.tone
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Tokens.s5
        anchors.topMargin: Tokens.s5 + Tokens.s1
        spacing: Tokens.s4

        Icon {
            name: "warning"
            size: Tokens.iconXl
            tone: overlay.tone
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: Tokens.s1
            Layout.fillWidth: true

            Text {
                text: overlay.title
                color: Tokens.textPrimary
                font.pixelSize: Tokens.titleSection
                font.weight: Tokens.weightDemi
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: overlay.detail
                visible: text.length > 0
                color: Tokens.textSecondary
                font.pixelSize: Tokens.bodyMd
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: overlay.recovery
                visible: text.length > 0
                color: Tokens.textTertiary
                font.pixelSize: Tokens.label
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
