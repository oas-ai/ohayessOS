import QtQuick
import OAS.HMI

// Boxed options separated by hairlines. The selection is inked rather than
// outlined, so it reads at a glance without colour.
Item {
    id: segmented

    // Entries are strings, or { text, iconName, enabled }.
    property var model: []
    property int currentIndex: 0
    signal activated(int index)

    implicitHeight: Tokens.touchBase
    implicitWidth: Math.max(Tokens.touchMin * Math.max(1, model.length), 220)

    function _entry(index, key, fallback) {
        const item = model[index]
        if (item === undefined) return fallback
        if (typeof item === "string") return key === "text" ? item : fallback
        return item[key] === undefined ? fallback : item[key]
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.line

        Row {
            anchors.fill: parent
            anchors.margins: Tokens.hairline
            spacing: Tokens.hairline

            Repeater {
                model: segmented.model

                delegate: Rectangle {
                    id: segment
                    required property int index
                    readonly property bool selected: segmented.currentIndex === index
                    readonly property bool segmentEnabled: segmented._entry(index, "enabled", true)

                    width: (parent.width - Tokens.hairline * Math.max(0, segmented.model.length - 1)) / Math.max(1, segmented.model.length)
                    height: parent.height
                    color: !segmentEnabled ? Tokens.surfaceAlt
                        : selected ? Tokens.ink : Tokens.surface
                    activeFocusOnTab: segmentEnabled
                    Accessible.name: segmented._entry(index, "text", "")
                    Accessible.role: Accessible.RadioButton

                    Behavior on color { ColorAnimation { duration: Tokens.mFast; easing.type: Tokens.easeOut } }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: segment.activeFocus ? 2 : 0
                        border.color: Tokens.ink
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: Tokens.s2

                        Icon {
                            name: segmented._entry(segment.index, "iconName", "")
                            visible: name.length > 0
                            anchors.verticalCenter: parent.verticalCenter
                            size: Tokens.iconMd
                            tone: !segment.segmentEnabled ? Tokens.inkDisabled
                                : segment.selected ? Tokens.onInk : Tokens.inkSecondary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: segmented._entry(segment.index, "text", "")
                            visible: text.length > 0
                            color: !segment.segmentEnabled ? Tokens.inkDisabled
                                : segment.selected ? Tokens.onInk : Tokens.inkSecondary
                            font.pixelSize: Tokens.bodyMd
                            font.weight: segment.selected ? Tokens.weightDemi : Tokens.weightRegular
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
}
