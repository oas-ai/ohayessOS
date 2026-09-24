pragma Singleton
import QtQuick

// OAS Automotive OS design system — "Grid".
//
// A hairline Swiss grid rather than floating cards: cells meet, separated by a
// single rule. Zero radius, no shadows, no blur. Monochrome, where emphasis is
// contrast and weight; colour is reserved for safety meaning alone.
//
// See apps/hmi/design/01-DESIGN-TOKENS.md. No other QML file declares a colour,
// a duration or a touch dimension.
QtObject {
    id: tokens

    property bool dark: false
    property int viewportWidth: 1920
    property int viewportHeight: 1080

    // ── Ground and paper ──────────────────────────────────────────────────
    readonly property color bg:         dark ? "#0E0E0D" : "#EDEDEB"
    readonly property color surface:    dark ? "#161615" : "#F4F4F2"
    readonly property color surfaceAlt: dark ? "#201F1E" : "#E4E4E0"
    readonly property color surfaceInk: dark ? "#2C2B29" : "#DCDCD7"

    // ── Rules ─────────────────────────────────────────────────────────────
    // The grid is built from `line`; `lineStrong` separates major regions.
    readonly property color line:       dark ? "#2A2A28" : "#D6D6D2"
    readonly property color lineStrong: dark ? "#43423F" : "#B9B9B3"

    // ── Ink ───────────────────────────────────────────────────────────────
    readonly property color ink:          dark ? "#F2F2F0" : "#111111"
    readonly property color inkSecondary: dark ? "#A3A29B" : "#6E6E68"
    readonly property color inkTertiary:  dark ? "#77776F" : "#9A9A93"
    readonly property color inkDisabled:  dark ? "#4E4E48" : "#BEBEB7"
    // Text drawn on top of a solid ink fill.
    readonly property color onInk:        dark ? "#0E0E0D" : "#F4F4F2"

    // ── Safety colour ─────────────────────────────────────────────────────
    // The only colour in the system. Anything coloured means something.
    readonly property color warning:  dark ? "#E2A244" : "#9A5B00"
    readonly property color critical: dark ? "#F2635A" : "#B3261E"
    readonly property color success:  dark ? "#5BC08D" : "#2E6B4F"

    function wash(tone, alpha) { return Qt.rgba(tone.r, tone.g, tone.b, alpha === undefined ? 0.12 : alpha) }
    readonly property color scrim: Qt.rgba(0, 0, 0, dark ? 0.55 : 0.22)

    // ── Typography ────────────────────────────────────────────────────────
    // Data is set in DemiBold and sits under a small, sentence-case grey label.
    readonly property int dataHero: Math.round(118 * typeScale)
    readonly property int dataXl:   Math.round(72 * typeScale)
    readonly property int dataLg:   Math.round(46 * typeScale)
    readonly property int dataMd:   Math.round(32 * typeScale)
    readonly property int titleLg:  Math.round(30 * typeScale)
    readonly property int titleMd:  Math.round(22 * typeScale)
    readonly property int bodyLg:   Math.round(19 * typeScale)
    readonly property int bodyMd:   Math.round(17 * typeScale)
    readonly property int label:    Math.round(15 * typeScale)
    readonly property int caption:  13

    readonly property real typeScale: breakpoint === "compact" ? 0.84
                                    : breakpoint === "wide" ? 1.06
                                    : breakpoint === "ultrawide" ? 1.10 : 1.0

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
    // Zero, everywhere. The grid does the separating; corners do not.
    readonly property int radius: 0

    // ── Rule weight ───────────────────────────────────────────────────────
    readonly property int hairline: 1

    // ── Touch target ──────────────────────────────────────────────────────
    readonly property int touchMin: 48
    readonly property int touchBase: 56
    readonly property int touchLarge: 72
    readonly property int touchHero: 96

    // ── Motion ────────────────────────────────────────────────────────────
    readonly property int mInstant: 0
    readonly property int mFast: 120
    readonly property int mBase: 180
    readonly property int mSlow: 260
    readonly property int easeOut: Easing.OutCubic
    readonly property int easeInOut: Easing.InOutCubic

    // ── Icon ──────────────────────────────────────────────────────────────
    readonly property int iconSm: 18
    readonly property int iconMd: 22
    readonly property int iconLg: 28
    readonly property int iconXl: 40

    // ── Breakpoint ────────────────────────────────────────────────────────
    readonly property real aspect: viewportHeight > 0 ? viewportWidth / viewportHeight : 1.78
    readonly property string breakpoint:
        (viewportWidth >= 3200 || aspect >= 2.6) ? "ultrawide"
        : viewportWidth >= 2300 ? "wide"
        : viewportWidth >= 1600 ? "regular" : "compact"

    readonly property int screenMargin: breakpoint === "compact" ? 0 : 0
    readonly property int cellPadding: breakpoint === "compact" ? s4 : s5
    readonly property int railHeight: breakpoint === "compact" ? 64 : 72
    readonly property int launcherHeight: breakpoint === "compact" ? 64 : 72
    readonly property bool showSideColumns: breakpoint !== "compact"
    readonly property bool showPersistentMap: breakpoint === "ultrawide"
    // Metric cells per row.
    readonly property int metricColumns: breakpoint === "compact" ? 2
                                       : breakpoint === "regular" ? 4
                                       : breakpoint === "wide" ? 4 : 6

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
