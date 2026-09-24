pragma Singleton
import QtQuick

// The only definition of a destination. Everything reachable is in `all`, so
// the launcher menu is complete by construction and no screen is orphaned.
QtObject {
    readonly property int home: 0
    readonly property int navigation: 1
    readonly property int climate: 2
    readonly property int media: 3
    readonly property int phone: 4
    readonly property int camera: 5
    readonly property int vehicle: 6
    readonly property int settings: 7
    readonly property int adas: 8
    readonly property int energy: 9
    readonly property int software: 10
    readonly property int diagnostics: 11

    readonly property var titles: [
        "홈", "내비게이션", "공조", "미디어", "전화", "카메라", "차량", "설정",
        "주행 보조", "에너지", "소프트웨어", "진단"
    ]

    readonly property var all: [
        { page: 0,  label: "홈",        icon: "home" },
        { page: 1,  label: "내비게이션", icon: "navigation" },
        { page: 2,  label: "공조",       icon: "climate" },
        { page: 3,  label: "미디어",     icon: "media" },
        { page: 4,  label: "전화",       icon: "phone" },
        { page: 5,  label: "카메라",     icon: "camera" },
        { page: 6,  label: "차량",       icon: "vehicle" },
        { page: 7,  label: "설정",       icon: "settings" },
        { page: 8,  label: "주행 보조",  icon: "adas" },
        { page: 9,  label: "에너지",     icon: "battery" },
        { page: 10, label: "소프트웨어", icon: "download" },
        { page: 11, label: "진단",       icon: "pulse" }
    ]

    function title(page) { return titles[page] === undefined ? "" : titles[page] }
}
