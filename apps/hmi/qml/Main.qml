import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OAS.HMI

// OAS Automotive OS shell. Twelve screens share one status rail, one dock and
// one set of components, so no destination reads as a separate app.
ApplicationWindow {
    id: window

    width: 1920; height: 1080
    minimumWidth: 1280; minimumHeight: 720
    visible: true
    title: "OAS Automotive OS"
    color: Tokens.bg

    // main.cpp drives these two.
    property int page: Nav.home
    property bool darkMode: true
    // 0 auto · 1 light · 2 dark
    property int appearanceMode: 2

    readonly property bool driving: vehicleState.speedValid && vehicleState.speedKph > 3
    readonly property bool reversing: vehicleState.gearValid && vehicleState.gear === "R"

    // Auto follows the vehicle's own night signal; with no signal it stays dark,
    // which is the default theme rather than a guess about the cabin.
    readonly property bool resolvedDark: appearanceMode === 1 ? false
        : appearanceMode === 2 ? true
        : (vehicleState.nightModeValid ? vehicleState.nightMode : true)

    onResolvedDarkChanged: Tokens.dark = resolvedDark
    onDarkModeChanged: appearanceMode = darkMode ? 2 : 1
    Component.onCompleted: {
        Providers.demo = Qt.binding(function () { return vehicleState.demo })
        Tokens.dark = resolvedDark
    }

    // ── Automatic surfacing: reverse gear is the only one ─────────────────
    property int _pageBeforeReverse: -1
    function applyReverseSurfacing() {
        if (reversing) {
            if (page !== Nav.camera) { _pageBeforeReverse = page; page = Nav.camera }
        } else if (_pageBeforeReverse >= 0) {
            page = _pageBeforeReverse
            _pageBeforeReverse = -1
        }
    }
    onReversingChanged: applyReverseSurfacing()

    // Booting with reverse already engaged has to surface the camera too, and
    // the rule runs after the host has assigned the starting page.
    Timer { interval: 0; running: true; onTriggered: window.applyReverseSurfacing() }

    function go(destination) { if (page !== destination) page = destination }
    function notify(message, iconName) { toast.show(message, iconName) }

    // ── Safety conditions ─────────────────────────────────────────────────
    readonly property bool doorOpenWhileDriving: driving && vehicleState.doorsValid && vehicleState.anyDoorOpen
    readonly property bool beltOpenWhileDriving: driving && vehicleState.seatbeltsValid && vehicleState.anyBeltUnlatched
    readonly property bool stateStale: vehicleState.freshness === "stale"
    readonly property bool anyCritical: doorOpenWhileDriving || beltOpenWhileDriving || stateStale

    // Every adaptive token derives from the live window size.
    Binding { target: Tokens; property: "viewportWidth"; value: window.width }
    Binding { target: Tokens; property: "viewportHeight"; value: window.height }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: Tokens.dark ? Qt.lighter(Tokens.bg, 1.25) : Tokens.bg }
            GradientStop { position: 1; color: Tokens.bg }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.screenMargin
        spacing: Tokens.gutter

        StatusRail {
            Layout.fillWidth: true
            clock: Qt.formatTime(clockSource.now, "HH:mm")
            connection: vehicleState.freshness === "fresh" ? "연결됨"
                : vehicleState.freshness === "stale" ? "업데이트 지연" : "연결 대기 중"
            connectionTone: vehicleState.freshness === "fresh" ? Tokens.success
                : vehicleState.freshness === "stale" ? Tokens.warning : Tokens.textTertiary
            synthetic: vehicleState.demo
            outsideTemp: Providers.climate.outsideTemp.toFixed(1) + " °C"
            outsideValid: Providers.climate.outsideValid
            onAppearanceToggled: window.appearanceMode = Tokens.dark ? 1 : 2
        }

        CriticalOverlay {
            Layout.fillWidth: true
            Layout.preferredHeight: 104
            visible: window.anyCritical
            opacity: window.anyCritical ? 1 : 0
            tone: window.stateStale ? Tokens.warning : Tokens.critical
            title: window.doorOpenWhileDriving ? "주행 중 도어가 열려 있습니다"
                : window.beltOpenWhileDriving ? "안전벨트를 착용하지 않은 좌석이 있습니다"
                : "차량 상태 업데이트가 지연되고 있습니다"
            detail: window.doorOpenWhileDriving ? "안전한 곳에 정차한 뒤 도어를 닫으세요."
                : window.beltOpenWhileDriving ? "모든 탑승자가 안전벨트를 착용해야 합니다."
                : "주행 수치를 표시하지 않습니다. 오래된 값은 없는 값보다 위험합니다."
            recovery: window.stateStale ? "Gateway 연결이 복구되면 자동으로 사라집니다."
                : "조건이 해제되면 자동으로 사라집니다."
        }

        // ── Screens ───────────────────────────────────────────────────────
        Item {
            id: stage
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                id: stack
                anchors.fill: parent
                currentIndex: window.page

                ScreenHome {
                    vehicle: vehicleState
                    onNavigate: function (d) { window.go(d) }
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenNavigation {
                    vehicle: vehicleState
                    driving: window.driving
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenClimate {
                    vehicle: vehicleState
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenMedia {
                    vehicle: vehicleState
                    driving: window.driving
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenPhone {
                    vehicle: vehicleState
                    driving: window.driving
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenCamera {
                    vehicle: vehicleState
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenVehicle {
                    vehicle: vehicleState
                    driving: window.driving
                    onNavigate: function (d) { window.go(d) }
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenSettings {
                    vehicle: vehicleState
                    driving: window.driving
                    appearanceMode: window.appearanceMode
                    onAppearanceSelected: function (mode) { window.appearanceMode = mode }
                    onNavigate: function (d) { window.go(d) }
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenAdas {
                    vehicle: vehicleState
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenEnergy {
                    vehicle: vehicleState
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenSoftware {
                    vehicle: vehicleState
                    driving: window.driving
                    onNotify: function (m, i) { window.notify(m, i) }
                }

                ScreenDiagnostics {
                    vehicle: vehicleState
                    onNotify: function (m, i) { window.notify(m, i) }
                }
            }

            // Screen change: 300ms fade and rise, the same for every destination.
            Connections {
                target: window
                function onPageChanged() { enter.restart() }
            }

            SequentialAnimation {
                id: enter
                PropertyAction { target: stack; property: "opacity"; value: 0 }
                PropertyAction { target: stack; property: "y"; value: 12 }
                ParallelAnimation {
                    NumberAnimation { target: stack; property: "opacity"; to: 1; duration: Tokens.mSlow; easing.type: Tokens.easeInOut }
                    NumberAnimation { target: stack; property: "y"; to: 0; duration: Tokens.mSlow; easing.type: Tokens.easeInOut }
                }
            }
        }

        // ── Global mini player ────────────────────────────────────────────
        // Suppressed on the Media screen so one transport is never duplicated.
        Panel {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.touchHero + Tokens.s5
            visible: Providers.media.connected && Providers.media.playing
                && window.page !== Nav.media && Tokens.showSideColumns

            MediaMiniPlayer {
                anchors.fill: parent
                anchors.margins: Tokens.s3
                anchors.leftMargin: Tokens.s5
                anchors.rightMargin: Tokens.s5
                available: vehicleState.mediaPlaybackAllowed
                lockReason: Tokens.playbackReason(vehicleState.mediaPlaybackReason)
                track: Providers.media.track
                artist: Providers.media.artist
                playing: Providers.media.playing
                onToggled: {
                    Providers.media.playing = !Providers.media.playing
                    window.notify(Providers.media.playing ? "재생" : "일시정지", Providers.media.playing ? "play" : "pause")
                }
                onExpand: window.go(Nav.media)
                onPrevious: window.notify("이전 곡", "prev")
                onNext: window.notify("다음 곡", "next")
            }
        }

        ControlDock {
            Layout.fillWidth: true
            selected: window.page
            onNavigate: function (destination) { window.go(destination) }
        }
    }

    Toast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Tokens.dockHeight + Tokens.screenMargin + Tokens.s5
    }

    Timer {
        id: clockSource
        property date now: new Date()
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: now = new Date()
    }

    // Number keys move straight to a dock destination.
    Shortcut { sequence: "1"; onActivated: window.go(Nav.home) }
    Shortcut { sequence: "2"; onActivated: window.go(Nav.navigation) }
    Shortcut { sequence: "3"; onActivated: window.go(Nav.climate) }
    Shortcut { sequence: "4"; onActivated: window.go(Nav.media) }
    Shortcut { sequence: "5"; onActivated: window.go(Nav.phone) }
    Shortcut { sequence: "6"; onActivated: window.go(Nav.camera) }
    Shortcut { sequence: "7"; onActivated: window.go(Nav.vehicle) }
    Shortcut { sequence: "8"; onActivated: window.go(Nav.settings) }
}
