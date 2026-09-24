pragma Singleton
import QtQuick

// The eight dock destinations and the secondary destinations that live inside
// the Vehicle hub. Nothing else defines a route.
QtObject {
    readonly property int home: 0
    readonly property int navigation: 1
    readonly property int climate: 2
    readonly property int media: 3
    readonly property int phone: 4
    readonly property int camera: 5
    readonly property int vehicle: 6
    readonly property int settings: 7

    // Secondary destinations continue the same index space so one StackLayout
    // holds every screen and no screen is an isolated app.
    readonly property int adas: 8
    readonly property int energy: 9
    readonly property int software: 10
    readonly property int diagnostics: 11

    readonly property var dock: [
        { label: "홈",     icon: "home" },
        { label: "내비",   icon: "navigation" },
        { label: "공조",   icon: "climate" },
        { label: "미디어", icon: "media" },
        { label: "전화",   icon: "phone" },
        { label: "카메라", icon: "camera" },
        { label: "차량",   icon: "vehicle" },
        { label: "설정",   icon: "settings" }
    ]

    readonly property var titles: [
        "홈", "내비게이션", "공조", "미디어", "전화", "카메라", "차량", "설정",
        "주행 보조", "에너지", "소프트웨어 업데이트", "진단"
    ]

    function title(page) { return titles[page] === undefined ? "" : titles[page] }
}
