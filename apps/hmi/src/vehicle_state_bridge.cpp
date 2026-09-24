#include "vehicle_state_bridge.h"

#include <QSocketNotifier>
#include <QTimer>
#include <QDateTime>
#include <QVariantMap>

#include <cmath>
#include <cerrno>
#include <map>
#include <string>

#include <fcntl.h>
#include <unistd.h>

#include "oas/vehicle/v1/vehicle.pb.h"

namespace {
constexpr qsizetype kMaximumFrameSize = 1 << 20;
constexpr double kRadToDeg = 57.295779513082320876;

QString gearName(oas::vehicle::v1::GearPosition gear) {
  switch (gear) {
    case oas::vehicle::v1::GEAR_POSITION_PARK: return "P";
    case oas::vehicle::v1::GEAR_POSITION_REVERSE: return "R";
    case oas::vehicle::v1::GEAR_POSITION_NEUTRAL: return "N";
    case oas::vehicle::v1::GEAR_POSITION_DRIVE: return "D";
    default: return "—";
  }
}

QString doorId(oas::vehicle::v1::DoorPosition position) {
  switch (position) {
    case oas::vehicle::v1::DOOR_POSITION_FRONT_LEFT: return "frontLeft";
    case oas::vehicle::v1::DOOR_POSITION_FRONT_RIGHT: return "frontRight";
    case oas::vehicle::v1::DOOR_POSITION_REAR_LEFT: return "rearLeft";
    case oas::vehicle::v1::DOOR_POSITION_REAR_RIGHT: return "rearRight";
    default: return QString();
  }
}

QString seatId(oas::vehicle::v1::SeatPosition position) {
  switch (position) {
    case oas::vehicle::v1::SEAT_POSITION_DRIVER: return "driver";
    case oas::vehicle::v1::SEAT_POSITION_FRONT_PASSENGER: return "passenger";
    case oas::vehicle::v1::SEAT_POSITION_REAR_LEFT: return "rearLeft";
    case oas::vehicle::v1::SEAT_POSITION_REAR_RIGHT: return "rearRight";
    default: return QString();
  }
}

QString wheelId(oas::vehicle::v1::WheelPosition position) {
  switch (position) {
    case oas::vehicle::v1::WHEEL_POSITION_FRONT_LEFT: return "frontLeft";
    case oas::vehicle::v1::WHEEL_POSITION_FRONT_RIGHT: return "frontRight";
    case oas::vehicle::v1::WHEEL_POSITION_REAR_LEFT: return "rearLeft";
    case oas::vehicle::v1::WHEEL_POSITION_REAR_RIGHT: return "rearRight";
    default: return QString();
  }
}

QString cornerLabel(const QString &id) {
  if (id == "frontLeft") return QStringLiteral("운전석");
  if (id == "frontRight") return QStringLiteral("동승석");
  if (id == "rearLeft") return QStringLiteral("뒷좌석 좌");
  if (id == "rearRight") return QStringLiteral("뒷좌석 우");
  if (id == "driver") return QStringLiteral("운전석");
  if (id == "passenger") return QStringLiteral("동승석");
  return id;
}

// The four corners are always present in the model so the vehicle visual has a
// stable layout. A corner the vehicle never reported stays valid:false and is
// drawn as an outline, never as "closed" or "latched".
QVariantList corners(const QStringList &ids) {
  QVariantList list;
  for (const auto &id : ids) {
    QVariantMap entry;
    entry["id"] = id;
    entry["label"] = cornerLabel(id);
    entry["valid"] = false;
    list.append(entry);
  }
  return list;
}

const QStringList kDoorIds{"frontLeft", "frontRight", "rearLeft", "rearRight"};
const QStringList kSeatIds{"driver", "passenger", "rearLeft", "rearRight"};
}  // namespace

VehicleStateBridge::VehicleStateBridge(QString streamPath, quint64 maximumAgeMs, QObject *parent)
    : QObject(parent), stream_path_(std::move(streamPath)), maximum_age_ns_(maximumAgeMs * 1'000'000), retry_timer_(new QTimer(this)) {
  clearVehicleSignals();
  retry_timer_->setInterval(1000);
  connect(retry_timer_, &QTimer::timeout, this, &VehicleStateBridge::connectStream);
  auto *freshness_timer = new QTimer(this);
  freshness_timer->setInterval(100);
  connect(freshness_timer, &QTimer::timeout, this, [this] {
    // Nonblocking read also detects FIFO EOF on platforms without an EOF notification.
    if (!demo_ && fd_ >= 0) readFrames();
    refreshFreshness();
  });
  freshness_timer->start();
  connectStream();
}

