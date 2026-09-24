import QtQuick
import QtQuick.Layouts
import OAS.HMI

// Reserved for destructive confirmations and, while driving, safety only.
Item {
    id: modal

    property string title: ""
    property string detail: ""
    property string confirmText: "확인"
    property string cancelText: "취소"
    property bool destructive: false
    property bool open: false
    signal accepted()
    signal rejected()

    anchors.fill: parent ? parent : undefined
    visible: opacity > 0
    opacity: open ? 1 : 0
    enabled: open

    Behavior on opacity { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    Rectangle {
        anchors.fill: parent
        color: Tokens.scrim
        MouseArea { anchors.fill: parent; onClicked: { modal.open = false; modal.rejected() } }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(620, parent.width - Tokens.s8 * 2)
        height: layout.implicitHeight + Tokens.s7 * 2
        color: Tokens.surface
        border.width: Tokens.hairline
        border.color: Tokens.lineStrong

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Tokens.s7
            spacing: Tokens.s4

            Text {
                text: modal.title
                color: Tokens.ink
                font.pixelSize: Tokens.titleMd
                font.weight: Tokens.weightDemi
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: modal.detail
                visible: text.length > 0
                color: Tokens.inkSecondary
                font.pixelSize: Tokens.bodyMd
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Tokens.s3
                Layout.topMargin: Tokens.s2
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                OasButton {
                    text: modal.cancelText
                    variant: "ghost"
                    size: Tokens.touchLarge
                    onClicked: { modal.open = false; modal.rejected() }
                }

                OasButton {
                    text: modal.confirmText
                    variant: modal.destructive ? "danger" : "primary"
                    size: Tokens.touchLarge
                    onClicked: { modal.open = false; modal.accepted() }
                }
            }
        }
    }
}
