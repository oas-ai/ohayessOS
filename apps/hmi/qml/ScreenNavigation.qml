import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 02 Navigation. The map takes the whole area; at most four overlays sit on it.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    signal notify(string message, string iconName)

    readonly property var nav: Providers.navigation

    MapSurface {
        id: surface
        anchors.fill: parent
        available: screen.nav.connected
        routeActive: screen.nav.routeActive
        traffic: screen.nav.traffic
    }

    // ── Overlay 1 · next instruction (top left) ───────────────────────────
    NavInstruction {
        visible: screen.nav.connected
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Tokens.s5
        width: Math.min(420, parent.width * 0.38)
        overlay: true
        available: screen.nav.connected
        turnIcon: screen.nav.nextTurnIcon
        distanceM: screen.nav.nextTurnDistanceM
        road: screen.nav.nextTurnRoad
        detail: screen.nav.nextTurnDetail
    }

    // ── Overlay 2 · trip summary (bottom left) ────────────────────────────
    Rectangle {
        id: summary
        visible: screen.nav.connected
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s5
        width: Math.min(420, parent.width * 0.38)
        height: summaryLayout.implicitHeight + Tokens.s5 * 2
        radius: Tokens.rXl
        color: Tokens.wash(Tokens.surface, 0.92)
        border.width: 1
        border.color: Tokens.borderStrong

        ColumnLayout {
            id: summaryLayout
            anchors.fill: parent
            anchors.margins: Tokens.s5
            spacing: Tokens.s3

            Text {
                text: screen.nav.destinationShort
                color: Tokens.textPrimary
                font.pixelSize: Tokens.bodyLg
                font.weight: Tokens.weightMedium
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.s5

                Readout { label: "도착"; value: screen.nav.eta; valueSize: Tokens.titleSection }
                Readout { label: "남은 시간"; value: screen.nav.remainingMin; unit: "분"; valueSize: Tokens.titleSection }
                Readout { label: "거리"; value: screen.nav.remainingKm.toFixed(1); unit: "km"; valueSize: Tokens.titleSection }
                Item { Layout.fillWidth: true }
            }

            OasButton {
                Layout.fillWidth: true
                text: "경로 안내 종료"
                variant: "ghost"
                onClicked: screen.notify("경로 안내를 종료했습니다", "close")
            }
        }
    }

    // ── Overlay 3 · charging and points of interest (top right) ───────────
    Rectangle {
        visible: screen.nav.connected
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.s5
        width: Math.min(340, parent.width * 0.3)
        height: poiLayout.implicitHeight + Tokens.s5 * 2
        radius: Tokens.rXl
        color: Tokens.wash(Tokens.surface, 0.92)
        border.width: 1
        border.color: Tokens.borderStrong

        ColumnLayout {
            id: poiLayout
            anchors.fill: parent
            anchors.margins: Tokens.s5
            spacing: Tokens.s2

            Caption { text: "경로 주변" }

            Repeater {
                model: screen.nav.pois

                delegate: Item {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: Tokens.touchMin

                    Icon {
                        id: poiIcon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        name: modelData.icon
                        size: Tokens.iconMd
                        tone: Tokens.textSecondary
                    }

                    Column {
                        anchors.left: poiIcon.right
                        anchors.leftMargin: Tokens.s3
                        anchors.right: poiDistance.left
                        anchors.rightMargin: Tokens.s2
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            text: modelData.name
                            width: parent.width
                            elide: Text.ElideRight
                            color: Tokens.textPrimary
                            font.pixelSize: Tokens.bodyMd
                        }

                        Text {
                            text: modelData.kind
                            color: Tokens.textTertiary
                            font.pixelSize: Tokens.caption
                        }
                    }

                    Text {
                        id: poiDistance
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.distanceKm.toFixed(1) + " km"
                        color: Tokens.textSecondary
                        font.pixelSize: Tokens.label
                    }
                }
            }
        }
    }

    // ── Overlay 4 · destination entry (bottom right) ──────────────────────
    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s5
        spacing: Tokens.s3

        OasButton {
            text: "즐겨찾기"
            iconName: "star"
            variant: "secondary"
            size: Tokens.touchLarge
            onClicked: screen.notify("즐겨찾기 목적지 없음", "star")
        }

        OasButton {
            // Text entry is the one input that stays locked while moving.
            text: screen.driving ? "주행 중 검색 잠금" : "목적지 검색"
            iconName: screen.driving ? "mic" : "search"
            variant: "primary"
            size: Tokens.touchLarge
            enabled: !screen.driving
            lockReason: "주행 중에는 텍스트 입력을 사용할 수 없습니다"
            onClicked: screen.notify("검색 공급자 연결 전", "search")
        }

        OasIconButton {
            iconName: "mic"
            size: Tokens.touchLarge
            variant: "secondary"
            text: "음성으로 목적지 말하기"
            onClicked: screen.notify("음성 인식 공급자 연결 전", "mic")
        }
    }
}
