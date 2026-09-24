import QtQuick
import OAS.HMI

// Line icon set drawn on a 24x24 grid with Canvas so the software renderer and
// embedded GPU produce identical output. Stroke only — active state changes the
// colour and weight, never a fill.
Item {
    id: icon

    property string name: ""
    property int size: Tokens.iconMd
    property color tone: Tokens.textSecondary
    property bool active: false

    implicitWidth: size
    implicitHeight: size

    readonly property color _stroke: active ? Tokens.accent : tone
    readonly property real _weight: active ? 2.25 : 1.75

    onNameChanged: canvas.requestPaint()
    on_StrokeChanged: canvas.requestPaint()
    on_WeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Immediate

        onPaint: {
            const c = getContext("2d")
            c.reset()
            c.scale(width / 24, height / 24)
            c.strokeStyle = icon._stroke
            c.fillStyle = icon._stroke
            c.lineWidth = icon._weight
            c.lineCap = "round"
            c.lineJoin = "round"
            draw(c, icon.name)
        }

        function line(c, x1, y1, x2, y2) { c.beginPath(); c.moveTo(x1, y1); c.lineTo(x2, y2); c.stroke() }
        function poly(c, pts, close) {
            c.beginPath(); c.moveTo(pts[0], pts[1])
            for (let i = 2; i < pts.length; i += 2) c.lineTo(pts[i], pts[i + 1])
            if (close) c.closePath()
            c.stroke()
        }
        function circle(c, x, y, r) { c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.stroke() }
        function dot(c, x, y, r) { c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.fill() }
        function rect(c, x, y, w, h, r) {
            const k = r === undefined ? 2 : r
            c.beginPath()
            c.moveTo(x + k, y); c.lineTo(x + w - k, y); c.quadraticCurveTo(x + w, y, x + w, y + k)
            c.lineTo(x + w, y + h - k); c.quadraticCurveTo(x + w, y + h, x + w - k, y + h)
            c.lineTo(x + k, y + h); c.quadraticCurveTo(x, y + h, x, y + h - k)
            c.lineTo(x, y + k); c.quadraticCurveTo(x, y, x + k, y)
            c.stroke()
        }
        function tri(c, x, y, s) { c.beginPath(); c.moveTo(x, y - s); c.lineTo(x + s * 1.15, y); c.lineTo(x, y + s); c.closePath(); c.fill() }

        function draw(c, n) {
            switch (n) {
            // ── Dock destinations ──────────────────────────────────────────
            case "home": poly(c, [3, 11, 12, 3.5, 21, 11]); poly(c, [5.2, 9.8, 5.2, 20.5, 18.8, 20.5, 18.8, 9.8]); line(c, 9.6, 20.5, 9.6, 14.5); line(c, 14.4, 20.5, 14.4, 14.5); line(c, 9.6, 14.5, 14.4, 14.5); break
            case "navigation": poly(c, [12, 2.8, 20.5, 21.2, 12, 17, 3.5, 21.2], true); break
            case "climate": circle(c, 12, 12, 3.1); for (let a = 0; a < 8; a++) { const r = a * Math.PI / 4; line(c, 12 + Math.cos(r) * 5.2, 12 + Math.sin(r) * 5.2, 12 + Math.cos(r) * 8.6, 12 + Math.sin(r) * 8.6) } break
            case "media": circle(c, 7, 18, 3); circle(c, 18, 15.6, 3); line(c, 10, 18, 10, 5.4); line(c, 21, 15.6, 21, 3); poly(c, [10, 5.4, 21, 3]); line(c, 10, 9.2, 21, 6.8); break
            case "phone": poly(c, [7.2, 3.2, 10.2, 3.2, 11.6, 8.2, 9.2, 9.8]); poly(c, [9.2, 9.8, 14.2, 14.8]); poly(c, [14.2, 14.8, 15.8, 12.4, 20.8, 13.8, 20.8, 16.8]); poly(c, [20.8, 16.8, 18.4, 20.4, 12.2, 18.4, 5.6, 11.8, 3.6, 5.6, 7.2, 3.2]); break
            case "camera": rect(c, 2.6, 6.6, 18.8, 13.4, 3); circle(c, 12, 13.3, 3.6); poly(c, [8.4, 6.6, 9.8, 3.8, 14.2, 3.8, 15.6, 6.6]); break
            case "vehicle": poly(c, [3.2, 15.4, 4.6, 10.2, 6.6, 8.4, 17.4, 8.4, 19.4, 10.2, 20.8, 15.4]); rect(c, 2.6, 15, 18.8, 4.2, 1.6); line(c, 4.6, 19.2, 4.6, 21); line(c, 19.4, 19.2, 19.4, 21); dot(c, 6.4, 17.1, 1); dot(c, 17.6, 17.1, 1); break
            case "settings": line(c, 3, 6.5, 21, 6.5); line(c, 3, 12, 21, 12); line(c, 3, 17.5, 21, 17.5); circle(c, 8.5, 6.5, 2.6); circle(c, 15.5, 12, 2.6); circle(c, 10, 17.5, 2.6); break

            // ── Media transport ────────────────────────────────────────────
            case "play": c.beginPath(); c.moveTo(7.5, 4.6); c.lineTo(19.5, 12); c.lineTo(7.5, 19.4); c.closePath(); c.fill(); break
            case "pause": c.fillRect(7, 4.6, 3.6, 14.8); c.fillRect(13.4, 4.6, 3.6, 14.8); break
            case "next": c.beginPath(); c.moveTo(5, 5); c.lineTo(15, 12); c.lineTo(5, 19); c.closePath(); c.fill(); c.fillRect(16.8, 5, 2.6, 14); break
            case "prev": c.beginPath(); c.moveTo(19, 5); c.lineTo(9, 12); c.lineTo(19, 19); c.closePath(); c.fill(); c.fillRect(4.6, 5, 2.6, 14); break
            case "volume": poly(c, [3.5, 9.5, 7, 9.5, 11.5, 5.5, 11.5, 18.5, 7, 14.5, 3.5, 14.5], true); c.beginPath(); c.arc(13, 12, 3.4, -0.9, 0.9); c.stroke(); c.beginPath(); c.arc(13, 12, 6.6, -0.9, 0.9); c.stroke(); break
            case "mic": rect(c, 9, 2.6, 6, 11, 3); c.beginPath(); c.arc(12, 12.4, 6, 0, Math.PI); c.stroke(); line(c, 12, 18.4, 12, 21.4); break

            // ── Climate ────────────────────────────────────────────────────
            case "fan": circle(c, 12, 12, 2.1); for (let f = 0; f < 3; f++) { const r = f * Math.PI * 2 / 3; c.beginPath(); c.moveTo(12 + Math.cos(r) * 2.1, 12 + Math.sin(r) * 2.1); c.bezierCurveTo(12 + Math.cos(r - 0.9) * 9, 12 + Math.sin(r - 0.9) * 9, 12 + Math.cos(r + 0.5) * 9.4, 12 + Math.sin(r + 0.5) * 9.4, 12 + Math.cos(r + 2.094) * 2.1, 12 + Math.sin(r + 2.094) * 2.1); c.stroke() } break
            case "seatHeat": poly(c, [6.5, 20.5, 6.5, 12.5, 9.5, 11]); poly(c, [9.5, 11, 9.5, 4.5, 12.5, 3.5, 15, 5, 14.5, 11.5]); line(c, 6.5, 20.5, 17.5, 20.5); c.beginPath(); c.moveTo(18.5, 4); c.quadraticCurveTo(16.5, 6, 18.5, 8); c.quadraticCurveTo(20.5, 10, 18.5, 12); c.stroke(); break
            case "seatVent": poly(c, [6.5, 20.5, 6.5, 12.5, 9.5, 11]); poly(c, [9.5, 11, 9.5, 4.5, 12.5, 3.5, 15, 5, 14.5, 11.5]); line(c, 6.5, 20.5, 17.5, 20.5); line(c, 18.5, 4, 18.5, 12); line(c, 18.5, 12, 16.6, 9.8); line(c, 18.5, 12, 20.4, 9.8); break
            case "defrostFront": c.beginPath(); c.moveTo(3.5, 12.5); c.quadraticCurveTo(3.5, 4, 12, 4); c.quadraticCurveTo(20.5, 4, 20.5, 12.5); c.stroke(); for (let d = 0; d < 3; d++) { const x = 7.5 + d * 4.5; c.beginPath(); c.moveTo(x, 15); c.quadraticCurveTo(x - 1.8, 17.5, x, 20); c.stroke() } break
            case "defrostRear": rect(c, 3.5, 5, 17, 9, 2); for (let l = 0; l < 3; l++) line(c, 5.6, 7.6 + l * 2.6, 18.4, 7.6 + l * 2.6); for (let d2 = 0; d2 < 3; d2++) { const x2 = 7.5 + d2 * 4.5; c.beginPath(); c.moveTo(x2, 16); c.quadraticCurveTo(x2 - 1.8, 18.5, x2, 21); c.stroke() } break

            // ── Vehicle systems ────────────────────────────────────────────
            case "lock": rect(c, 4.5, 10.5, 15, 10, 2.5); poly(c, [8, 10.5, 8, 7.2]); c.beginPath(); c.arc(12, 7.2, 4, Math.PI, 0); c.stroke(); line(c, 16, 7.2, 16, 10.5); dot(c, 12, 15.2, 1.5); break
            case "unlock": rect(c, 4.5, 10.5, 15, 10, 2.5); poly(c, [8, 10.5, 8, 7.2]); c.beginPath(); c.arc(12, 7.2, 4, Math.PI, -0.1); c.stroke(); dot(c, 12, 15.2, 1.5); break
            case "light": c.beginPath(); c.arc(8.5, 12, 6, Math.PI * 0.5, Math.PI * 1.5); c.stroke(); line(c, 8.5, 6, 8.5, 18); for (let b = 0; b < 3; b++) { line(c, 12.5, 8.4 + b * 3.6, 20.5, 8.4 + b * 3.6) } break
            case "battery": rect(c, 2.5, 7, 16.5, 10, 2); c.fillRect(20, 10, 2, 4); c.fillRect(4.6, 9.1, 7, 5.8); break
            case "fuel": rect(c, 4, 3.5, 10, 17, 2); line(c, 5.8, 8.4, 12.2, 8.4); poly(c, [14, 9, 17.5, 9, 17.5, 16.5]); c.beginPath(); c.arc(19, 16.5, 1.5, Math.PI, 0); c.stroke(); line(c, 17.5, 5.5, 19.6, 8); break
            case "charge": poly(c, [13.5, 2.5, 6.5, 13, 11.5, 13, 10.5, 21.5, 17.5, 11, 12.5, 11], true); break
            case "adas": poly(c, [12, 3, 20.5, 7, 20.5, 13, 12, 21, 3.5, 13, 3.5, 7], true); line(c, 12, 3, 12, 21); circle(c, 12, 11.5, 2.6); break
            case "wrench": c.beginPath(); c.arc(7.5, 7.5, 4.6, 0.6, 5.4); c.stroke(); poly(c, [10.6, 10.9, 19.5, 19.8]); c.beginPath(); c.arc(19.5, 19.8, 1.9, 0, Math.PI * 2); c.stroke(); break
            case "download": line(c, 12, 3.5, 12, 15.5); poly(c, [7.6, 11.2, 12, 15.6, 16.4, 11.2]); poly(c, [3.8, 18.5, 3.8, 20.6, 20.2, 20.6, 20.2, 18.5]); break
            case "pulse": poly(c, [2.5, 12, 7, 12, 9.4, 5.5, 13.6, 18.5, 16.4, 12, 21.5, 12]); break

            // ── Turn instructions ──────────────────────────────────────────
            case "turnLeft": poly(c, [18, 20.5, 18, 11.5, 8, 11.5]); poly(c, [12.4, 6.6, 7.2, 11.5, 12.4, 16.4]); break
            case "turnRight": poly(c, [6, 20.5, 6, 11.5, 16, 11.5]); poly(c, [11.6, 6.6, 16.8, 11.5, 11.6, 16.4]); break
            case "turnStraight": line(c, 12, 21, 12, 5); poly(c, [6.8, 10, 12, 4.6, 17.2, 10]); break
            case "uTurn": poly(c, [7, 21, 7, 10.5]); c.beginPath(); c.arc(11.5, 10.5, 4.5, Math.PI, 0); c.stroke(); line(c, 16, 10.5, 16, 15); poly(c, [12.8, 11.8, 16, 15.4, 19.2, 11.8]); break

            // ── Utility ────────────────────────────────────────────────────
            case "chevronRight": poly(c, [9, 4.5, 16.5, 12, 9, 19.5]); break
            case "chevronLeft": poly(c, [15, 4.5, 7.5, 12, 15, 19.5]); break
            case "close": line(c, 5.5, 5.5, 18.5, 18.5); line(c, 18.5, 5.5, 5.5, 18.5); break
            case "check": poly(c, [4.5, 12.5, 9.8, 18, 19.5, 6.5]); break
            case "warning": poly(c, [12, 3.2, 22, 20.4, 2, 20.4], true); line(c, 12, 9, 12, 14.6); dot(c, 12, 17.6, 1.1); break
            case "plus": line(c, 12, 5, 12, 19); line(c, 5, 12, 19, 12); break
            case "minus": line(c, 5, 12, 19, 12); break
            case "sync": c.beginPath(); c.arc(12, 12, 7.6, Math.PI * 0.75, Math.PI * 1.85); c.stroke(); poly(c, [16.4, 2.6, 19.6, 5.8, 16.4, 9]); c.beginPath(); c.arc(12, 12, 7.6, Math.PI * 1.75, Math.PI * 0.85); c.stroke(); poly(c, [7.6, 21.4, 4.4, 18.2, 7.6, 15]); break
            case "search": circle(c, 10.5, 10.5, 6.6); line(c, 15.4, 15.4, 20.5, 20.5); break
            case "star": { const pts = []; for (let i = 0; i < 10; i++) { const r = i % 2 === 0 ? 8.8 : 3.9; const a = -Math.PI / 2 + i * Math.PI / 5; pts.push(12 + Math.cos(a) * r, 12 + Math.sin(a) * r) } poly(c, pts, true); break }
            default: circle(c, 12, 12, 8.6)
            }
        }
    }
}
