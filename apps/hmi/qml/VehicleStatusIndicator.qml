import QtQuick
import OAS.HMI

// Dot cluster for corner-addressed state. An invalid corner is an outline, so
// "unknown" is never mistaken for "fine".
Flow {
    id: cluster

    // [{ id, label, state, valid }] where state is ok | open | warn | critical
    property var items: []
    property string title: ""

    spacing: Tokens.s4

    function toneFor(state) {
        switch (state) {
        case "ok": return Tokens.success
        case "open": return Tokens.warning
        case "warn": return Tokens.warning
        case "critical": return Tokens.critical
        default: return Tokens.textTertiary
        }
    }

    Repeater {
        model: cluster.items

        delegate: Row {
            required property var modelData
            spacing: Tokens.s2

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 12; height: 12; radius: 6
                color: modelData.valid ? cluster.toneFor(modelData.state) : "transparent"
                border.width: modelData.valid ? 0 : 1.5
                border.color: Tokens.textTertiary

                Behavior on color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: modelData.valid ? Tokens.textSecondary : Tokens.textTertiary
                font.pixelSize: Tokens.label
            }
        }
    }
}
