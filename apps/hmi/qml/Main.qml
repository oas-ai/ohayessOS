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
                        Layout.minimumWidth: 240; Layout.maximumWidth: 240; Layout.preferredWidth: 240; Layout.fillHeight: true; spacing: 16
                        Caption { text: "현재 주행" }
                        Text { text: hasState ? "지금 이 순간에 집중하세요." : "차량 상태를 기다리고 있습니다."; color: Theme.text; font.pixelSize: 27; font.weight: Font.Light; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                        Text { text: hasState ? Math.round(vehicleState.speedKph) : "—"; color: Theme.text; font.pixelSize: 136; font.weight: Font.Light; font.letterSpacing: -7 }
                        Caption { text: "킬로미터 / 시" }
                        Item { Layout.preferredHeight: 12 }
                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: ["P", "R", "N", "D"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 46; height: 46; radius: 15
                                    color: hasState && vehicleState.gear === modelData ? Theme.selection : "transparent"
                                    border.color: hasState && vehicleState.gear === modelData ? Theme.selectionBorder : "transparent"
                                    Text { anchors.centerIn: parent; text: modelData; color: hasState && vehicleState.gear === modelData ? Theme.cyan : Theme.muted; font.pixelSize: 21 }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                        Caption { text: "팰리세이드 / 2020" }
                        Body { text: "여정에 더 조용하게\n연결됩니다." }
                    }

                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        Column {
                            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; spacing: 12
                            Caption { text: "차량 개요"; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "여유로운 이동."; color: Theme.text; font.pixelSize: 34; font.weight: Font.Light; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                        VehicleVisual { anchors.centerIn: parent; anchors.verticalCenterOffset: 10; width: parent.width; height: Math.min(parent.height - 120, width * 0.78) }
                        Column {
                            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                            StatusPill { anchors.horizontalCenter: parent.horizontalCenter; text: vehicleState.freshness === "fresh" ? "상태 수신됨" : vehicleState.freshness === "stale" ? "신호 지연" : "신호 대기 중"; tone: stateColor }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "콘셉트 일러스트 · 주변 환경을 감지하지 않습니다"; color: Theme.muted; font.pixelSize: 11 }
                        }
                    }

                    ColumnLayout {
                        Layout.minimumWidth: 288; Layout.maximumWidth: 288; Layout.preferredWidth: 288; Layout.fillHeight: true; spacing: 16
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "연결 상태" }
                                Text { text: connection; color: Theme.text; font.pixelSize: 25; font.weight: Font.Light; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                Body { text: vehicleState.freshness === "fresh" ? "차량 데이터를 받고 있습니다.\n제어 기능은 읽기 전용입니다." : "최신 데이터가 도착할 때까지 주행 값은 표시하지 않습니다." }
                                Item { Layout.fillHeight: true }
                                StatusPill { text: "차량 제어 사용 안 함"; tone: Theme.muted }
                            }
                        }
                        GlassPanel {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 24; spacing: 14
                                Caption { text: "미디어 / 영상" }
                                Text { text: vehicleState.mediaPlaybackAllowed ? "잠시\n쉬어가세요." : "여정을\n즐기세요."; color: Theme.text; font.pixelSize: 29; font.weight: Font.Light }
                                Body { text: Theme.reason(vehicleState.mediaPlaybackReason) }
                                Item { Layout.fillHeight: true }
                                StatusPill { text: vehicleState.mediaPlaybackAllowed ? "허용됨 · 플레이어 없음" : "재생 불가"; tone: vehicleState.mediaPlaybackAllowed ? Theme.cyan : Theme.muted }
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
