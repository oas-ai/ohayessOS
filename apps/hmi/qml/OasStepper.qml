import QtQuick
import OAS.HMI

// Minus and plus sit at opposite ends with a full value field between them, so
// two opposing actions are never adjacent.
Item {
    id: stepper

    property string label: ""
    property real value: 0
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property int decimals: 0
    property string unit: ""
    signal moved(real value)

    implicitHeight: Tokens.touchLarge
    implicitWidth: 260

    function _apply(delta) {
        const next = Math.max(from, Math.min(to, value + delta))
        if (next !== value) { value = next; moved(next) }
    }

    OasIconButton {
        id: minus
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        iconName: "minus"
        size: Tokens.touchLarge
        text: stepper.label + " 감소"
        enabled: stepper.enabled && stepper.value > stepper.from
        onClicked: stepper._apply(-stepper.stepSize)
        onPressAndHold: repeat.start()
        onReleased: repeat.stop()
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Caption {
            text: stepper.label
            visible: stepper.label.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: Tokens.s1
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: valueText
                text: stepper.value.toFixed(stepper.decimals)
                color: stepper.enabled ? Tokens.textPrimary : Tokens.textDisabled
                font.pixelSize: Tokens.titleSection
                font.weight: Tokens.weightMedium
            }

            Text {
                anchors.baseline: valueText.baseline
                text: stepper.unit
                visible: stepper.unit.length > 0
                color: Tokens.textTertiary
                font.pixelSize: Tokens.label
            }
        }
    }

    OasIconButton {
        id: plus
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        iconName: "plus"
        size: Tokens.touchLarge
        text: stepper.label + " 증가"
        enabled: stepper.enabled && stepper.value < stepper.to
        onClicked: stepper._apply(stepper.stepSize)
        onPressAndHold: repeatUp.start()
        onReleased: repeatUp.stop()
    }

    Timer { id: repeat; interval: 250; repeat: true; onTriggered: stepper._apply(-stepper.stepSize) }
    Timer { id: repeatUp; interval: 250; repeat: true; onTriggered: stepper._apply(stepper.stepSize) }
}
