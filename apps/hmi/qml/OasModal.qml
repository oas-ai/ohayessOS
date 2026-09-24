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

    Panel {
        anchors.centerIn: parent
        width: Math.min(560, parent.width - Tokens.s8)
        height: layout.implicitHeight + Tokens.s6 * 2
        border.color: Tokens.borderStrong
        scale: modal.open ? 1 : 0.96

        Behavior on scale { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Tokens.s6
            spacing: Tokens.s4

            Text {
                text: modal.title
                color: Tokens.textPrimary
                font.pixelSize: Tokens.titleSection
                font.weight: Tokens.weightDemi
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: modal.detail
                visible: text.length > 0
                color: Tokens.textSecondary
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
