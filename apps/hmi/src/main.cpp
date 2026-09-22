#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "vehicle_state_bridge.h"

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  QCommandLineParser parser;
  QCommandLineOption streamOption("stream", "HmiState FIFO path.", "path", "/run/ohayess/vehicle-state");
  QCommandLineOption maximumAgeOption("maximum-age-ms", "Maximum accepted VehicleState age.", "milliseconds", "500");
  QCommandLineOption demoOption("demo", "Show a read-only development preview without a stream.");
  parser.addOption(streamOption);
  parser.addOption(maximumAgeOption);
  parser.addOption(demoOption);
  parser.process(app);
  VehicleStateBridge vehicleState(parser.value(streamOption), parser.value(maximumAgeOption).toULongLong());
  if (parser.isSet(demoOption)) vehicleState.showDemo();
  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("vehicleState", &vehicleState);
  engine.loadFromModule("OAS.HMI", "Main");
  return engine.rootObjects().isEmpty() ? 1 : app.exec();
}
