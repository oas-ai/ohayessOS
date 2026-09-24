pragma Singleton
import QtQuick

// Domain providers for everything the canonical VehicleState contract does not
// carry. Each provider reports `connected`; a screen renders an EmptyState
// rather than inventing a value when it is false.
//
// Nothing here is a vehicle command path. Writable properties are local UI
// state only, and stay so until a control transport exists.
QtObject {
    id: root

    // Set from the bridge. The only source of synthetic values in the product.
    property bool demo: false
    readonly property bool synthetic: demo

    // ── Navigation ────────────────────────────────────────────────────────
    readonly property QtObject navigation: QtObject {
        readonly property bool connected: root.demo
        readonly property bool routeActive: connected
        readonly property string destination: "서울특별시 강남구 테헤란로 152"
        readonly property string destinationShort: "테헤란로 152"
        readonly property string eta: "14:58"
        readonly property real remainingKm: 12.4
        readonly property int remainingMin: 26
        readonly property string nextTurnIcon: "turnLeft"
        readonly property int nextTurnDistanceM: 450
        readonly property string nextTurnRoad: "테헤란로"
        readonly property string nextTurnDetail: "좌회전 후 2차로 유지"
        readonly property string followingTurnIcon: "turnRight"
        readonly property string followingTurnRoad: "역삼로"
        // none · light · moderate · heavy
        readonly property string traffic: "moderate"
        readonly property var pois: [
            { name: "GS칼텍스 역삼", kind: "주유", distanceKm: 1.2, icon: "fuel" },
            { name: "환승 주차장", kind: "주차", distanceKm: 2.0, icon: "vehicle" },
            { name: "E-pit 강남", kind: "충전", distanceKm: 3.4, icon: "charge" }
        ]
    }

    // ── Climate ───────────────────────────────────────────────────────────
    // Writable: assigning breaks the demo binding, which is the intended
    // local-only behaviour until a climate transport exists.
    readonly property QtObject climate: QtObject {
        readonly property bool connected: root.demo
        property real driverTemp: root.demo ? 21.5 : 0
        property real passengerTemp: root.demo ? 22.0 : 0
        property int fanLevel: root.demo ? 3 : 0
        property int driverSeatHeat: root.demo ? 1 : 0
        property int passengerSeatHeat: 0
        property int driverSeatVent: 0
        property int passengerSeatVent: 0
        property bool sync: false
        property bool auto: root.demo
        property bool ac: root.demo
        property bool recirculate: false
        property bool defrostFront: false
        property bool defrostRear: false
        readonly property real minTemp: 17.0
        readonly property real maxTemp: 27.0
        readonly property int maxFan: 7
        readonly property real outsideTemp: 18.5
        readonly property bool outsideValid: connected
    }

    // ── Energy ────────────────────────────────────────────────────────────
    readonly property QtObject energy: QtObject {
        readonly property bool connected: root.demo
        // battery · fuel
        readonly property string kind: "battery"
        readonly property real level: 0.68
        readonly property real rangeKm: 412
        readonly property real consumptionKwhPer100: 17.4
        readonly property bool charging: false
        readonly property real chargePowerKw: 0
        readonly property int timeToFullMin: 0
        readonly property real capacityKwh: 77.4
        readonly property var recent: [
            { label: "최근 50 km", value: 16.8 },
            { label: "이번 주행", value: 17.4 },
            { label: "평균", value: 18.1 }
        ]
    }

    // ── Driver assistance ─────────────────────────────────────────────────
    readonly property QtObject adas: QtObject {
        readonly property bool connected: root.demo
        property bool laneKeep: root.demo
        property bool laneCentering: root.demo
        property bool blindSpot: root.demo
        property bool forwardCollision: root.demo
        property int followDistance: root.demo ? 2 : 0
        readonly property int maxFollowDistance: 4
        property int cruiseSetKph: root.demo ? 90 : 0
        readonly property bool lanesDetected: connected
        // lane: -1 left, 0 ego, 1 right. distance: 0 near … 1 far.
        readonly property var surroundings: [
            { lane: 0, distance: 0.42, kind: "car" },
            { lane: -1, distance: 0.66, kind: "truck" },
            { lane: 1, distance: 0.24, kind: "car" }
        ]
    }

    // ── Camera & parking ──────────────────────────────────────────────────
    readonly property QtObject camera: QtObject {
        readonly property bool connected: root.demo
        readonly property var views: ["후방", "서라운드", "전방", "측방"]
        // 0 clear … 1 immediate
        readonly property var rearSensors: [0.15, 0.62, 0.81, 0.44]
        readonly property var frontSensors: [0.0, 0.0, 0.12, 0.0]
    }

    // ── Media ─────────────────────────────────────────────────────────────
    readonly property QtObject media: QtObject {
        readonly property bool connected: root.demo
        property bool playing: root.demo
        readonly property string track: "Nocturne in E-flat major"
        readonly property string artist: "Op. 9 No. 2"
        readonly property string album: "Chopin · Nocturnes"
        property int sourceIndex: 0
        readonly property var sources: ["블루투스", "USB", "라디오"]
        property real positionSec: root.demo ? 84 : 0
        readonly property real durationSec: 268
        property real volume: root.demo ? 0.42 : 0
        readonly property var queue: [
            { track: "Nocturne in E-flat major", artist: "Op. 9 No. 2", duration: "4:28" },
            { track: "Prelude in D-flat major", artist: "Op. 28 No. 15", duration: "5:11" },
            { track: "Gymnopédie No. 1", artist: "Erik Satie", duration: "3:22" },
            { track: "Clair de Lune", artist: "Claude Debussy", duration: "5:04" },
            { track: "Arabesque No. 1", artist: "Claude Debussy", duration: "4:15" }
        ]
    }

    // ── Lights ────────────────────────────────────────────────────────────
    readonly property QtObject lights: QtObject {
        readonly property bool connected: root.demo
        // off · auto · on
        property int headlightMode: root.demo ? 1 : 0
        property bool highBeam: false
        property bool fog: false
        property int ambientLevel: root.demo ? 2 : 0
        readonly property int maxAmbient: 5
        // none · left · right · hazard
        property string turnSignal: "none"
        readonly property bool lit: connected && headlightMode > 0
    }

    // ── Locks ─────────────────────────────────────────────────────────────
    readonly property QtObject locks: QtObject {
        readonly property bool connected: root.demo
        property bool allLocked: root.demo
        property bool childLock: false
        property bool autoLock: root.demo
        property bool walkAwayLock: false
    }

    // ── Tyres ─────────────────────────────────────────────────────────────
    readonly property QtObject tires: QtObject {
        readonly property bool connected: root.demo
        readonly property var pressures: [
            { id: "frontLeft",  label: "앞 좌", kpa: 241, state: "ok" },
            { id: "frontRight", label: "앞 우", kpa: 238, state: "ok" },
            { id: "rearLeft",   label: "뒤 좌", kpa: 196, state: "warn" },
            { id: "rearRight",  label: "뒤 우", kpa: 243, state: "ok" }
        ]
        readonly property bool anyWarning: connected
    }

    // ── Phone ─────────────────────────────────────────────────────────────
    readonly property QtObject phone: QtObject {
        readonly property bool connected: root.demo
        readonly property string device: "Driver iPhone"
        readonly property int signalBars: 4
        readonly property int batteryPercent: 78
        readonly property var recents: [
            { name: "집", detail: "부재중 · 어제", icon: "home", missed: true },
            { name: "정비소 예약", detail: "발신 · 3일 전", icon: "wrench", missed: false },
            { name: "0212345678", detail: "수신 · 3일 전", icon: "phone", missed: false }
        ]
        readonly property var favorites: [
            { name: "집", icon: "home" },
            { name: "직장", icon: "vehicle" },
            { name: "정비소", icon: "wrench" }
        ]
    }

    // ── Software ──────────────────────────────────────────────────────────
    readonly property QtObject update: QtObject {
        readonly property bool connected: root.demo
        readonly property string currentVersion: "OAS 0.1.0"
        readonly property string availableVersion: "OAS 0.2.0"
        readonly property bool updateAvailable: connected
        readonly property real sizeMb: 412
        readonly property var notes: [
            "차량 시각화가 도어·안전벨트·조향 신호를 실시간 반영합니다.",
            "공조 화면에서 온도를 드래그로 조절합니다.",
            "진단 화면이 원시 CAN 신호를 정렬해 표시합니다."
        ]
    }
}
