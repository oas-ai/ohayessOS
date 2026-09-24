pragma Singleton
import QtQuick

// Single source of truth for the OAS Automotive OS design system.
// See apps/hmi/design/01-DESIGN-TOKENS.md. No other QML file declares a hex
// literal, a duration, or a touch dimension.
QtObject {
    id: tokens

    property bool dark: true
    // Main assigns the live window size; every adaptive value derives from it.
    property int viewportWidth: 1920
    property int viewportHeight: 1080

    // ── Surface ───────────────────────────────────────────────────────────
    readonly property color bg:            dark ? "#0B0C0E" : "#F2F3F5"
    readonly property color surface:       dark ? "#16181C" : "#FFFFFF"
    readonly property color surfaceAlt:    dark ? "#202329" : "#E9EBEE"
    readonly property color surfaceRaised: dark ? "#2A2E36" : "#DDE0E4"
    readonly property color borderSubtle:  dark ? "#24272E" : "#E2E5E9"
    readonly property color borderStrong:  dark ? "#363B44" : "#C9CDD3"

    // ── Text ──────────────────────────────────────────────────────────────
    readonly property color textPrimary:   dark ? "#FFFFFF" : "#101215"
    readonly property color textSecondary: dark ? "#A5A7AB" : "#5A5E66"
    readonly property color textTertiary:  dark ? "#6E7176" : "#7E838B"
    readonly property color textDisabled:  dark ? "#4A4D53" : "#B0B4BA"

    // ── Accent · Genesis copper ───────────────────────────────────────────
    // Reserved for active, selected and emphasised values. Never a warning.
    readonly property color accent:     dark ? "#C08B5C" : "#8A6039"
    readonly property color accentHi:   dark ? "#E8C39E" : "#C08B5C"
    readonly property color accentDeep: dark ? "#7A5433" : "#5E3F24"

    // ── Semantic ──────────────────────────────────────────────────────────
    readonly property color warning:  dark ? "#F2A93B" : "#B97708"
    readonly property color critical: dark ? "#E5484D" : "#C62A2F"
    readonly property color success:  dark ? "#4CC38A" : "#1F8F5B"
    readonly property color info:     dark ? "#7FA8C9" : "#41688A"

    // Text and icons drawn on top of an accent fill.
    readonly property color onAccent: dark ? "#16181C" : "#FFFFFF"

    // ── Illustration surfaces ─────────────────────────────────────────────
    // Used only by VehicleVisual and MapSurface. They are rendering materials,
    // not UI chrome, but they live here so no other QML file carries a colour.
    readonly property color ground:    dark ? "#0E1013" : "#E8EAED"
    readonly property color videoInk:  dark ? "#050607" : "#1A1D21"
    readonly property color glazing:   dark ? "#0D1117" : "#AEB8C4"
    readonly property color bodyHigh:  dark ? "#343A44" : "#FFFFFF"
    readonly property color bodyMid:   dark ? "#232932" : "#E4E8ED"
    readonly property color bodyLow:   dark ? "#171B22" : "#C9CFD7"
    readonly property color doorPanel: dark ? "#2A3039" : "#DCE1E7"
    readonly property color tyre:      dark ? "#05070A" : "#9AA0A8"
    readonly property color mapBlock:  dark ? "#1A1E24" : "#D3D8DE"
    readonly property color mapRoad:   dark ? "#262C34" : "#C2C9D1"

    function wash(tone, alpha) { return Qt.rgba(tone.r, tone.g, tone.b, alpha === undefined ? 0.12 : alpha) }
    readonly property color accentWash: wash(accent)
    readonly property color scrim: Qt.rgba(0, 0, 0, dark ? 0.62 : 0.40)

    // ── Typography ────────────────────────────────────────────────────────
    readonly property int speedHero:   Math.round(140 * typeScale)
    readonly property int speedLarge:  Math.round(104 * typeScale)
    readonly property int displayMd:   Math.round(72 * typeScale)
    readonly property int displaySm:   Math.round(48 * typeScale)
    readonly property int titlePage:   Math.round(32 * typeScale)
    readonly property int titleSection: Math.round(24 * typeScale)
    readonly property int bodyLg:      Math.round(20 * typeScale)
    readonly property int bodyMd:      Math.round(18 * typeScale)
    readonly property int label:       Math.round(15 * typeScale)
    readonly property int caption:     13

    // Display sizes grow on large panels; 13px stays the absolute floor.
    readonly property real typeScale: breakpoint === "compact" ? 0.82
                                    : breakpoint === "wide" ? 1.08
                                    : breakpoint === "ultrawide" ? 1.12 : 1.0

    readonly property int weightLight: Font.Light
    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightDemi: Font.DemiBold

    // ── Space ─────────────────────────────────────────────────────────────
    readonly property int s1: 4
    readonly property int s2: 8
    readonly property int s3: 12
    readonly property int s4: 16
    readonly property int s5: 24
    readonly property int s6: 32
    readonly property int s7: 40
    readonly property int s8: 64

    // ── Radius ────────────────────────────────────────────────────────────
    readonly property int rSm: 10
    readonly property int rMd: 16
    readonly property int rLg: 22
    readonly property int rXl: 28
    readonly property int rDock: 30
    readonly property int rPill: 999

    // ── Touch target ──────────────────────────────────────────────────────
    readonly property int touchMin: 48
    readonly property int touchBase: 56
    readonly property int touchLarge: 72
    readonly property int touchHero: 96

    // ── Motion ────────────────────────────────────────────────────────────
    readonly property int mInstant: 0
    readonly property int mFast: 150
    readonly property int mBase: 200
    readonly property int mSlow: 300
    readonly property int easeOut: Easing.OutCubic
    readonly property int easeInOut: Easing.InOutCubic

    // ── Icon ──────────────────────────────────────────────────────────────
    readonly property int iconSm: 20
    readonly property int iconMd: 24
    readonly property int iconLg: 32
    readonly property int iconXl: 48

    // ── Breakpoint ────────────────────────────────────────────────────────
    readonly property real aspect: viewportHeight > 0 ? viewportWidth / viewportHeight : 1.78
    readonly property string breakpoint:
        (viewportWidth >= 3200 || aspect >= 2.6) ? "ultrawide"
        : viewportWidth >= 2300 ? "wide"
        : viewportWidth >= 1600 ? "regular" : "compact"

    readonly property int screenMargin: breakpoint === "compact" ? s5
                                      : breakpoint === "regular" ? s6 : s7
    readonly property int gutter: s5
    readonly property int railHeight: breakpoint === "ultrawide" ? 64 : 56
    readonly property int dockHeight: breakpoint === "compact" ? 80
                                    : breakpoint === "ultrawide" ? 96 : 88
    readonly property int sideColumn: breakpoint === "wide" ? 400
                                    : breakpoint === "ultrawide" ? 360 : 340
    readonly property bool showSideColumns: breakpoint !== "compact"
    readonly property bool showPersistentMap: breakpoint === "ultrawide"

    // ── Runtime policy strings ────────────────────────────────────────────
    // Presentation only. The runtime owns the decision these describe.
    function playbackReason(code) {
        switch (code) {
        case "allowed": return "재생이 허용되었습니다";
        case "vehicle_in_motion": return "주행 중에는 영상이 일시 정지됩니다";
        case "not_parked": return "영상을 보려면 P에 주차하세요";
        case "stale_vehicle_state": return "최신 차량 상태를 기다리는 중입니다";
        case "no_vehicle_state": return "차량 상태 스트림을 연결하세요";
        default: return "재생 권한을 확인할 수 없습니다";
        }
    }
}
