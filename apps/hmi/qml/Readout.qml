import QtQuick
import OAS.HMI

// Value + unit pair. An invalid signal renders an em dash — never zero and
// never the last known value.
Column {
    id: readout

    property string label: ""
    property string value: ""
    property string unit: ""
    property bool valid: true
    property int valueSize: Tokens.displaySm
    property color tone: Tokens.textPrimary

    spacing: Tokens.s1

    Caption {
        text: readout.label
        visible: readout.label.length > 0
    }

    Row {
        spacing: Tokens.s2

        Text {
            id: valueText
            text: readout.valid ? readout.value : "—"
            color: readout.valid ? readout.tone : Tokens.textTertiary
            font.pixelSize: readout.valueSize
            font.weight: readout.valueSize >= Tokens.displaySm ? Tokens.weightLight : Tokens.weightMedium
            font.letterSpacing: readout.valueSize >= Tokens.displaySm ? -1.5 : 0
        }

        Text {
            anchors.baseline: valueText.baseline
            text: readout.unit
            visible: readout.unit.length > 0
            color: Tokens.textTertiary
            font.pixelSize: Math.max(Tokens.caption, Math.round(readout.valueSize * 0.28))
            font.weight: Tokens.weightMedium
        }
    }
}
