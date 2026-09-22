#include <QCoreApplication>
#include <QDateTime>
#include <QElapsedTimer>
#include <QTemporaryDir>
#include <QThread>

#include <cerrno>
#include <cmath>
#include <cstdlib>
#include <functional>

#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

#include "oas/vehicle/v1/vehicle.pb.h"
#include "vehicle_state_bridge.h"

namespace {
void fail(const char *message) {
  qCritical("%s", message);
  std::exit(1);
}

bool waitFor(const std::function<bool()> &condition, int timeoutMs = 500) {
  QElapsedTimer timer;
  timer.start();
  while (timer.elapsed() < timeoutMs) {
    QCoreApplication::processEvents();
    if (condition()) return true;
    QThread::msleep(5);
  }
  return condition();
}

int writerFor(const QString &path) {
  int fd = -1;
  if (!waitFor([&] {
        fd = open(path.toLocal8Bit().constData(), O_WRONLY | O_NONBLOCK | O_CLOEXEC);
        return fd >= 0;
      })) fail("FIFO writer did not connect");
  return fd;
}

void writeState(int fd, float speedMps, bool includeSpeed = true, bool stale = false) {
  oas::vehicle::v1::VehicleState state;
  state.set_timestamp_ns(static_cast<quint64>(QDateTime::currentMSecsSinceEpoch()) * 1'000'000);
  if (includeSpeed) state.set_vehicle_speed_mps(speedMps);
  state.mutable_gear()->set_position(oas::vehicle::v1::GEAR_POSITION_DRIVE);
  (*state.mutable_raw_signals())["CGW1.CF_Gway_DrvDrSw"] = 1.0;
  oas::vehicle::v1::HmiState hmi;
  *hmi.mutable_vehicle_state() = state;
  hmi.set_freshness(stale ? oas::vehicle::v1::HMI_FRESHNESS_STALE : oas::vehicle::v1::HMI_FRESHNESS_FRESH);
  hmi.set_media_playback(oas::vehicle::v1::HMI_CAPABILITY_ALLOWED);
  hmi.set_media_playback_reason("allowed");
  hmi.set_diagnostics(oas::vehicle::v1::HMI_CAPABILITY_ALLOWED);
  std::string payload;
  if (!hmi.SerializeToString(&payload)) fail("protobuf serialization failed");
  const auto size = static_cast<quint32>(payload.size());
  const char header[] = {static_cast<char>(size >> 24), static_cast<char>(size >> 16), static_cast<char>(size >> 8), static_cast<char>(size)};
  if (write(fd, header, sizeof(header)) != sizeof(header) || write(fd, payload.data(), payload.size()) != static_cast<ssize_t>(payload.size())) fail("FIFO write failed");
}
}  // namespace

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  VehicleStateBridge demo("/missing", 1);
  demo.showDemo();
  QThread::msleep(20);
  QCoreApplication::processEvents();
  if (!demo.available() || !demo.diagnosticsAvailable()) fail("demo preview is not read-only available");

  QTemporaryDir directory;
  const auto path = directory.path() + "/vehicle-state";
  if (::mkfifo(path.toLocal8Bit().constData(), 0600) != 0) fail("mkfifo failed");

  VehicleStateBridge bridge(path, 250);
  const int writer = writerFor(path);
  writeState(writer, 22.222F);
  if (!waitFor([&] { return bridge.available(); })) fail("fresh VehicleState was not published");
  if (std::abs(bridge.speedKph() - 80.0) > 0.1 || bridge.gear() != "D") fail("published VehicleState values are incorrect");
  if (!bridge.mediaPlaybackAllowed() || !bridge.diagnosticsAvailable()) fail("runtime capabilities were not published");
  if (!bridge.diagnosticsSummary().contains("Door switch 1.0")) fail("raw diagnostics were not published");

  if (!waitFor([&] { return !bridge.available(); }, 750)) fail("stale VehicleState stayed available");
  if (bridge.mediaPlaybackAllowed() || bridge.diagnosticsAvailable()) fail("stale state left capabilities enabled");
  if (bridge.freshness() != "stale") fail("expired stream was not distinguished from waiting");
  writeState(writer, 0.0F);
  if (!waitFor([&] { return bridge.available(); })) fail("fresh VehicleState did not recover");

  writeState(writer, 0, false);
  if (!waitFor([&] { return !bridge.available() && bridge.diagnosticsAvailable(); })) fail("missing speed prevented diagnostics");
  if (!waitFor([&] { return !bridge.diagnosticsAvailable(); }, 750)) fail("missing speed bypassed expiry guard");
  writeState(writer, 0, true, true);
  QThread::msleep(10);
  QCoreApplication::processEvents();
  if (bridge.available() || bridge.mediaPlaybackAllowed() || bridge.diagnosticsAvailable()) fail("stale envelope enabled capabilities");

  close(writer);
  if (!waitFor([&] { return !bridge.available(); })) fail("stream disconnect stayed available");
  if (!waitFor([&] { return bridge.freshness() == "waiting"; })) fail("disconnect did not reset freshness");
  demo.showDemo("park");
  if (!demo.isDemo() || !demo.mediaPlaybackAllowed() || demo.gear() != "P") fail("park preview is invalid");
  demo.showDemo("stale");
  if (demo.available() || demo.freshness() != "stale") fail("stale preview is invalid");
}
