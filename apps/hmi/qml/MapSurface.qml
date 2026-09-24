import QtQuick
import OAS.HMI

// The map owns the whole area it is given. UI goes on top of it as overlays;
// nothing is stacked on it as cards.
Item {
    id: map

    property bool available: false
    property bool routeActive: false
    property string traffic: "none"
    property real heading: 0

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rXl
        color: Tokens.ground
        border.width: 1
        border.color: Tokens.borderSubtle
        clip: true

        Canvas {
            id: canvas
            anchors.fill: parent
            visible: map.available
            renderStrategy: Canvas.Immediate

            Connections { target: Tokens; function onDarkChanged() { canvas.requestPaint() } }
            Connections { target: map; function onRouteActiveChanged() { canvas.requestPaint() } }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                const c = getContext("2d")
                c.reset()

                // Block structure. Deliberately abstract: this is a rendering
                // target for the route overlay, not a survey of real geography.
                c.strokeStyle = Tokens.mapBlock
                c.lineWidth = 1
                for (let x = -40; x < width + 80; x += 96) { c.beginPath(); c.moveTo(x, 0); c.lineTo(x + 60, height); c.stroke() }
                for (let y = -40; y < height + 80; y += 84) { c.beginPath(); c.moveTo(0, y); c.lineTo(width, y + 36); c.stroke() }

                c.strokeStyle = Tokens.mapRoad
                c.lineWidth = 9
                c.lineCap = "round"
                c.beginPath(); c.moveTo(0, height * 0.72); c.lineTo(width * 0.42, height * 0.60); c.lineTo(width, height * 0.30); c.stroke()
                c.beginPath(); c.moveTo(width * 0.24, 0); c.lineTo(width * 0.40, height); c.stroke()

                if (!map.routeActive) return

                // Route, drawn under the vehicle marker.
                c.strokeStyle = Tokens.accent
                c.lineWidth = 11
                c.beginPath()
                c.moveTo(width * 0.30, height * 0.88)
                c.lineTo(width * 0.30, height * 0.56)
                c.lineTo(width * 0.52, height * 0.42)
                c.lineTo(width * 0.58, height * 0.12)
                c.stroke()

                // Congestion sits on the route as a differently weighted stroke,
                // so it survives a colour-blind read.
                if (map.traffic === "moderate" || map.traffic === "heavy") {
                    // Drawn as explicit dashes so a colour-blind read still has
                    // a texture difference, and so it needs no dash support.
                    c.strokeStyle = map.traffic === "heavy" ? Tokens.critical : Tokens.warning
                    c.lineWidth = 11
                    const x0 = width * 0.52, y0 = height * 0.42
                    const dx = width * 0.06, dy = -height * 0.30
                    for (let i = 0; i < 6; i++) {
                        const a = i / 6, b = a + 0.085
                        c.beginPath()
                        c.moveTo(x0 + dx * a, y0 + dy * a)
                        c.lineTo(x0 + dx * b, y0 + dy * b)
                        c.stroke()
                    }
                }

                // Destination.
                c.fillStyle = Tokens.accentHi
                c.beginPath(); c.arc(width * 0.58, height * 0.12, 12, 0, Math.PI * 2); c.fill()
                c.fillStyle = Tokens.onAccent
                c.beginPath(); c.arc(width * 0.58, height * 0.12, 5, 0, Math.PI * 2); c.fill()
            }
        }

        // Own-vehicle marker.
        Item {
            visible: map.available
            x: canvas.width * 0.30 - width / 2
            y: canvas.height * 0.88 - height / 2
            width: 44; height: 44

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Tokens.wash(Tokens.accent, 0.22)
            }

            Canvas {
                id: marker
                anchors.centerIn: parent
                width: 26; height: 26
                renderStrategy: Canvas.Immediate
                Connections { target: Tokens; function onDarkChanged() { marker.requestPaint() } }
                onPaint: {
                    const c = getContext("2d")
                    c.reset()
                    c.fillStyle = Tokens.accent
                    c.beginPath(); c.moveTo(13, 1); c.lineTo(24, 25); c.lineTo(13, 19); c.lineTo(2, 25)
                    c.closePath(); c.fill()
                }
            }
        }

        EmptyState {
            anchors.centerIn: parent
            width: Math.min(parent.width - Tokens.s8, 480)
            visible: !map.available
            iconName: "navigation"
            title: "지도 공급자 연결 전"
            detail: "지도 공급자가 연결되면 현재 위치, 경로, 교통 상황과 다음 안내가 이 표면 위에 오버레이로 표시됩니다."
            badge: "위치 데이터 없음"
        }
    }
}
