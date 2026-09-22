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
  oas::vehicle::v1::VehicleState state;
  if (!state.ParseFromArray(frame.data(), frame.size())) return false;
  timestamp_ns_ = state.has_timestamp_ns() ? state.timestamp_ns() : 0;
  available_ = state.has_vehicle_speed_mps() && std::isfinite(state.vehicle_speed_mps());
  speed_kph_ = available_ ? state.vehicle_speed_mps() * 3.6 : 0.0;
  gear_ = state.has_gear() ? gearName(state.gear().position()) : "—";
  night_mode_ = state.has_night_mode() && state.night_mode();
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
  speed_kph_ = 0.0;
  gear_ = "—";
  night_mode_ = false;
  timestamp_ns_ = 0;
  emit changed();
  retry_timer_->start();
}

void VehicleStateBridge::refreshFreshness() {
  const auto now_ns = static_cast<quint64>(QDateTime::currentMSecsSinceEpoch()) * 1'000'000;
  const bool fresh = timestamp_ns_ > 0 && timestamp_ns_ <= now_ns && now_ns - timestamp_ns_ <= maximum_age_ns_;
  if (available_ && !fresh) {
    available_ = false;
    emit changed();
  }
}
