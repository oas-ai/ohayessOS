import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OAS.HMI

ApplicationWindow {
    id: window
    width: 1440; height: 810
    minimumWidth: 1280; minimumHeight: 720
    visible: true
    title: "OAS · 차분한 미래 모빌리티"
    color: Theme.background
    property int page: 0
    property bool darkMode: true
    readonly property bool hasState: vehicleState.available
    readonly property string connection: vehicleState.freshness === "fresh" ? "연결됨" : vehicleState.freshness === "stale" ? "업데이트 지연" : "연결 대기 중"
    readonly property color stateColor: vehicleState.freshness === "fresh" ? Theme.success : Theme.warning

    onDarkModeChanged: Theme.darkMode = darkMode
    Component.onCompleted: Theme.darkMode = darkMode

    Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: Theme.horizon } GradientStop { position: 1; color: Theme.background } } }

    component Caption: Text { color: Theme.muted; font.pixelSize: 12; font.letterSpacing: 2; font.weight: Font.Medium }
    component Body: Text { color: Theme.muted; font.pixelSize: 16; wrapMode: Text.WordWrap; Layout.fillWidth: true }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 32; spacing: 24
        RowLayout {
            Layout.fillWidth: true; Layout.preferredHeight: 42; spacing: 20
            Text { text: "o a s"; color: Theme.text; font.pixelSize: 27; font.weight: Font.Medium }
            Rectangle { width: 1; height: 20; color: Theme.border }
            Caption { text: "차분한 미래 모빌리티" }
            Item { Layout.fillWidth: true }
            StatusPill { text: vehicleState.demo ? "데모 · 합성 상태" : "읽기 전용"; tone: Theme.cyan }
            Button {
                text: darkMode ? "밝은 화면" : "어두운 화면"
                Accessible.name: text
                onClicked: darkMode = !darkMode
                contentItem: Text { text: parent.text; color: Theme.text; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { radius: 17; color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.12); border.color: Theme.border }
                implicitWidth: 92; implicitHeight: 34
            }
            Text { text: connection; color: stateColor; font.pixelSize: 14 }
        }

        StackLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; currentIndex: page
            Item {
                RowLayout {
                    anchors.fill: parent; spacing: 24
                    ColumnLayout {
                        Layout.minimumWidth: 300; Layout.maximumWidth: 340; Layout.preferredWidth: 320; Layout.fillHeight: true; spacing: 16
                        GlassPanel {
                            Layout.fillWidth: true; Layout.preferredHeight: 260
                            ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 12
                                Caption { text: "내비게이션" }
                                Text { text: "목적지 없음"; color: Theme.text; font.pixelSize: 25; font.weight: Font.Medium }
                                Body { text: "지도 공급자를 연결하면 현재 위치와 다음 안내를 표시합니다." }
                                Item { Layout.fillHeight: true }
                                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 98; radius: 14; color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.08)
                                    Canvas { anchors.fill: parent; onPaint: { var c = getContext("2d"); c.reset(); c.strokeStyle = Theme.border; c.lineWidth = 2; c.beginPath(); c.moveTo(0, 76); c.lineTo(width * .32, 40); c.lineTo(width * .66, 60); c.lineTo(width, 15); c.stroke(); c.beginPath(); c.moveTo(width * .12, 0); c.lineTo(width * .38, height); c.moveTo(width * .7, 0); c.lineTo(width * .48, height); c.stroke(); } }
                                }
                                StatusPill { text: "지도 데이터 연결 전"; tone: Theme.muted }
                            }
                        }
                        RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 142; spacing: 16
                            GlassPanel { Layout.fillWidth: true; Layout.fillHeight: true
                                Column { anchors.fill: parent; anchors.margins: 20; spacing: 8
                                    Caption { text: "주행" }
                                    Text { text: hasState ? Math.round(vehicleState.speedKph) : "—"; color: Theme.text; font.pixelSize: 52; font.weight: Font.Light }
                                    Caption { text: "km/h" }
                                }
                            }
                            GlassPanel { Layout.fillWidth: true; Layout.fillHeight: true
                                Column { anchors.fill: parent; anchors.margins: 20; spacing: 8
                                    Caption { text: "연결" }
                                    Text { text: connection; color: stateColor; font.pixelSize: 20; font.weight: Font.Medium; width: parent.width; wrapMode: Text.WordWrap }
                                    Caption { text: "읽기 전용" }
                                }
                            }
                        }
                    }

                    GlassPanel {
                        Layout.minimumWidth: 400; Layout.fillWidth: true; Layout.fillHeight: true
                        Item {
                            anchors.fill: parent
                            Column { anchors.top: parent.top; anchors.topMargin: 26; anchors.horizontalCenter: parent.horizontalCenter; spacing: 7
                                Caption { text: "차량 개요"; anchors.horizontalCenter: parent.horizontalCenter }
                                Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 14; Repeater { model: ["P", "R", "N", "D"]; delegate: Text { required property string modelData; text: modelData; color: hasState && vehicleState.gear === modelData ? Theme.text : Theme.muted; font.pixelSize: 16; font.weight: hasState && vehicleState.gear === modelData ? Font.DemiBold : Font.Normal } } }
                            }
                            VehicleVisual { anchors.centerIn: parent; anchors.verticalCenterOffset: 12; width: parent.width * .9; height: Math.min(parent.height * .72, width * .75) }
                            Column { anchors.bottom: parent.bottom; anchors.bottomMargin: 24; anchors.horizontalCenter: parent.horizontalCenter; spacing: 0
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: hasState ? Math.round(vehicleState.speedKph) : "—"; color: Theme.text; font.pixelSize: 70; font.weight: Font.Light }
                                Caption { text: "km/h"; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.minimumWidth: 300; Layout.maximumWidth: 340; Layout.preferredWidth: 320; Layout.fillHeight: true; spacing: 16
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "미디어" }
                                Text { text: vehicleState.mediaPlaybackAllowed ? "재생 준비됨" : "재생 불가"; color: Theme.text; font.pixelSize: 25; font.weight: Font.Medium; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                Body { text: Theme.reason(vehicleState.mediaPlaybackReason) }
                                Item { Layout.fillHeight: true }
                                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 82; radius: 14; color: Theme.darkMode ? "#080A12" : "#17191D"; Text { anchors.centerIn: parent; text: "재생 소스 연결 전"; color: "#FFFFFF"; font.pixelSize: 15 } }
                            }
                        }
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "차량 상태" }
                                Text { text: "팰리세이드 / 2020"; color: Theme.text; font.pixelSize: 24; font.weight: Font.Medium }
                                Body { text: vehicleState.diagnosticsAvailable ? vehicleState.diagnosticsSummary : "최신 차량 데이터를 기다리고 있습니다." }
                                Item { Layout.fillHeight: true }
                                StatusPill { text: "제어 기능 사용 안 함"; tone: Theme.muted }
                            }
                        }
                    }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "지도 / 경로" }
                    Text { text: "다음 여정을 준비합니다."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: "지도 데이터 연결 전"; tone: Theme.muted }
                    Body { text: "현재 위치, 목적지, ETA, 교통 정보는 지도 공급자가 연결되면 이 화면에 오버레이로 표시됩니다." }
                    Item { Layout.fillHeight: true }
                    Text { text: "경로 없음"; color: Theme.muted; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "공조 / 편의" }
                    Text { text: "실내 환경"; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: "읽기 전용 · 제어 연결 전"; tone: Theme.muted }
                    Body { text: vehicleState.diagnosticsAvailable ? vehicleState.diagnosticsSummary : "온도와 시트 상태를 표시하려면 최신 차량 데이터가 필요합니다."; font.pixelSize: 23 }
                    Item { Layout.fillHeight: true }
                    Body { text: "온도, 팬, 열선·통풍은 향후 Runtime capability가 제공될 때만 표시·조작합니다." }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "나만의 공간 / 미디어" }
                    Text { text: "여정 속 작은 쉼표."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: vehicleState.mediaPlaybackAllowed ? "재생 권한 허용됨" : "재생 잠김"; tone: vehicleState.mediaPlaybackAllowed ? Theme.success : Theme.warning }
                    Body { text: Theme.reason(vehicleState.mediaPlaybackReason) }
                    Item { Layout.fillHeight: true }
                    Body { text: "미디어 플레이어가 설치되지 않았습니다. 재생 소스가 연결되면 재생과 오디오 제어가 표시됩니다." }
                }
            }
            GlassPanel {
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 48; spacing: 22
                    Caption { text: "팰리세이드 / 2020" }
                    Text { text: "연결됨. 읽기 전용."; color: Theme.text; font.pixelSize: 48; font.weight: Font.Light }
                    StatusPill { text: "차량 제어를 사용할 수 없음"; tone: Theme.muted }
                    Body { text: "이 설치 환경은 차량 정보만 표시합니다. 공조, 잠금, 조향, 주행 제어는 연결하지 않습니다." }
                    Item { Layout.fillHeight: true }
                    Caption { text: "진단 / 원시 DBC 신호" }
                    Body { text: vehicleState.diagnosticsAvailable ? vehicleState.diagnosticsSummary : "신호 값을 표시하려면 최신 차량 데이터가 필요합니다." }
                    Body { text: "ADAS, 에너지, 카메라, 전화, 설정, 소프트웨어 업데이트는 데이터·권한 공급자가 연결된 뒤 이 차량 공간에서 점진적으로 제공합니다." }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 24
            Caption { text: "OAS / 01"; Layout.preferredWidth: 160 }
            NavDock { Layout.fillWidth: true; Layout.preferredHeight: 76; selected: page; onNavigate: function(destination) { page = destination } }
            Text { text: "읽기 전용\n차량 플랫폼"; color: Theme.muted; font.pixelSize: 11; font.letterSpacing: 1.2; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 160 }
        }
    }
}
