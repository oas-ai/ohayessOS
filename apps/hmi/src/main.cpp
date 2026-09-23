#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QQuickWindow>
#include <QTimer>
#include <QImage>
#include <cmath>
#include <limits>

#include "vehicle_state_bridge.h"

int main(int argc, char *argv[]) {
  qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
  QGuiApplication app(argc, argv);
  QCommandLineParser parser;
  QCommandLineOption streamOption("stream", "HmiState FIFO 경로.", "path", "/run/ohayess/vehicle-state");
  QCommandLineOption maximumAgeOption("maximum-age-ms", "허용할 VehicleState 최대 경과 시간.", "milliseconds", "500");
  QCommandLineOption demoOption("demo", "스트림 없이 읽기 전용 개발 미리보기를 표시합니다.");
  parser.addOption(streamOption);
  parser.addOption(maximumAgeOption);
  parser.addOption(demoOption);
  parser.addOption({"scenario", "데모 프리셋: drive, park, waiting, stale.", "name", "drive"});
  parser.addOption({"demo-speed-kph", "데모 속도를 km/h 단위로 주입합니다.", "value"});
  parser.addOption({"demo-gear", "데모 기어를 주입합니다: P, R, N, D.", "gear"});
  parser.addOption({"capture", "렌더링한 PNG를 저장하고 종료합니다.", "path"});
  parser.addOption({"size", "미리보기 창 크기.", "WIDTHxHEIGHT", "1440x810"});
  parser.addOption({"page", "처음 열 화면: drive, media, diagnostics, vehicle.", "name", "drive"});
  parser.addOption({"expect-speed", "실시간 속도가 도착한 뒤 PNG를 저장합니다(km/h). 10초 뒤 실패합니다.", "value"});
  parser.process(app);
  bool validAge = false;
  const auto maximumAge = parser.value(maximumAgeOption).toULongLong(&validAge);
  if (!validAge || maximumAge == 0 || maximumAge > std::numeric_limits<quint64>::max() / 1'000'000) return 2;
  const auto scenario = parser.value("scenario");
  if (!QStringList{"drive", "park", "waiting", "stale"}.contains(scenario)) return 2;
  const auto dimensions = parser.value("size").split('x');
  if (dimensions.size() != 2 || dimensions[0].toInt() < 1280 || dimensions[1].toInt() < 720) return 2;
  const auto page = QStringList{"drive", "media", "diagnostics", "vehicle"}.indexOf(parser.value("page"));
  if (page < 0) return 2;
  std::optional<double> demoSpeed;
  if (parser.isSet("demo-speed-kph")) {
    bool validSpeed = false;
    const auto speed = parser.value("demo-speed-kph").toDouble(&validSpeed);
    if (!validSpeed || !std::isfinite(speed) || speed < 0 || speed > 400) return 2;
    demoSpeed = speed;
  }
  std::optional<QString> demoGear;
  if (parser.isSet("demo-gear")) {
    const auto gear = parser.value("demo-gear").trimmed().toUpper();
    if (!QStringList{"P", "R", "N", "D"}.contains(gear)) return 2;
    demoGear = gear;
  }
  if ((demoSpeed || demoGear) && !parser.isSet(demoOption)) return 2;
  VehicleStateBridge vehicleState(parser.value(streamOption), maximumAge);
  if (parser.isSet(demoOption)) vehicleState.showDemo(scenario, demoSpeed, demoGear);
  QQmlApplicationEngine engine;
  engine.addImportPath("qrc:/");
  engine.rootContext()->setContextProperty("vehicleState", &vehicleState);
  engine.load(QUrl("qrc:/OAS/HMI/qml/Main.qml"));
  if (engine.rootObjects().isEmpty()) return 1;
  auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
  if (!window) return 1;
  window->resize(dimensions[0].toInt(), dimensions[1].toInt());
  window->setProperty("page", page);
  if (parser.isSet("capture")) {
    if (parser.isSet("expect-speed")) {
      bool ok = false;
      const auto expected = parser.value("expect-speed").toDouble(&ok);
      if (!ok || !std::isfinite(expected) || parser.isSet(demoOption)) return 2;
      auto *poll = new QTimer(&app);
      QObject::connect(poll, &QTimer::timeout, &app, [&, expected] {
        if (vehicleState.available() && std::abs(vehicleState.speedKph() - expected) < 0.1 && vehicleState.diagnosticsAvailable()) {
          app.exit(window->grabWindow().save(parser.value("capture")) ? 0 : 1);
        }
      });
      poll->start(100);
      QTimer::singleShot(10000, &app, [&] { app.exit(1); });
    } else {
      QTimer::singleShot(1000, &app, [&] {
        app.exit(window->grabWindow().save(parser.value("capture")) ? 0 : 1);
      });
    }
  }
  return app.exec();
}
