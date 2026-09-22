#include "vehicle_state_bridge.h"

#include <QSocketNotifier>
#include <QTimer>
#include <QDateTime>

#include <cmath>
#include <cerrno>

#include <fcntl.h>
#include <unistd.h>

#include "oas/vehicle/v1/vehicle.pb.h"

namespace {
constexpr qsizetype kMaximumFrameSize = 1 << 20;

QString gearName(oas::vehicle::v1::GearPosition gear) {
  switch (gear) {
    case oas::vehicle::v1::GEAR_POSITION_PARK: return "P";
    case oas::vehicle::v1::GEAR_POSITION_REVERSE: return "R";
    case oas::vehicle::v1::GEAR_POSITION_NEUTRAL: return "N";
    case oas::vehicle::v1::GEAR_POSITION_DRIVE: return "D";
    default: return "—";
  }
}
}  // namespace

VehicleStateBridge::VehicleStateBridge(QString streamPath, quint64 maximumAgeMs, QObject *parent)
    : QObject(parent), stream_path_(std::move(streamPath)), maximum_age_ns_(maximumAgeMs * 1'000'000), retry_timer_(new QTimer(this)) {
  retry_timer_->setInterval(1000);
  connect(retry_timer_, &QTimer::timeout, this, &VehicleStateBridge::connectStream);
  auto *freshness_timer = new QTimer(this);
  freshness_timer->setInterval(100);
  connect(freshness_timer, &QTimer::timeout, this, &VehicleStateBridge::refreshFreshness);
  freshness_timer->start();
  connectStream();
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

void VehicleStateBridge::connectStream() {
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
    const auto size = (static_cast<unsigned char>(buffer_[0]) << 24) |
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
  timestamp_ns_ = state && state->has_timestamp_ns() ? state->timestamp_ns() : 0;
  available_ = fresh && state && state->has_vehicle_speed_mps() && std::isfinite(state->vehicle_speed_mps());
  speed_kph_ = available_ ? state->vehicle_speed_mps() * 3.6 : 0.0;
  gear_ = state && state->has_gear() ? gearName(state->gear().position()) : "—";
  night_mode_ = state && state->has_night_mode() && state->night_mode();
  media_playback_allowed_ = hmi.media_playback() == oas::vehicle::v1::HMI_CAPABILITY_ALLOWED;
  media_playback_reason_ = QString::fromStdString(hmi.media_playback_reason());
  diagnostics_available_ = hmi.diagnostics() == oas::vehicle::v1::HMI_CAPABILITY_ALLOWED;
  const auto raw = [state](const char *key) {
    if (!state) return QString("—");
    const auto value = state->raw_signals().find(key);
    return value == state->raw_signals().end() ? QString("—") : QString::number(value->second, 'f', 1);
  };
  diagnostics_summary_ = QString("Door switch %1 · Belt D/P %2/%3 · Temp D/P %4/%5 °C")
      .arg(raw("CGW1.CF_Gway_DrvDrSw"), raw("CGW1.CF_Gway_DrvSeatBeltSw"), raw("CGW1.CF_Gway_AstSeatBeltSw"), raw("DATC12.CR_Datc_DrTempDispC"), raw("DATC12.CR_Datc_PsTempDispC"));
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
  speed_kph_ = 0.0;
  gear_ = "—";
  night_mode_ = false;
  media_playback_allowed_ = false;
  media_playback_reason_.clear();
  diagnostics_available_ = false;
  diagnostics_summary_.clear();
  timestamp_ns_ = 0;
  emit changed();
  retry_timer_->start();
}

void VehicleStateBridge::refreshFreshness() {
  const auto now_ns = static_cast<quint64>(QDateTime::currentMSecsSinceEpoch()) * 1'000'000;
  const bool fresh = timestamp_ns_ > 0 && timestamp_ns_ <= now_ns && now_ns - timestamp_ns_ <= maximum_age_ns_;
  if (available_ && !fresh) {
    available_ = false;
    media_playback_allowed_ = false;
    diagnostics_available_ = false;
    emit changed();
  }
}
