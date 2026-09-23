pragma Singleton
import QtQuick
QtObject {
    property bool darkMode: true
    readonly property color background: darkMode ? "#080A12" : "#F7F9FC"
    readonly property color horizon: darkMode ? "#10182B" : "#FFFFFF"
    readonly property color surface: darkMode ? "#121D2D" : "#FFFFFF"
    readonly property color surfaceTop: darkMode ? "#19283A" : "#FFFFFF"
    readonly property color surfaceBottom: darkMode ? "#101827" : "#F0F4F9"
    readonly property color border: darkMode ? "#26374A" : "#D9E1EB"
    readonly property color text: darkMode ? "#F4F7FF" : "#131927"
    readonly property color muted: darkMode ? "#9BA9C7" : "#62708A"
    readonly property color selection: darkMode ? "#283C50" : "#E1F7FC"
    readonly property color selectionBorder: darkMode ? "#416077" : "#9EDDE8"
    readonly property color cyan: "#4BE7FF"
    readonly property color violet: "#8E7CFF"
    readonly property color success: "#57E3A1"
    readonly property color warning: "#FFB45B"
    readonly property color danger: "#FF6B78"
    readonly property int radius: darkMode ? 30 : 20
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
