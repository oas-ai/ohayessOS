import QtQuick
import OAS.HMI

// Top-down vehicle state surface. Not a camera view and not sensed
// surroundings: every element is driven by a named signal, and a signal that is
// not valid is drawn as an outline rather than as a healthy state.
//
// Anything that moves every frame — road flow, indicator blink, charge fill —
// is a plain QML item. The Canvas holds only the body, which repaints when a
// vehicle signal changes and never on a timer. That keeps the software
// renderer and an embedded GPU on the same frame budget.
Item {
    id: visual

    // Canonical VehicleState signals.
    property string gear: "—"
    property bool gearValid: false
    property real speedKph: 0
    property bool speedValid: false
    property real steeringAngleDeg: 0
    property bool steeringValid: false
    property var doors: []
    property bool doorsValid: false
    property var seatbelts: []
    property bool seatbeltsValid: false

    // Provider-backed signals.
    property bool lightsOn: false
    property string turnSignal: "none"
    property bool charging: false
    property bool lanesDetected: false
    property var surroundings: []
    property var parkingSensors: []
    property bool showSurroundings: false

    readonly property bool driving: speedValid && speedKph > 3
    readonly property bool anyDoorOpen: {
        for (let i = 0; i < doors.length; i++) {
            if (doors[i] && doors[i].valid && doors[i].open) return true
        }
        return false
    }
    property real steer: steeringValid ? Math.max(-35, Math.min(35, steeringAngleDeg)) : 0
    Behavior on steer { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }

    // Logical drawing space; one scale factor keeps every child in proportion.
    readonly property real _scale: Math.min(width / 400, height / 700)

    // Ground fills the whole surface; the car keeps its own proportions on top.
    Rectangle {
        id: ground
        anchors.fill: parent
        radius: Tokens.rLg
        color: Tokens.ground
        clip: true
    }

    Item {
        id: board
        width: 400
        height: 700
        anchors.centerIn: parent
        scale: visual._scale

        Item {
            anchors.fill: parent

            // Road flow: eight rectangles translated together. No repaint, and
            // it stops the moment speed is not a valid signal.
            Item {
                id: flow
                anchors.fill: parent
                property real offset: 0

                Repeater {
                    model: 8
                    delegate: Rectangle {
                        required property int index
                        y: (index * 120 + flow.offset) % 960 - 120
                        x: (400 - width) / 2
                        width: visual._scale > 0 ? visual.width / visual._scale : 400
                        height: 1
                        color: Tokens.borderSubtle
                    }
                }
            }

            Timer {
                interval: 60
                repeat: true
                running: visual.driving && visual.visible
                onTriggered: flow.offset = (flow.offset + Math.min(26, visual.speedKph / 4)) % 960
            }

            // Lane markings appear only when the provider reports detection.
            Repeater {
                model: visual.lanesDetected ? [64, 336] : []
                delegate: Rectangle {
                    required property int modelData
                    x: modelData - 2
                    width: 4
                    height: board.height
                    color: Tokens.wash(Tokens.accent, 0.5)
                }
            }

            // Surrounding traffic as reported, never as inference.
            Repeater {
                model: visual.showSurroundings ? visual.surroundings : []
                delegate: Rectangle {
                    required property var modelData
                    readonly property real h: modelData.kind === "truck" ? 150 : 108
                    x: 200 + modelData.lane * 122 - 52
                    y: 350 - (modelData.distance - 0.5) * 620 - h / 2
                    width: 104
                    height: h
                    radius: Tokens.rMd
                    color: Tokens.surfaceRaised
                    border.width: 2
                    border.color: Tokens.borderStrong
                    Behavior on y { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                }
            }
        }

        // ── Parking proximity ─────────────────────────────────────────────
        Repeater {
            model: visual.parkingSensors

            delegate: Item {
                id: sensor
                required property int index
                required property var modelData
                readonly property real level: Number(modelData)
                readonly property int slots: Math.max(1, Math.floor(visual.parkingSensors.length / 2))
                readonly property bool rear: index >= visual.parkingSensors.length / 2
                readonly property int slot: rear ? index - slots : index

                visible: level > 0.05
                x: 120 + slot * (160 / Math.max(1, slots - 1)) - 70
                y: (rear ? 578 : 122) - 70
                width: 140
                height: 140

                Repeater {
                    model: 3
                    delegate: Rectangle {
                        required property int index
                        visible: sensor.level * 3 >= index
                        anchors.centerIn: parent
                        width: (26 + index * 20) * 2
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 6
                        border.color: sensor.level > 0.7 ? Tokens.critical
                            : sensor.level > 0.4 ? Tokens.warning : Tokens.success
                    }
                }

                // Masks the half of each ring that points into the car, leaving an arc.
                Rectangle {
                    x: 0
                    y: sensor.rear ? 70 : -70
                    width: 140
                    height: 70
                    color: ground.color
                }
            }
        }

        // ── Wheels ────────────────────────────────────────────────────────
        Repeater {
            model: [
                { x: 112, y: 214, steered: true },
                { x: 288, y: 214, steered: true },
                { x: 112, y: 486, steered: false },
                { x: 288, y: 486, steered: false }
            ]

            delegate: Rectangle {
                required property var modelData
                x: modelData.x - 15
                y: modelData.y - 42
                width: 30
                height: 84
                radius: 12
                color: Tokens.tyre
                rotation: modelData.steered ? visual.steer : 0
            }
        }

        // ── Body, doors, lamps and seats ──────────────────────────────────
        Canvas {
            id: canvas
            anchors.fill: parent
            renderStrategy: Canvas.Immediate

            Connections { target: Tokens; function onDarkChanged() { canvas.requestPaint() } }
            Connections {
                target: visual
                function onDoorsChanged() { canvas.requestPaint() }
                function onSeatbeltsChanged() { canvas.requestPaint() }
                function onLightsOnChanged() { canvas.requestPaint() }
            }

            // Door swing is the only animated value the canvas tracks, and it
            // settles in 300 ms rather than running continuously.
            property real open: visual.doorsValid && visual.anyDoorOpen ? 1 : 0
            Behavior on open { NumberAnimation { duration: Tokens.mSlow; easing.type: Tokens.easeInOut } }
            onOpenChanged: requestPaint()

            function doorState(id) {
                for (let i = 0; i < visual.doors.length; i++) {
                    if (visual.doors[i] && visual.doors[i].id === id) return visual.doors[i]
                }
                return { valid: false, open: false }
            }

            function beltState(id) {
                for (let i = 0; i < visual.seatbelts.length; i++) {
                    if (visual.seatbelts[i] && visual.seatbelts[i].id === id) return visual.seatbelts[i]
                }
                return { valid: false, latched: false }
            }

            onPaint: {
                const c = getContext("2d")
                c.reset()
                drawBody(c)
                drawDoors(c)
                drawLamps(c)
                drawSeats(c)
            }

            function drawBody(c) {
                const g = c.createLinearGradient(105, 130, 295, 570)
                g.addColorStop(0, Tokens.bodyHigh)
                g.addColorStop(0.45, Tokens.bodyMid)
                g.addColorStop(1, Tokens.bodyLow)
                c.fillStyle = g
                c.strokeStyle = Tokens.borderStrong
                c.lineWidth = 2
                roundRect(c, 105, 130, 190, 440, 54)
                c.fill(); c.stroke()

                c.fillStyle = Tokens.glazing
                roundRect(c, 128, 196, 144, 62, 26); c.fill()
                roundRect(c, 124, 268, 152, 128, 22); c.fill()
                roundRect(c, 128, 452, 144, 58, 24); c.fill()

                c.strokeStyle = Tokens.wash(Tokens.textPrimary, 0.08)
                c.lineWidth = 2
                c.beginPath(); c.moveTo(200, 278); c.lineTo(200, 388); c.stroke()
            }

            function drawDoors(c) {
                const panels = [
                    { id: "frontLeft",  x: 105, y: 282, side: -1 },
                    { id: "frontRight", x: 295, y: 282, side: 1 },
                    { id: "rearLeft",   x: 105, y: 386, side: -1 },
                    { id: "rearRight",  x: 295, y: 386, side: 1 }
                ]
                for (const p of panels) {
                    const state = doorState(p.id)
                    const isOpen = state.valid && state.open
                    c.save()
                    c.translate(p.x, p.y)
                    c.rotate(p.side * (isOpen ? open * 30 : 0) * Math.PI / 180)
                    c.fillStyle = isOpen ? Tokens.wash(Tokens.warning, 0.35) : Tokens.doorPanel
                    c.strokeStyle = !state.valid ? Tokens.textTertiary : isOpen ? Tokens.warning : Tokens.borderStrong
                    c.lineWidth = isOpen ? 3 : 2
                    roundRect(c, p.side < 0 ? -12 : -6, 0, 18, 88, 7)
                    if (state.valid) c.fill()
                    c.stroke()
                    c.restore()
                }
            }

            function drawLamps(c) {
                c.fillStyle = visual.lightsOn ? Tokens.accentHi : Tokens.wash(Tokens.textSecondary, 0.35)
                roundRect(c, 132, 138, 44, 14, 7); c.fill()
                roundRect(c, 224, 138, 44, 14, 7); c.fill()
                c.fillStyle = Tokens.wash(Tokens.critical, visual.lightsOn ? 0.9 : 0.4)
                roundRect(c, 132, 550, 44, 14, 7); c.fill()
                roundRect(c, 224, 550, 44, 14, 7); c.fill()
            }

            function drawSeats(c) {
                const seats = [
                    { id: "driver",    x: 163, y: 306 },
                    { id: "passenger", x: 237, y: 306 },
                    { id: "rearLeft",  x: 163, y: 368 },
                    { id: "rearRight", x: 237, y: 368 }
                ]
                for (const s of seats) {
                    const state = beltState(s.id)
                    c.lineWidth = 2.5
                    if (!state.valid) {
                        // Unknown is an outline, never a healthy dot.
                        c.strokeStyle = Tokens.textTertiary
                        c.beginPath(); c.arc(s.x, s.y, 11, 0, Math.PI * 2); c.stroke()
                        continue
                    }
                    c.fillStyle = state.latched ? Tokens.wash(Tokens.success, 0.9) : Tokens.critical
                    c.beginPath(); c.arc(s.x, s.y, 11, 0, Math.PI * 2); c.fill()
                    if (state.latched) continue
                    c.strokeStyle = Tokens.onAccent
                    c.beginPath()
                    c.moveTo(s.x - 4, s.y - 4); c.lineTo(s.x + 4, s.y + 4)
                    c.moveTo(s.x + 4, s.y - 4); c.lineTo(s.x - 4, s.y + 4)
                    c.stroke()
                }
            }

            function roundRect(c, x, y, w, h, r) {
                const k = Math.min(r, w / 2, h / 2)
                c.beginPath()
                c.moveTo(x + k, y)
                c.lineTo(x + w - k, y); c.quadraticCurveTo(x + w, y, x + w, y + k)
                c.lineTo(x + w, y + h - k); c.quadraticCurveTo(x + w, y + h, x + w - k, y + h)
                c.lineTo(x + k, y + h); c.quadraticCurveTo(x, y + h, x, y + h - k)
                c.lineTo(x, y + k); c.quadraticCurveTo(x, y, x + k, y)
                c.closePath()
            }
        }

        // ── Turn indicators ───────────────────────────────────────────────
        // Blinking is the legal meaning of the signal, so this loop is allowed.
        Repeater {
            model: [
                { side: "left", x: 74 },
                { side: "right", x: 310 }
            ]

            delegate: Rectangle {
                required property var modelData
                readonly property bool armed: visual.turnSignal === modelData.side || visual.turnSignal === "hazard"
                x: modelData.x
                y: 300
                width: 16
                height: 100
                radius: 8
                color: Tokens.warning
                opacity: armed && blink.on ? 1 : 0
            }
        }

        Timer {
            id: blink
            property bool on: false
            interval: 500
            repeat: true
            running: visual.turnSignal !== "none" && visual.visible
            onTriggered: on = !on
            onRunningChanged: if (!running) on = false
        }

        // ── Charging ──────────────────────────────────────────────────────
        // The one permitted looping animation, and it moves a rectangle rather
        // than forcing a canvas repaint.
        Rectangle {
            visible: visual.charging
            x: 168; y: 408
            width: 64; height: 34
            radius: Tokens.rSm
            color: Tokens.wash(Tokens.success, 0.25)
            clip: true

            Rectangle {
                id: chargeFill
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 58
                radius: Tokens.rSm - 2
                color: Tokens.success
                height: 11

                SequentialAnimation on height {
                    running: visual.charging && visual.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 11; to: 31; duration: 1400; easing.type: Tokens.easeInOut }
                    NumberAnimation { from: 31; to: 11; duration: 0 }
                }
            }
        }
    }
}
