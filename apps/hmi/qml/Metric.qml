import QtQuick
import QtQuick.Layouts
import OAS.HMI

// The unit the whole system is built from: a small grey label with an optional
// change on the right, a heavy value beneath it, and room for a chart under
// that. An invalid signal shows an em dash rather than a zero.
Cell {
    id: metric

    property string label: ""
    property string value: ""
    property string unit: ""
    property string delta: ""
    property color deltaTone: Tokens.inkSecondary
    property bool valid: true
    property color valueTone: Tokens.ink
    property int valueSize: Tokens.dataMd

    spacing: Tokens.s3

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.s3

        Caption { text: metric.label }

        Item { Layout.fillWidth: true }

        Text {
            text: metric.delta
            visible: metric.valid && metric.delta.length > 0
            color: metric.deltaTone
            font.pixelSize: Tokens.caption
            font.weight: Tokens.weightMedium
        }
    }

    Row {
        Layout.fillWidth: true
        spacing: Tokens.s2

        Text {
            id: valueText
            text: metric.valid ? metric.value : "—"
            color: metric.valid ? metric.valueTone : Tokens.inkTertiary
            font.pixelSize: metric.valueSize
            font.weight: Tokens.weightDemi
            font.letterSpacing: metric.valueSize >= Tokens.dataLg ? -1.2 : -0.3
        }

        Text {
            anchors.baseline: valueText.baseline
            text: metric.unit
            visible: metric.unit.length > 0
            color: metric.valid ? metric.valueTone : Tokens.inkTertiary
            font.pixelSize: Math.max(Tokens.caption, Math.round(metric.valueSize * 0.52))
            font.weight: Tokens.weightMedium
        }
    }
}
