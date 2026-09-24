import QtQuick
import OAS.HMI

// 2–5 mutually exclusive options. The indicator moves; the segments do not.
Item {
    id: segmented

    // Entries are strings, or { text, iconName, enabled }.
    property var model: []
    property int currentIndex: 0
    signal activated(int index)

    implicitHeight: Tokens.touchBase
    implicitWidth: Math.max(Tokens.touchMin * Math.max(1, model.length), 240)

    readonly property real _segmentWidth: model.length > 0 ? width / model.length : width

    function _entry(index, key, fallback) {
        const item = model[index]
        if (item === undefined) return fallback
        if (typeof item === "string") return key === "text" ? item : fallback
        return item[key] === undefined ? fallback : item[key]
    }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rMd
        color: Tokens.surfaceAlt
        border.width: 1
        border.color: Tokens.borderStrong
    }

    Rectangle {
        id: indicator
        width: segmented._segmentWidth - Tokens.s1 * 2
        height: parent.height - Tokens.s1 * 2
        x: segmented.currentIndex * segmented._segmentWidth + Tokens.s1
        y: Tokens.s1
        radius: Tokens.rMd - 4
        color: Tokens.surfaceRaised
        border.width: 1
        border.color: Tokens.accent
        visible: segmented.currentIndex >= 0 && segmented.currentIndex < segmented.model.length

        Behavior on x { NumberAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
    }

    Row {
        anchors.fill: parent

        Repeater {
            model: segmented.model

            delegate: Item {
                id: segment
                required property int index
                readonly property bool selected: segmented.currentIndex === index
                readonly property bool segmentEnabled: segmented._entry(index, "enabled", true)

                width: segmented._segmentWidth
                height: segmented.height
                activeFocusOnTab: segmentEnabled
                Accessible.name: segmented._entry(index, "text", "")
                Accessible.role: Accessible.RadioButton

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Tokens.s1
                    radius: Tokens.rMd - 4
                    color: "transparent"
                    border.width: segment.activeFocus ? 2 : 0
                    border.color: Tokens.accent
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Tokens.s2

                    Icon {
                        name: segmented._entry(segment.index, "iconName", "")
                        visible: name.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        size: Tokens.iconMd
                        tone: !segment.segmentEnabled ? Tokens.textDisabled
                            : segment.selected ? Tokens.accent : Tokens.textSecondary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: segmented._entry(segment.index, "text", "")
                        visible: text.length > 0
                        color: !segment.segmentEnabled ? Tokens.textDisabled
                            : segment.selected ? Tokens.textPrimary : Tokens.textSecondary
                        font.pixelSize: Tokens.bodyMd
                        font.weight: segment.selected ? Tokens.weightDemi : Tokens.weightRegular

                        Behavior on color { ColorAnimation { duration: Tokens.mBase; easing.type: Tokens.easeOut } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: segment.segmentEnabled
                    onClicked: {
                        segment.forceActiveFocus()
                        segmented.currentIndex = segment.index
                        segmented.activated(segment.index)
                    }
                }

                Keys.onSpacePressed: if (segment.segmentEnabled) { segmented.currentIndex = segment.index; segmented.activated(segment.index) }
            }
        }
    }
}
