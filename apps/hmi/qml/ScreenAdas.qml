import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 06 Driver assistance. The visualisation shows what the system reports it
// sees; nothing is drawn from inference.
Item {
    id: screen

    property var vehicle: null
    signal notify(string message, string iconName)

    readonly property var adas: Providers.adas

    GridBoard {
        anchors.fill: parent
        columns: Tokens.showSideColumns ? 2 : 1

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
            padding: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                VehicleVisual {
                    anchors.fill: parent
                    speedKph: screen.vehicle ? screen.vehicle.speedKph : 0
                    speedValid: screen.vehicle ? screen.vehicle.speedValid : false
                    gear: screen.vehicle ? screen.vehicle.gear : "—"
                    gearValid: screen.vehicle ? screen.vehicle.gearValid : false
                    steeringAngleDeg: screen.vehicle ? screen.vehicle.steeringAngleDeg : 0
                    steeringValid: screen.vehicle ? screen.vehicle.steeringValid : false
                    doors: screen.vehicle ? screen.vehicle.doors : []
                    doorsValid: screen.vehicle ? screen.vehicle.doorsValid : false
                    seatbelts: screen.vehicle ? screen.vehicle.seatbelts : []
                    seatbeltsValid: screen.vehicle ? screen.vehicle.seatbeltsValid : false
                    lanesDetected: screen.adas.lanesDetected
                    showSurroundings: screen.adas.connected
                    surroundings: screen.adas.surroundings
                    lightsOn: Providers.lights.lit
                }

                StatusBadge {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: Tokens.cellPadding
                    text: screen.adas.connected ? "차로 인식됨" : "센서 연결 전"
                    tone: screen.adas.connected ? Tokens.success : Tokens.inkTertiary
                }

                EmptyState {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - Tokens.s8, 460)
                    visible: !screen.adas.connected
                    iconName: "adas"
                    title: "주행 보조 공급자 연결 전"
                    detail: "차로, 주변 차량, 앞차와의 거리는 ADAS 데이터가 연결되면 이 표면에 표시됩니다."
                }
            }
        }

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            spacing: Tokens.s5

            Caption { text: "스마트 크루즈" }

            Row {
                spacing: Tokens.s2

                Text {
                    id: cruiseValue
                    text: screen.adas.connected ? screen.adas.cruiseSetKph : "—"
                    color: screen.adas.connected ? Tokens.ink : Tokens.inkTertiary
                    font.pixelSize: Tokens.dataXl
                    font.weight: Tokens.weightDemi
                    font.letterSpacing: -1.2
                }

                Text {
                    anchors.baseline: cruiseValue.baseline
                    text: "km/h"
                    color: Tokens.inkSecondary
                    font.pixelSize: Tokens.titleMd
                    font.weight: Tokens.weightMedium
                }
            }

            OasSlider {
                Layout.fillWidth: true
                label: "차간 거리"
                from: 1
                to: screen.adas.maxFollowDistance
                stepSize: 1
                value: screen.adas.followDistance
                displayText: screen.adas.followDistance + " 단계"
                enabled: screen.adas.connected
                onMoved: function (v) { screen.adas.followDistance = v }
            }

            Divider { Layout.fillWidth: true; Layout.topMargin: Tokens.s2 }

            Caption { text: "보조 시스템" }

            OasToggle {
                Layout.fillWidth: true
                text: "차로 이탈 방지"
                checked: screen.adas.laneKeep
                enabled: screen.adas.connected
                lockReason: "ADAS 공급자 연결 전"
                onToggled: function (v) { screen.adas.laneKeep = v; screen.notify(v ? "차로 이탈 방지 켜짐" : "차로 이탈 방지 꺼짐", "adas") }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "차로 중앙 유지"
                checked: screen.adas.laneCentering
                enabled: screen.adas.connected
                lockReason: "ADAS 공급자 연결 전"
                onToggled: function (v) { screen.adas.laneCentering = v }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "후측방 충돌 경고"
                checked: screen.adas.blindSpot
                enabled: screen.adas.connected
                lockReason: "ADAS 공급자 연결 전"
                onToggled: function (v) { screen.adas.blindSpot = v }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "전방 충돌 방지 보조"
                checked: screen.adas.forwardCollision
                enabled: screen.adas.connected
                lockReason: "ADAS 공급자 연결 전"
                onToggled: function (v) { screen.adas.forwardCollision = v }
            }

            Item { Layout.fillHeight: true }

            Text {
                text: "이 HMI는 ADAS 판단을 수행하지 않습니다. 표시되는 상태는 공급자가 보고한 값입니다."
                color: Tokens.inkTertiary
                font.pixelSize: Tokens.label
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
