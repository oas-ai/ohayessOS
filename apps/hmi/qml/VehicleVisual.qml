import QtQuick
import OAS.HMI
Item {
    // Original concept SUV illustration. Decorative, not sensed surroundings.
    Canvas {
        id: canvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections { target: Theme; function onDarkModeChanged() { canvas.requestPaint() } }
        onPaint: {
            var c = getContext("2d"); c.reset(); c.scale(width / 640, height / 460);
            var glow = c.createRadialGradient(320, 290, 8, 320, 290, 245);
            glow.addColorStop(0, Theme.darkMode ? "#244657" : "#BDEDF5"); glow.addColorStop(1, Theme.darkMode ? "rgba(13,19,33,0)" : "rgba(255,255,255,0)");
            c.fillStyle = glow; c.fillRect(0, 0, 640, 460);
            c.strokeStyle = Theme.darkMode ? "#23364a" : "#D5E0E9"; c.lineWidth = 1;
            for (var i = 0; i < 5; i++) { c.beginPath(); c.moveTo(40, 340+i*24); c.lineTo(600, 340+i*24); c.stroke(); }
            c.beginPath(); c.ellipse(90, 319, 470, 70); c.fillStyle = Theme.darkMode ? "#080d17" : "#E6ECF2"; c.fill();
            // Rear three-quarter body with roof, glazing and machined wheels.
            var body = c.createLinearGradient(200, 140, 420, 330);
            body.addColorStop(0, "#d7e3ee"); body.addColorStop(0.42, "#839bab"); body.addColorStop(1, "#293b50");
            c.beginPath(); c.moveTo(103,264); c.lineTo(191,173); c.quadraticCurveTo(210,151,247,151);
            c.lineTo(394,160); c.lineTo(489,236); c.lineTo(531,268); c.lineTo(519,327);
            c.lineTo(386,360); c.lineTo(112,311); c.closePath(); c.fillStyle = body; c.fill();
            c.strokeStyle = "#b0c7d3"; c.stroke();
            c.beginPath(); c.moveTo(203,177); c.lineTo(254,167); c.lineTo(388,177); c.lineTo(458,234);
            c.lineTo(326,233); c.closePath(); c.fillStyle = "#142536"; c.fill();
            c.beginPath(); c.moveTo(195,187); c.lineTo(296,244); c.lineTo(125,267); c.closePath(); c.fillStyle = "#1d3042"; c.fill();
            c.beginPath(); c.moveTo(318,244); c.lineTo(497,254); c.lineTo(477,296); c.lineTo(320,285); c.closePath(); c.fillStyle = "#0c1929"; c.fill();
            c.beginPath(); c.moveTo(320,296); c.lineTo(505,305); c.lineTo(499,315); c.lineTo(319,305); c.closePath(); c.fillStyle = "#ff7888"; c.fill();
            c.beginPath(); c.moveTo(134,281); c.lineTo(305,308); c.lineTo(386,346); c.strokeStyle = "#b6d3df"; c.stroke();
            c.beginPath(); c.moveTo(273,250); c.lineTo(270,315); c.strokeStyle = "#4a6374"; c.stroke();
            var wheels = [[166,307,26,39], [436,338,29,38]];
            for (var w = 0; w < wheels.length; w++) {
                var a = wheels[w]; c.beginPath(); c.ellipse(a[0]-a[2],a[1]-a[3],a[2]*2,a[3]*2); c.fillStyle = "#090f19"; c.fill();
                c.beginPath(); c.ellipse(a[0]-a[2]*0.68,a[1]-a[3]*0.72,a[2]*1.36,a[3]*1.44); c.fillStyle = "#748c9e"; c.fill();
                c.beginPath(); c.ellipse(a[0]-9,a[1]-20,18,40); c.fillStyle = "#26384a"; c.fill();
            }
        }
    }
}