VehicleStateBridge::~VehicleStateBridge() {
  if (notifier_) notifier_->setEnabled(false);
  if (fd_ >= 0) close(fd_);
}

bool VehicleStateBridge::available() const { return available_; }
double VehicleStateBridge::speedKph() const { return speed_kph_; }
QString VehicleStateBridge::gear() const { return gear_; }
bool VehicleStateBridge::nightMode() const { return night_mode_; }
bool VehicleStateBridge::mediaPlaybackAllowed() const { return media_playback_allowed_; }
QString VehicleStateBridge::mediaPlaybackReason() const { return media_playback_reason_; }
bool VehicleStateBridge::diagnosticsAvailable() const { return diagnostics_available_; }
QString VehicleStateBridge::diagnosticsSummary() const { return diagnostics_summary_; }
QString VehicleStateBridge::streamPath() const { return stream_path_; }

void VehicleStateBridge::clearVehicleSignals() {
  speed_kph_ = 0.0;
  speed_valid_ = false;
  acceleration_mps2_ = 0.0;
  acceleration_valid_ = false;
  gear_ = "—";
  gear_valid_ = false;
  steering_angle_deg_ = 0.0;
  steering_valid_ = false;
  brake_pressed_ = false;
  brake_valid_ = false;
  accelerator_position_ = 0.0;
  accelerator_valid_ = false;
  cruise_enabled_ = false;
  cruise_valid_ = false;
  night_mode_ = false;
  night_mode_valid_ = false;
  doors_ = corners(kDoorIds);
  doors_valid_ = false;
  any_door_open_ = false;
  seatbelts_ = corners(kSeatIds);
  seatbelts_valid_ = false;
  any_belt_unlatched_ = false;
  wheels_ = corners(kDoorIds);
  raw_signals_.clear();
}

void VehicleStateBridge::showDemo(const QString &scenario, std::optional<double> speedKph,
                                  std::optional<QString> gear) {
  disconnectStream();
  retry_timer_->stop();
  demo_ = true;
  freshness_ = scenario == "stale" ? "stale" : scenario == "waiting" ? "waiting" : "fresh";
  available_ = freshness_ == "fresh";
  clearVehicleSignals();

  speed_kph_ = speedKph.value_or(scenario == "park" ? 0.0 : 80.0);
  gear_ = gear.value_or(scenario == "park" ? "P" : "D");
  speed_valid_ = available_;
  gear_valid_ = available_;

  if (available_) {
    const bool moving = speed_kph_ > 0.1;
    acceleration_mps2_ = moving ? 0.4 : 0.0;
    acceleration_valid_ = true;
    steering_angle_deg_ = moving ? -8.5 : 0.0;
    steering_valid_ = true;
    brake_pressed_ = !moving;
    brake_valid_ = true;
    accelerator_position_ = moving ? 0.23 : 0.0;
    accelerator_valid_ = true;
    cruise_enabled_ = moving && speed_kph_ > 60.0;
    cruise_valid_ = true;
    night_mode_ = false;
    night_mode_valid_ = true;

    // Parked preview shows an open driver door so the visual's door state is
    // observable; driving preview has every door closed.
    doors_.clear();
    for (const auto &id : kDoorIds) {
      QVariantMap entry;
      entry["id"] = id;
      entry["label"] = cornerLabel(id);
      entry["valid"] = true;
      entry["open"] = !moving && id == "frontLeft";
      doors_.append(entry);
    }
    doors_valid_ = true;
    any_door_open_ = !moving;

    seatbelts_.clear();
    for (const auto &id : kSeatIds) {
      QVariantMap entry;
      entry["id"] = id;
      entry["label"] = cornerLabel(id);
      entry["valid"] = true;
      entry["latched"] = moving || id == "driver" || id == "passenger";
      seatbelts_.append(entry);
    }
    seatbelts_valid_ = true;
    any_belt_unlatched_ = !moving;

    wheels_.clear();
    for (const auto &id : kDoorIds) {
      QVariantMap entry;
      entry["id"] = id;
      entry["label"] = cornerLabel(id);
      entry["valid"] = true;
      entry["speedKph"] = speed_kph_;
      wheels_.append(entry);
    }

    const std::map<QString, double> demoRaw{
        {"CGW1.CF_Gway_DrvDrSw", !moving ? 1.0 : 0.0},
        {"CGW1.CF_Gway_DrvSeatBeltSw", 1.0},
        {"CGW1.CF_Gway_AstSeatBeltSw", 1.0},
        {"DATC12.CR_Datc_DrTempDispC", 21.5},
        {"DATC12.CR_Datc_PsTempDispC", 22.0},
        {"SAS11.SAS_Angle", steering_angle_deg_},
        {"WHL_SPD11.WHL_SpdFLVal", speed_kph_},
        {"WHL_SPD11.WHL_SpdFRVal", speed_kph_},
    };
    for (const auto &[key, value] : demoRaw) {
      QVariantMap entry;
      entry["key"] = key;
      entry["value"] = value;
      raw_signals_.append(entry);
    }
  }

  media_playback_allowed_ = available_ && speed_kph_ <= 0.1 && gear_ == "P";
  media_playback_reason_ = media_playback_allowed_ ? "allowed" : scenario == "stale" ? "stale_vehicle_state" : scenario == "waiting" ? "no_vehicle_state" : speed_kph_ > 0.1 ? "vehicle_in_motion" : "not_parked";
  diagnostics_available_ = available_;
  vehicle_controls_allowed_ = false;
  diagnostics_summary_ = "Door switch 1.0 · Belt D/P 1.0/1.0 · Temp D/P 21.5/22.0 °C";
  emit changed();
}

