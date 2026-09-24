import QtQuick
import OAS.HMI

// A filled run, an optional hatched run for what is projected rather than
// measured, and a tick for the target. The hatch is what keeps a projection
// from reading as a fact.
Item {
    id: meter

    // All three are 0..1 of the track.
    property real value: 0
    property real projection: 0
    property real target: -1
    property color fill: Tokens.ink

    implicitHeight: 14
    implicitWidth: 160

    Rectangle {
        id: track
        anchors.fill: parent
        color: Tokens.surfaceInk
    }

    Rectangle {
        height: parent.height
        width: parent.width * Math.max(0, Math.min(1, meter.value))
        color: meter.fill
        Behavior on width { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
    }

    Canvas {
        id: hatch
        x: parent.width * Math.max(0, Math.min(1, meter.value))
        width: parent.width * Math.max(0, Math.min(1, meter.projection - meter.value))
        height: parent.height
        visible: width > 1
        renderStrategy: Canvas.Immediate

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections { target: Tokens; function onDarkChanged() { hatch.requestPaint() } }

        onPaint: {
            const c = getContext("2d")
            c.reset()
            c.strokeStyle = Tokens.ink
            c.lineWidth = 2
            for (let x = -height; x < width + height; x += 6) {
                c.beginPath(); c.moveTo(x, height); c.lineTo(x + height, 0); c.stroke()
            }
        }
    }

    Rectangle {
        visible: meter.target >= 0
        x: Math.min(parent.width - width, parent.width * meter.target)
        width: 2
        height: parent.height + Tokens.s2
        y: -Tokens.s1
        color: Tokens.ink
    }
}
