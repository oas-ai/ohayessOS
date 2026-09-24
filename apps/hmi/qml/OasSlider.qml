import QtQuick
import OAS.HMI

// Handle-free slider: the whole filled bar is the drag target, so no precise
// aim is required while driving. The fill follows the finger with no animation;
// only externally changed values animate.
Item {
    id: slider

    property string label: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0
    property string displayText: ""
    property string iconName: ""
    signal moved(real value)

    implicitHeight: Tokens.touchBase
    implicitWidth: 240
    activeFocusOnTab: enabled
    Accessible.name: slider.label
    Accessible.role: Accessible.Slider

    readonly property real _span: to - from
    readonly property real _ratio: _span > 0 ? Math.max(0, Math.min(1, (value - from) / _span)) : 0
    property bool _dragging: false

    function _commit(px) {
        const ratio = Math.max(0, Math.min(1, px / Math.max(1, track.width)))
        let next = from + ratio * _span
        if (stepSize > 0) next = from + Math.round((next - from) / stepSize) * stepSize
        next = Math.max(from, Math.min(to, next))
        if (next !== value) { value = next; moved(next) }
    }

    Rectangle {
        id: track
        anchors.fill: parent
        radius: Tokens.rLg
        color: Tokens.surfaceAlt
        border.width: slider.activeFocus ? 2 : 1
        border.color: slider.activeFocus ? Tokens.accent : Tokens.borderStrong
        clip: true

        Rectangle {
            width: Math.round(track.width * slider._ratio)
            height: track.height
            color: slider.enabled ? Tokens.accent : Tokens.textDisabled
            // Radius only matters while the fill is narrow; the clip handles the rest.
            radius: Tokens.rLg

            Behavior on width {
                enabled: !slider._dragging
                NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut }
            }
        }

        Icon {
            name: slider.iconName
            visible: slider.iconName.length > 0
            anchors.left: parent.left
            anchors.leftMargin: Tokens.s4
            anchors.verticalCenter: parent.verticalCenter
            size: Tokens.iconMd
            tone: Tokens.textPrimary
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: slider.iconName.length > 0 ? Tokens.s4 * 2 + Tokens.iconMd : Tokens.s4
            anchors.verticalCenter: parent.verticalCenter
            text: slider.label
            color: Tokens.textPrimary
            font.pixelSize: Tokens.bodyMd
            font.weight: Tokens.weightMedium
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: Tokens.s4
            anchors.verticalCenter: parent.verticalCenter
            text: slider.displayText
            visible: slider.displayText.length > 0
            color: Tokens.textPrimary
            font.pixelSize: Tokens.bodyMd
            font.weight: Tokens.weightDemi
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: slider.enabled
        onPressed: function (mouse) { slider.forceActiveFocus(); slider._dragging = true; slider._commit(mouse.x) }
        onPositionChanged: function (mouse) { if (slider._dragging) slider._commit(mouse.x) }
        onReleased: slider._dragging = false
        onCanceled: slider._dragging = false
    }

    Keys.onLeftPressed: if (enabled) _commit((_ratio * track.width) - Math.max(4, track.width / 20))
    Keys.onRightPressed: if (enabled) _commit((_ratio * track.width) + Math.max(4, track.width / 20))
}
