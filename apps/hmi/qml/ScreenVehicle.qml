import QtQuick
import QtQuick.Layouts
import OAS.HMI

// 05 Vehicle hub. Secondary destinations are large tiles, never a list.
Item {
    id: screen

    property var vehicle: null
    property bool driving: false
    signal navigate(int destination)
    signal notify(string message, string iconName)

    readonly property var lights: Providers.lights
    readonly property var locks: Providers.locks
    readonly property var energy: Providers.energy
    readonly property var adas: Providers.adas
    readonly property int columns: Tokens.breakpoint === "compact" ? 2
                                 : Tokens.breakpoint === "regular" ? 3 : 4

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.gutter

        Panel {
            Layout.fillWidth: true
            Layout.preferredHeight: 108

            RowLayout {
                anchors.fill: parent
                anchors.margins: Tokens.s5
                spacing: Tokens.s5

                ColumnLayout {
                    spacing: Tokens.s1
                    Text {
                        text: "차량"
                        color: Tokens.textPrimary
                        font.pixelSize: Tokens.titlePage
                        font.weight: Tokens.weightMedium
                    }
                    Text {
                        text: screen.vehicle && screen.vehicle.vehicleControlsAllowed
                            ? "차량 제어 권한이 허용되었습니다"
                            : "이 설치 환경은 차량 정보만 표시합니다"
                        color: Tokens.textTertiary
                        font.pixelSize: Tokens.label
                    }
                }

                Item { Layout.fillWidth: true }

                StatusBadge {
                    text: screen.vehicle && screen.vehicle.vehicleControlsAllowed ? "제어 허용" : "제어 전송 없음"
                    tone: screen.vehicle && screen.vehicle.vehicleControlsAllowed ? Tokens.success : Tokens.textTertiary
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: screen.columns
            columnSpacing: Tokens.gutter
            rowSpacing: Tokens.gutter

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "주행"
                iconName: "vehicle"
                summary: screen.vehicle && screen.vehicle.gearValid
                    ? "기어 " + screen.vehicle.gear + " · 가속 " + (screen.vehicle.accelerationValid ? screen.vehicle.accelerationMps2.toFixed(1) + " m/s²" : "—")
                    : "주행 신호 없음"
                onActivated: screen.navigate(Nav.diagnostics)
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "주행 보조"
                iconName: "adas"
                summary: screen.adas.connected ? "차로 유지 · 스마트 크루즈" : "ADAS 공급자 연결 전"
                onActivated: screen.navigate(Nav.adas)
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "조명"
                iconName: "light"
                summary: screen.lights.connected
                    ? ["꺼짐", "자동", "켜짐"][screen.lights.headlightMode] + " · 앰비언트 " + screen.lights.ambientLevel
                    : "조명 공급자 연결 전"
                active: screen.lights.lit
                onActivated: lightsPanel.open = true
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "잠금"
                iconName: screen.locks.allLocked ? "lock" : "unlock"
                summary: screen.locks.connected
                    ? (screen.locks.allLocked ? "전체 잠김" : "잠금 해제") + (screen.locks.autoLock ? " · 자동 잠금" : "")
                    : "잠금 공급자 연결 전"
                active: screen.locks.connected && screen.locks.allLocked
                onActivated: locksPanel.open = true
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "에너지"
                iconName: screen.energy.kind === "battery" ? "battery" : "fuel"
                summary: screen.energy.connected
                    ? Math.round(screen.energy.level * 100) + "% · " + Math.round(screen.energy.rangeKm) + " km"
                    : "에너지 공급자 연결 전"
                onActivated: screen.navigate(Nav.energy)
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "화면"
                iconName: "settings"
                summary: Tokens.dark ? "어두운 화면" : "밝은 화면"
                onActivated: screen.navigate(Nav.settings)
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "서비스"
                iconName: "wrench"
                summary: "정비 이력 공급자 연결 전"
                enabled: !screen.driving
                lockReason: "주행 중에는 열 수 없습니다"
                onActivated: screen.notify("정비 공급자 연결 전", "wrench")
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "소프트웨어"
                iconName: "download"
                summary: Providers.update.updateAvailable ? Providers.update.availableVersion + " 사용 가능" : Providers.update.currentVersion
                enabled: !screen.driving
                lockReason: "주행 중에는 열 수 없습니다"
                onActivated: screen.navigate(Nav.software)
            }

            CategoryTile {
                Layout.fillWidth: true; Layout.fillHeight: true
                title: "진단"
                iconName: "pulse"
                summary: screen.vehicle && screen.vehicle.diagnosticsAvailable
                    ? screen.vehicle.rawSignals.length + "개 신호 수신" : "진단 권한 없음"
                enabled: !screen.driving
                lockReason: "주행 중에는 열 수 없습니다"
                onActivated: screen.navigate(Nav.diagnostics)
            }
        }
    }

    SidePanel {
        id: lightsPanel
        title: "조명"

        ColumnLayout {
            anchors.fill: parent
            spacing: Tokens.s4

            Caption { text: "전조등" }

            OasSegmented {
                Layout.fillWidth: true
                model: ["꺼짐", "자동", "켜짐"]
                currentIndex: screen.lights.headlightMode
                enabled: screen.lights.connected
                onActivated: function (i) {
                    screen.lights.headlightMode = i
                    screen.notify("전조등 " + ["꺼짐", "자동", "켜짐"][i], "light")
                }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "상향등 보조"
                detail: "마주 오는 차량을 감지하면 자동으로 낮춥니다"
                checked: screen.lights.highBeam
                enabled: screen.lights.connected
                onToggled: function (v) { screen.lights.highBeam = v }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "안개등"
                checked: screen.lights.fog
                enabled: screen.lights.connected
                onToggled: function (v) { screen.lights.fog = v }
            }

            Divider { Layout.fillWidth: true }

            Caption { text: "실내 앰비언트" }

            OasSlider {
                Layout.fillWidth: true
                label: "밝기"
                from: 0
                to: screen.lights.maxAmbient
                stepSize: 1
                value: screen.lights.ambientLevel
                displayText: screen.lights.ambientLevel + " / " + screen.lights.maxAmbient
                enabled: screen.lights.connected
                onMoved: function (v) { screen.lights.ambientLevel = v }
            }

            Item { Layout.fillHeight: true }

            EmptyState {
                Layout.fillWidth: true
                visible: !screen.lights.connected
                iconName: "light"
                title: "조명 공급자 연결 전"
                detail: "조명 상태와 제어는 공급자가 연결된 뒤 활성화됩니다."
            }
        }
    }

    SidePanel {
        id: locksPanel
        title: "잠금"

        ColumnLayout {
            anchors.fill: parent
            spacing: Tokens.s4

            OasButton {
                Layout.fillWidth: true
                size: Tokens.touchLarge
                text: screen.locks.allLocked ? "전체 잠금 해제" : "전체 잠금"
                iconName: screen.locks.allLocked ? "unlock" : "lock"
                variant: "primary"
                enabled: screen.locks.connected
                onClicked: {
                    screen.locks.allLocked = !screen.locks.allLocked
                    screen.notify(screen.locks.allLocked ? "전체 잠금" : "전체 잠금 해제", screen.locks.allLocked ? "lock" : "unlock")
                }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "자동 잠금"
                detail: "주행을 시작하면 자동으로 잠급니다"
                checked: screen.locks.autoLock
                enabled: screen.locks.connected
                onToggled: function (v) { screen.locks.autoLock = v }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "하차 시 잠금"
                detail: "스마트키가 멀어지면 잠급니다"
                checked: screen.locks.walkAwayLock
                enabled: screen.locks.connected
                onToggled: function (v) { screen.locks.walkAwayLock = v }
            }

            OasToggle {
                Layout.fillWidth: true
                text: "뒷좌석 차일드 락"
                checked: screen.locks.childLock
                enabled: screen.locks.connected
                onToggled: function (v) { screen.locks.childLock = v }
            }

            Item { Layout.fillHeight: true }

            EmptyState {
                Layout.fillWidth: true
                visible: !screen.locks.connected
                iconName: "lock"
                title: "잠금 공급자 연결 전"
                detail: "도어 잠금 제어는 공급자가 연결된 뒤 활성화됩니다."
            }
        }
    }
}
