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
  QCommandLineOption streamOption("stream", "HmiState FIFO path.", "path", "/run/ohayess/vehicle-state");
  QCommandLineOption maximumAgeOption("maximum-age-ms", "Maximum accepted VehicleState age.", "milliseconds", "500");
  QCommandLineOption demoOption("demo", "Show a read-only development preview without a stream.");
  parser.addOption(streamOption);
  parser.addOption(maximumAgeOption);
  parser.addOption(demoOption);
  parser.addOption({"scenario", "Demo: drive, park, waiting, stale.", "name", "drive"});
  parser.addOption({"capture", "Save a rendered PNG and exit.", "path"});
  parser.addOption({"size", "Window dimensions for preview.", "WIDTHxHEIGHT", "1440x810"});
  parser.addOption({"page", "Initial preview page: drive, media, diagnostics, vehicle.", "name", "drive"});
  parser.addOption({"expect-speed", "Capture only after a live speed arrives (km/h); fail after 10 seconds.", "value"});
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
  VehicleStateBridge vehicleState(parser.value(streamOption), maximumAge);
  if (parser.isSet(demoOption)) vehicleState.showDemo(scenario);
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
