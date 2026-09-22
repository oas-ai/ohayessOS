pragma Singleton
import QtQuick
QtObject {
    readonly property color background: "#080A12"
    readonly property color horizon: "#10182B"
    readonly property color surface: "#121d2d"
    readonly property color border: "#26374a"
    readonly property color text: "#F4F7FF"
    readonly property color muted: "#9BA9C7"
    readonly property color cyan: "#4BE7FF"
    readonly property color violet: "#8E7CFF"
    readonly property color success: "#57E3A1"
    readonly property color warning: "#FFB45B"
    readonly property color danger: "#FF6B78"
    readonly property int radius: 30
    readonly property int spacing: 24
    readonly property int motion: 240
    function reason(code) {
        switch (code) {
        case "allowed": return "Playback permission granted";
        case "vehicle_in_motion": return "Video is paused while moving";
        case "not_parked": return "Shift to Park to enable video";
        case "stale_vehicle_state": return "Waiting for a fresh vehicle update";
        case "no_vehicle_state": return "Connect a vehicle state stream";
        default: return "Playback permission unavailable";
        }
    }
}
