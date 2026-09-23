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
        case "allowed": return "재생이 허용되었습니다";
        case "vehicle_in_motion": return "주행 중에는 영상이 일시 정지됩니다";
        case "not_parked": return "영상을 보려면 P에 주차하세요";
        case "stale_vehicle_state": return "최신 차량 상태를 기다리는 중입니다";
        case "no_vehicle_state": return "차량 상태 스트림을 연결하세요";
        default: return "재생 권한을 확인할 수 없습니다";
        }
    }
}