void VehicleStateBridge::connectStream() {
  if (demo_) return;
  if (fd_ >= 0) return;
  fd_ = open(stream_path_.toLocal8Bit().constData(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
  if (fd_ < 0) {
    retry_timer_->start();
    return;
  }
  retry_timer_->stop();
  notifier_ = new QSocketNotifier(fd_, QSocketNotifier::Read, this);
  connect(notifier_, &QSocketNotifier::activated, this, &VehicleStateBridge::readFrames);
}

void VehicleStateBridge::readFrames() {
  char chunk[4096];
  const auto bytes = read(fd_, chunk, sizeof(chunk));
  if (bytes < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) return;
  if (bytes <= 0) {
    disconnectStream();
    return;
  }
  buffer_.append(chunk, bytes);
  while (buffer_.size() >= 4) {
    const quint32 size = (static_cast<quint32>(static_cast<unsigned char>(buffer_[0])) << 24) |
                      (static_cast<unsigned char>(buffer_[1]) << 16) |
                      (static_cast<unsigned char>(buffer_[2]) << 8) |
                      static_cast<unsigned char>(buffer_[3]);
    if (size > kMaximumFrameSize) {
      disconnectStream();
      return;
    }
    if (buffer_.size() < 4 + size) return;
    if (!applyFrame(QByteArrayView(buffer_).sliced(4, size))) {
      disconnectStream();
      return;
    }
    buffer_.remove(0, 4 + size);
  }
}

bool VehicleStateBridge::applyFrame(QByteArrayView frame) {
  oas::vehicle::v1::HmiState hmi;
  if (!hmi.ParseFromArray(frame.data(), frame.size())) return false;
  const auto fresh = hmi.freshness() == oas::vehicle::v1::HMI_FRESHNESS_FRESH;
  const auto *state = hmi.has_vehicle_state() ? &hmi.vehicle_state() : nullptr;
  freshness_ = fresh ? "fresh" : hmi.freshness() == oas::vehicle::v1::HMI_FRESHNESS_STALE ? "stale" : "waiting";
  timestamp_ns_ = state && state->has_timestamp_ns() ? state->timestamp_ns() : 0;
  clearVehicleSignals();

  available_ = fresh && state && state->has_vehicle_speed_mps() && std::isfinite(state->vehicle_speed_mps());
  speed_valid_ = available_;
  speed_kph_ = available_ ? state->vehicle_speed_mps() * 3.6 : 0.0;

  if (fresh && state) {
    if (state->has_acceleration_mps2() && std::isfinite(state->acceleration_mps2())) {
      acceleration_mps2_ = state->acceleration_mps2();
      acceleration_valid_ = true;
    }
    if (state->has_gear() && state->gear().position() != oas::vehicle::v1::GEAR_POSITION_UNSPECIFIED) {
      gear_ = gearName(state->gear().position());
      gear_valid_ = true;
    }
    if (state->has_steering() && state->steering().has_angle_rad() && std::isfinite(state->steering().angle_rad())) {
      steering_angle_deg_ = state->steering().angle_rad() * kRadToDeg;
      steering_valid_ = true;
    }
    if (state->has_brake() && state->brake().has_pressed()) {
      brake_pressed_ = state->brake().pressed();
      brake_valid_ = true;
    }
    if (state->has_accelerator() && state->accelerator().has_position() && std::isfinite(state->accelerator().position())) {
      accelerator_position_ = state->accelerator().position();
      accelerator_valid_ = true;
    }
    if (state->has_cruise() && state->cruise().has_enabled()) {
      cruise_enabled_ = state->cruise().enabled();
      cruise_valid_ = true;
    }
    if (state->has_night_mode()) {
      night_mode_ = state->night_mode();
      night_mode_valid_ = true;
    }

    for (const auto &door : state->doors()) {
      const auto id = doorId(door.position());
      if (id.isEmpty() || !door.has_open()) continue;
      for (auto &value : doors_) {
        auto entry = value.toMap();
        if (entry["id"].toString() != id) continue;
        entry["valid"] = true;
        entry["open"] = door.open();
        value = entry;
        doors_valid_ = true;
        if (door.open()) any_door_open_ = true;
      }
    }
    for (const auto &belt : state->seatbelts()) {
      const auto id = seatId(belt.position());
      if (id.isEmpty() || !belt.has_latched()) continue;
      for (auto &value : seatbelts_) {
        auto entry = value.toMap();
        if (entry["id"].toString() != id) continue;
        entry["valid"] = true;
        entry["latched"] = belt.latched();
        value = entry;
        seatbelts_valid_ = true;
        if (!belt.latched()) any_belt_unlatched_ = true;
      }
    }
    for (const auto &wheel : state->wheels()) {
      const auto id = wheelId(wheel.position());
      if (id.isEmpty() || !wheel.has_speed_mps() || !std::isfinite(wheel.speed_mps())) continue;
      for (auto &value : wheels_) {
        auto entry = value.toMap();
        if (entry["id"].toString() != id) continue;
        entry["valid"] = true;
        entry["speedKph"] = wheel.speed_mps() * 3.6;
        value = entry;
      }
    }

    // std::map keeps the diagnostics list in a stable, sorted order across frames.
    std::map<std::string, double> sorted;
    for (const auto &[key, value] : state->raw_signals()) sorted.emplace(key, value);
    for (const auto &[key, value] : sorted) {
      QVariantMap entry;
      entry["key"] = QString::fromStdString(key);
      entry["value"] = value;
      raw_signals_.append(entry);
    }
  }

  media_playback_allowed_ = fresh && hmi.media_playback() == oas::vehicle::v1::HMI_CAPABILITY_ALLOWED;
  media_playback_reason_ = QString::fromStdString(hmi.media_playback_reason());
  diagnostics_available_ = fresh && hmi.diagnostics() == oas::vehicle::v1::HMI_CAPABILITY_ALLOWED;
  vehicle_controls_allowed_ = fresh && hmi.vehicle_controls() == oas::vehicle::v1::HMI_CAPABILITY_ALLOWED;
  const auto raw = [state](const char *key) {
    if (!state) return QString("—");
    const auto value = state->raw_signals().find(key);
    return value == state->raw_signals().end() ? QString("—") : QString::number(value->second, 'f', 1);
  };
  diagnostics_summary_ = QString("Door switch %1 · Belt D/P %2/%3 · Temp D/P %4/%5 °C")
      .arg(raw("CGW1.CF_Gway_DrvDrSw"), raw("CGW1.CF_Gway_DrvSeatBeltSw"), raw("CGW1.CF_Gway_AstSeatBeltSw"), raw("DATC12.CR_Datc_DrTempDispC"), raw("DATC12.CR_Datc_PsTempDispC"));
  refreshFreshness();
  emit changed();
  return true;
}

void VehicleStateBridge::disconnectStream() {
  if (notifier_) notifier_->deleteLater();
  notifier_ = nullptr;
  if (fd_ >= 0) close(fd_);
  fd_ = -1;
  buffer_.clear();
  available_ = false;
  freshness_ = "waiting";
  clearVehicleSignals();
  media_playback_allowed_ = false;
  media_playback_reason_.clear();
  diagnostics_available_ = false;
  diagnostics_summary_.clear();
  vehicle_controls_allowed_ = false;
  timestamp_ns_ = 0;
  emit changed();
  retry_timer_->start();
}

void VehicleStateBridge::refreshFreshness() {
  if (demo_) return;
  const auto now_ns = static_cast<quint64>(QDateTime::currentMSecsSinceEpoch()) * 1'000'000;
  const bool fresh = timestamp_ns_ > 0 && timestamp_ns_ <= now_ns && now_ns - timestamp_ns_ <= maximum_age_ns_;
  if ((freshness_ == "fresh" || media_playback_allowed_ || diagnostics_available_) && !fresh) {
    freshness_ = "stale";
    available_ = false;
    // A stale snapshot must not leave any driving value on screen.
    clearVehicleSignals();
    media_playback_allowed_ = false;
    media_playback_reason_ = "stale_vehicle_state";
    diagnostics_available_ = false;
    vehicle_controls_allowed_ = false;
    emit changed();
  }
}
