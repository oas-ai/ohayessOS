import QtQuick
import OAS.HMI

// Temperature is set by dragging the whole zone vertically; the buttons are a
// secondary path for precise taps. No aiming at a small handle while driving.
Item {
    id: zone

    property string label: ""
    property real value: 21.0
    property real from: 17.0
    property real to: 27.0
    property real stepSize: 0.5
    property bool valid: true
    signal moved(real value)

    implicitHeight: Tokens.touchLarge * 3
    implicitWidth: 240
    activeFocusOnTab: enabled
    Accessible.name: label
    Accessible.role: Accessible.Slider

    property real _dragOrigin: 0
    property real _valueOrigin: 0

    function _apply(next) {
        const clamped = Math.max(from, Math.min(to, Math.round(next / stepSize) * stepSize))
        if (clamped !== value) { value = clamped; moved(clamped) }
    }

    Rectangle {
        anchors.fill: parent
        color: drag.pressed ? Tokens.surfaceAlt : Tokens.surface
        border.width: zone.activeFocus || drag.pressed ? 2 : 0
        border.color: Tokens.ink

        Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }
    }

    Caption {
        anchors.top: parent.top
        anchors.topMargin: Tokens.cellPadding
        anchors.left: parent.left
        anchors.leftMargin: Tokens.cellPadding
        text: zone.label
    }

    Row {
        anchors.centerIn: parent
        spacing: Tokens.s2

        Text {
            id: valueText
            text: zone.valid ? zone.value.toFixed(1) : "—"
            color: zone.valid ? Tokens.ink : Tokens.inkTertiary
            font.pixelSize: Tokens.dataXl
            font.weight: Tokens.weightDemi
            font.letterSpacing: -1.2
        }

        Text {
            anchors.baseline: valueText.baseline
            text: "°C"
            color: Tokens.inkSecondary
            font.pixelSize: Tokens.titleMd
            font.weight: Tokens.weightMedium
        }
    }

    OasIconButton {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        iconName: "minus"
        variant: "ghost"
        size: Tokens.touchLarge
        text: zone.label + " 온도 낮춤"
        enabled: zone.enabled && zone.value > zone.from
        onClicked: zone._apply(zone.value - zone.stepSize)
    }

    OasIconButton {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        iconName: "plus"
        variant: "ghost"
        size: Tokens.touchLarge
        text: zone.label + " 온도 올림"
        enabled: zone.enabled && zone.value < zone.to
        onClicked: zone._apply(zone.value + zone.stepSize)
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        anchors.bottomMargin: Tokens.touchLarge
        enabled: zone.enabled
        onPressed: function (mouse) {
            zone.forceActiveFocus()
            zone._dragOrigin = mouse.y
            zone._valueOrigin = zone.value
        }
        onPositionChanged: function (mouse) {
            if (!pressed) return
            // Upward drag raises the temperature; 12px per 0.5 °C step.
            zone._apply(zone._valueOrigin + (zone._dragOrigin - mouse.y) / 12 * zone.stepSize)
        }
    }

    Keys.onUpPressed: if (enabled) _apply(value + stepSize)
    Keys.onDownPressed: if (enabled) _apply(value - stepSize)
}
