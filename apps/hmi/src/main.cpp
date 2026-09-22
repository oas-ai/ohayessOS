#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#include "vehicle_state_bridge.h"

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  QCommandLineParser parser;
  QCommandLineOption streamOption("stream", "VehicleState FIFO path.", "path", "/run/ohayess/vehicle-state");
  QCommandLineOption maximumAgeOption("maximum-age-ms", "Maximum accepted VehicleState age.", "milliseconds", "500");
  parser.addOption(streamOption);
  parser.addOption(maximumAgeOption);
  parser.process(app);
  VehicleStateBridge vehicleState(parser.value(streamOption), parser.value(maximumAgeOption).toULongLong());
  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("vehicleState", &vehicleState);
  engine.load(QUrl("qrc:/qt/qml/OAS/HMI/Main.qml"));
  return engine.rootObjects().isEmpty() ? 1 : app.exec();
}
