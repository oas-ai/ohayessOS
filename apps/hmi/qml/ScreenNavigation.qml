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
        width: Math.min(440, parent.width * 0.38)
        overlay: true
        available: screen.nav.connected
        turnIcon: screen.nav.nextTurnIcon
        distanceM: screen.nav.nextTurnDistanceM
        road: screen.nav.nextTurnRoad
        detail: screen.nav.nextTurnDetail
    }

    // ── Overlay 2 · trip summary (bottom left) ────────────────────────────
    GridBoard {
        visible: screen.nav.connected
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s5
        width: Math.min(460, parent.width * 0.4)
        columns: 3

        Cell {
            Layout.columnSpan: 3
            Layout.fillWidth: true
            spacing: Tokens.s2

            Caption { text: "목적지" }

            Text {
                text: screen.nav.destinationShort
                Layout.fillWidth: true
                elide: Text.ElideRight
                color: Tokens.ink
                font.pixelSize: Tokens.bodyLg
                font.weight: Tokens.weightDemi
            }
        }

        Metric { Layout.fillWidth: true; label: "도착"; value: screen.nav.eta }
        Metric { Layout.fillWidth: true; label: "남은 시간"; value: screen.nav.remainingMin; unit: "분" }
        Metric { Layout.fillWidth: true; label: "거리"; value: screen.nav.remainingKm.toFixed(1); unit: "km" }

        Cell {
            Layout.columnSpan: 3
            Layout.fillWidth: true
            padding: 0

            OasButton {
                Layout.fillWidth: true
                text: "경로 안내 종료"
                variant: "ghost"
                onClicked: screen.notify("경로 안내를 종료했습니다", "close")
            }
        }
    }

    // ── Overlay 3 · charging and points of interest (top right) ───────────
    GridBoard {
        visible: screen.nav.connected
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.s5
        width: Math.min(360, parent.width * 0.3)
        columns: 1

        Cell {
            Layout.fillWidth: true
            Caption { text: "경로 주변" }
        }

        Repeater {
            model: screen.nav.pois

            delegate: Cell {
                required property var modelData
                Layout.fillWidth: true
                padding: Tokens.s4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.s3

                    Icon { name: modelData.icon; size: Tokens.iconMd; tone: Tokens.inkSecondary }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: modelData.name
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            color: Tokens.ink
                            font.pixelSize: Tokens.bodyMd
                        }

                        Caption { text: modelData.kind }
                    }

                    Text {
                        text: modelData.distanceKm.toFixed(1) + " km"
                        color: Tokens.inkSecondary
                        font.pixelSize: Tokens.label
                        font.weight: Tokens.weightMedium
                    }
                }
            }
        }
    }

    // ── Overlay 4 · destination entry (bottom right) ──────────────────────
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.s5
        spacing: Tokens.hairline

        OasButton {
            text: "즐겨찾기"
            iconName: "star"
            size: Tokens.touchLarge
            onClicked: screen.notify("즐겨찾기 목적지 없음", "star")
        }

        OasButton {
            // Text entry is the one input that stays locked while moving.
            text: screen.driving ? "주행 중 검색 잠금" : "목적지 검색"
            iconName: "search"
            variant: "primary"
            size: Tokens.touchLarge
            enabled: !screen.driving
            lockReason: "주행 중에는 텍스트 입력을 사용할 수 없습니다"
            onClicked: screen.notify("검색 공급자 연결 전", "search")
        }

        OasIconButton {
            iconName: "mic"
            size: Tokens.touchLarge
            text: "음성으로 목적지 말하기"
            onClicked: screen.notify("음성 인식 공급자 연결 전", "mic")
        }
    }
}
