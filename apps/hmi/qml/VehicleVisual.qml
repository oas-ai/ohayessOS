import QtQuick
import OAS.HMI

// Top-down vehicle state surface, drawn flat and monochrome to match the grid.
// Not a camera view and not sensed surroundings: every element is driven by a
// named signal, and a signal that is not valid is drawn as an outline rather
// than as a healthy state.
//
// Anything that moves every frame is a plain QML item; the Canvas repaints only
// when a vehicle signal changes, so the software renderer and an embedded GPU
// hold the same frame budget.
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

    // The car is always 400x700; the board widens to three lanes (a 3.5 m lane
    // against a 1.9 m body) when there is traffic to place.
    readonly property bool _wide: lanesDetected || showSurroundings
    readonly property int _laneWidth: 350
    readonly property int _boardWidth: _wide ? _laneWidth * 3 + 110 : 264
    readonly property int _boardHeight: _wide ? 700 : 516
    readonly property real _scale: Math.min(width / _boardWidth, height / _boardHeight)

    Rectangle {
        id: ground
        anchors.fill: parent
        color: Tokens.surfaceAlt
        clip: true
    }

    Item {
        id: board
        width: visual._boardWidth
        height: visual._boardHeight
        anchors.centerIn: parent
        scale: visual._scale
        readonly property real centre: width / 2

        Item {
            anchors.fill: parent

            // Road flow: rules translated together. No repaint, and it stops
            // the moment speed is not a valid signal.
            Item {
                id: flow
                anchors.fill: parent
                property real offset: 0

                Repeater {
                    model: 8
                    delegate: Rectangle {
                        required property int index
                        y: (index * 120 + flow.offset) % 960 - 120
                        x: (board.width - width) / 2
                        width: visual._scale > 0 ? visual.width / visual._scale : board.width
                        height: Tokens.hairline
                        color: Tokens.line
                    }
                }
            }

            Timer {
                interval: 60
                repeat: true
                running: visual.driving && visual.visible
                onTriggered: flow.offset = (flow.offset + Math.min(26, visual.speedKph / 4)) % 960
            }

            // Both edges of the ego lane, and the outer edge of each neighbour.
            Repeater {
                model: visual.lanesDetected ? [-1.5, -0.5, 0.5, 1.5] : []
                delegate: Rectangle {
                    required property real modelData
                    x: board.centre + modelData * visual._laneWidth - 2
                    width: 4
                    height: board.height
                    color: Math.abs(modelData) < 1 ? Tokens.lineStrong : Tokens.line
                }
            }

            // Surrounding traffic as reported, never as inference.
            Repeater {
                model: visual.showSurroundings ? visual.surroundings : []
                delegate: Rectangle {
                    required property var modelData
                    readonly property real h: modelData.kind === "truck" ? 150 : 108
                    x: board.centre + modelData.lane * visual._laneWidth - 52
                    y: 350 - (modelData.distance - 0.5) * 620 - h / 2
                    width: 104
                    height: h
                    color: "transparent"
                    border.width: 3
                    border.color: Tokens.inkTertiary
                    Behavior on y { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                }
            }
        }

        Item {
            id: car
            width: 400
            height: 700
            anchors.centerIn: parent

            // ── Parking proximity ─────────────────────────────────────────
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
                            border.width: 5
                            border.color: sensor.level > 0.7 ? Tokens.critical
                                : sensor.level > 0.4 ? Tokens.warning : Tokens.success
                        }
                    }

                    // Masks the half of each ring that points into the car.
                    Rectangle {
                        x: 0
                        y: sensor.rear ? 70 : -70
                        width: 140
                        height: 70
                        color: ground.color
                    }
                }
            }

            // ── Wheels ────────────────────────────────────────────────────
            Repeater {
                model: [
                    { x: 112, y: 214, steered: true },
                    { x: 288, y: 214, steered: true },
                    { x: 112, y: 486, steered: false },
                    { x: 288, y: 486, steered: false }
                ]

                delegate: Rectangle {
                    required property var modelData
                    x: modelData.x - 14
                    y: modelData.y - 42
                    width: 28
                    height: 84
                    color: Tokens.ink
                    rotation: modelData.steered ? visual.steer : 0
                }
            }

            // ── Body, doors, lamps and seats ──────────────────────────────
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

                // The only animated value the canvas tracks, and it settles in
                // 260 ms rather than running continuously.
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
                    // Flat silhouette with a hairline outline: the grid's own
                    // vocabulary rather than a rendered material.
                    c.fillStyle = Tokens.surface
                    c.strokeStyle = Tokens.ink
                    c.lineWidth = 3
                    c.fillRect(105, 130, 190, 440)
                    c.strokeRect(105, 130, 190, 440)

                    c.fillStyle = Tokens.surfaceInk
                    c.fillRect(128, 196, 144, 62)
                    c.fillRect(124, 268, 152, 128)
                    c.fillRect(128, 452, 144, 58)

                    c.strokeStyle = Tokens.line
                    c.lineWidth = 2
                    c.beginPath(); c.moveTo(200, 268); c.lineTo(200, 396); c.stroke()
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
                        c.fillStyle = isOpen ? Tokens.warning : Tokens.ink
                        c.strokeStyle = !state.valid ? Tokens.inkTertiary : c.fillStyle
                        c.lineWidth = 2
                        const x = p.side < 0 ? -14 : -4
                        if (state.valid) c.fillRect(x, 0, 18, 88)
                        else c.strokeRect(x, 0, 18, 88)
                        c.restore()
                    }
                }

                function drawLamps(c) {
                    c.fillStyle = visual.lightsOn ? Tokens.ink : Tokens.surfaceInk
                    c.fillRect(132, 138, 44, 12)
                    c.fillRect(224, 138, 44, 12)
                    c.fillStyle = visual.lightsOn ? Tokens.critical : Tokens.surfaceInk
                    c.fillRect(132, 552, 44, 12)
                    c.fillRect(224, 552, 44, 12)
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
                            // Unknown is an outline, never a healthy mark.
                            c.strokeStyle = Tokens.inkTertiary
                            c.strokeRect(s.x - 10, s.y - 10, 20, 20)
                            continue
                        }
                        c.fillStyle = state.latched ? Tokens.success : Tokens.critical
                        c.fillRect(s.x - 10, s.y - 10, 20, 20)
                        if (state.latched) continue
                        c.strokeStyle = Tokens.surface
                        c.beginPath()
                        c.moveTo(s.x - 4, s.y - 4); c.lineTo(s.x + 4, s.y + 4)
                        c.moveTo(s.x + 4, s.y - 4); c.lineTo(s.x - 4, s.y + 4)
                        c.stroke()
                    }
                }
            }

            // ── Turn indicators ───────────────────────────────────────────
            // Blinking is the legal meaning of the signal, so this loop stays.
            Repeater {
                model: [{ side: "left", x: 72 }, { side: "right", x: 312 }]

                delegate: Rectangle {
                    required property var modelData
                    readonly property bool armed: visual.turnSignal === modelData.side || visual.turnSignal === "hazard"
                    x: modelData.x
                    y: 300
                    width: 16
                    height: 100
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

            // ── Charging ──────────────────────────────────────────────────
            // The one permitted looping animation, and it moves a rectangle
            // rather than forcing a canvas repaint.
            Rectangle {
                visible: visual.charging
                x: 168; y: 408
                width: 64; height: 34
                color: Tokens.surfaceInk
                clip: true

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 56
                    color: Tokens.success
                    height: 11

                    SequentialAnimation on height {
                        running: visual.charging && visual.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: 11; to: 30; duration: 1400; easing.type: Tokens.easeInOut }
                        NumberAnimation { from: 30; to: 11; duration: 0 }
                    }
                }
            }
        }
    }
}
