import QtQuick
import OAS.HMI

// Sentence case, grey, small. It names the value below it and never shouts.
Text {
    color: Tokens.inkSecondary
    font.pixelSize: Tokens.caption
    font.weight: Tokens.weightRegular
    elide: Text.ElideRight
}
