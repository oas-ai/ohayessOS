import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 08 Camera. Reverse gear brings this screen forward automatically; it is the
// only automatic screen change in the system.
Item {
    id: screen

    property var vehicle: null
    signal notify(string message, string iconName)

    readonly property var camera: Providers.camera
    readonly property bool reversing: vehicle ? (vehicle.gearValid && vehicle.gear === "R") : false
    property int view: 0

    GridBoard {
        anchors.fill: parent
        columns: Tokens.showSideColumns ? 2 : 1

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
            spacing: Tokens.s4

            RowLayout {
                Layout.fillWidth: true
                Caption { text: "카메라" }
                Item { Layout.fillWidth: true }
                StatusBadge {
                    visible: screen.reversing
                    text: "후진 중"
                    tone: Tokens.warning
                }
            }

            // Camera feed surface. No camera pipeline exists, so this stays an
            // explicit waiting state rather than a fabricated image.
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 200
                color: Tokens.surfaceInk

                EmptyState {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - Tokens.s8, 460)
                    iconName: "camera"
                    title: "카메라 영상 연결 전"
                    detail: "카메라 하드웨어와 영상 파이프라인이 준비되면 " +
                            (screen.camera.connected ? screen.camera.views[screen.view] : "선택한") +
                            " 뷰가 이 표면에 표시됩니다."
                    badge: "영상 없음"
                }
            }

            OasSegmented {
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.touchHero
                model: screen.camera.connected ? screen.camera.views : ["후방", "서라운드", "전방", "측방"]
                currentIndex: screen.view
                enabled: screen.camera.connected
                onActivated: function (i) { screen.view = i }
            }
        }

        Cell {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            spacing: Tokens.s4

            Caption { text: "주차 센서" }

            EmptyState {
                Layout.fillWidth: true
                visible: !screen.camera.connected
                iconName: "pulse"
                title: "센서 연결 전"
                detail: "초음파 센서가 연결되면 전방과 후방의 근접도가 차량 주위에 표시됩니다."
            }

            VehicleVisual {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 220
                visible: screen.camera.connected

                gear: screen.vehicle ? screen.vehicle.gear : "—"
                gearValid: screen.vehicle ? screen.vehicle.gearValid : false
                steeringAngleDeg: screen.vehicle ? screen.vehicle.steeringAngleDeg : 0
                steeringValid: screen.vehicle ? screen.vehicle.steeringValid : false
                doors: screen.vehicle ? screen.vehicle.doors : []
                doorsValid: screen.vehicle ? screen.vehicle.doorsValid : false
                seatbelts: screen.vehicle ? screen.vehicle.seatbelts : []
                seatbeltsValid: screen.vehicle ? screen.vehicle.seatbeltsValid : false
                parkingSensors: screen.camera.connected
                    ? screen.camera.frontSensors.concat(screen.camera.rearSensors) : []
            }

            Text {
                visible: screen.camera.connected
                text: "가장 가까운 장애물까지 약 0.4 m"
                color: Tokens.warning
                font.pixelSize: Tokens.label
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
    }
}
