#pragma once

#include <QObject>
#include <QByteArray>
#include <QByteArrayView>
#include <QString>
#include <QVariantList>

#include <optional>

class QSocketNotifier;
class QTimer;

// Read-only presentation view of the canonical HmiState stream.
//
// Every signal carries its own validity flag: a value is only meaningful when
// its *Valid companion is true. QML renders an em dash for invalid signals
// rather than substituting zero or the last known value.
class VehicleStateBridge final : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool available READ available NOTIFY changed)
  Q_PROPERTY(QString freshness READ freshness NOTIFY changed)
  Q_PROPERTY(bool demo READ isDemo NOTIFY changed)

  Q_PROPERTY(double speedKph READ speedKph NOTIFY changed)
  Q_PROPERTY(bool speedValid READ speedValid NOTIFY changed)
  Q_PROPERTY(double accelerationMps2 READ accelerationMps2 NOTIFY changed)
  Q_PROPERTY(bool accelerationValid READ accelerationValid NOTIFY changed)
  Q_PROPERTY(QString gear READ gear NOTIFY changed)
  Q_PROPERTY(bool gearValid READ gearValid NOTIFY changed)
  Q_PROPERTY(double steeringAngleDeg READ steeringAngleDeg NOTIFY changed)
  Q_PROPERTY(bool steeringValid READ steeringValid NOTIFY changed)
  Q_PROPERTY(bool brakePressed READ brakePressed NOTIFY changed)
  Q_PROPERTY(bool brakeValid READ brakeValid NOTIFY changed)
  Q_PROPERTY(double acceleratorPosition READ acceleratorPosition NOTIFY changed)
  Q_PROPERTY(bool acceleratorValid READ acceleratorValid NOTIFY changed)
  Q_PROPERTY(bool cruiseEnabled READ cruiseEnabled NOTIFY changed)
  Q_PROPERTY(bool cruiseValid READ cruiseValid NOTIFY changed)
  Q_PROPERTY(bool nightMode READ nightMode NOTIFY changed)
  Q_PROPERTY(bool nightModeValid READ nightModeValid NOTIFY changed)

  // Each entry: { id, label, open|latched|speedKph, valid }
  Q_PROPERTY(QVariantList doors READ doors NOTIFY changed)
  Q_PROPERTY(bool doorsValid READ doorsValid NOTIFY changed)
  Q_PROPERTY(bool anyDoorOpen READ anyDoorOpen NOTIFY changed)
  Q_PROPERTY(QVariantList seatbelts READ seatbelts NOTIFY changed)
  Q_PROPERTY(bool seatbeltsValid READ seatbeltsValid NOTIFY changed)
  Q_PROPERTY(bool anyBeltUnlatched READ anyBeltUnlatched NOTIFY changed)
  Q_PROPERTY(QVariantList wheels READ wheels NOTIFY changed)
  Q_PROPERTY(QVariantList rawSignals READ rawSignals NOTIFY changed)

  Q_PROPERTY(bool mediaPlaybackAllowed READ mediaPlaybackAllowed NOTIFY changed)
  Q_PROPERTY(QString mediaPlaybackReason READ mediaPlaybackReason NOTIFY changed)
  Q_PROPERTY(bool diagnosticsAvailable READ diagnosticsAvailable NOTIFY changed)
  Q_PROPERTY(QString diagnosticsSummary READ diagnosticsSummary NOTIFY changed)
  Q_PROPERTY(bool vehicleControlsAllowed READ vehicleControlsAllowed NOTIFY changed)
  Q_PROPERTY(QString streamPath READ streamPath CONSTANT)

 public:
  explicit VehicleStateBridge(QString streamPath, quint64 maximumAgeMs, QObject *parent = nullptr);
  ~VehicleStateBridge() override;

  bool available() const;
  double speedKph() const;
  bool speedValid() const { return speed_valid_; }
  double accelerationMps2() const { return acceleration_mps2_; }
  bool accelerationValid() const { return acceleration_valid_; }
  QString gear() const;
  bool gearValid() const { return gear_valid_; }
  double steeringAngleDeg() const { return steering_angle_deg_; }
  bool steeringValid() const { return steering_valid_; }
  bool brakePressed() const { return brake_pressed_; }
  bool brakeValid() const { return brake_valid_; }
  double acceleratorPosition() const { return accelerator_position_; }
  bool acceleratorValid() const { return accelerator_valid_; }
  bool cruiseEnabled() const { return cruise_enabled_; }
  bool cruiseValid() const { return cruise_valid_; }
  bool nightMode() const;
  bool nightModeValid() const { return night_mode_valid_; }

  QVariantList doors() const { return doors_; }
  bool doorsValid() const { return doors_valid_; }
  bool anyDoorOpen() const { return any_door_open_; }
  QVariantList seatbelts() const { return seatbelts_; }
  bool seatbeltsValid() const { return seatbelts_valid_; }
  bool anyBeltUnlatched() const { return any_belt_unlatched_; }
  QVariantList wheels() const { return wheels_; }
  QVariantList rawSignals() const { return raw_signals_; }

  bool mediaPlaybackAllowed() const;
  QString mediaPlaybackReason() const;
  bool diagnosticsAvailable() const;
  QString diagnosticsSummary() const;
  bool vehicleControlsAllowed() const { return vehicle_controls_allowed_; }
  QString streamPath() const;
  QString freshness() const { return freshness_; }
  bool isDemo() const { return demo_; }

  void showDemo(const QString &scenario = "drive", std::optional<double> speedKph = std::nullopt,
                std::optional<QString> gear = std::nullopt);

 signals:
  void changed();

 private:
  void connectStream();
  void readFrames();
  void disconnectStream();
  void refreshFreshness();
  bool applyFrame(QByteArrayView frame);
  void clearVehicleSignals();

  QString stream_path_;
  QByteArray buffer_;
  QSocketNotifier *notifier_ = nullptr;
  QTimer *retry_timer_ = nullptr;
  int fd_ = -1;
  quint64 maximum_age_ns_ = 0;
  quint64 timestamp_ns_ = 0;
  bool available_ = false;

  double speed_kph_ = 0.0;
  bool speed_valid_ = false;
  double acceleration_mps2_ = 0.0;
  bool acceleration_valid_ = false;
  QString gear_;
  bool gear_valid_ = false;
  double steering_angle_deg_ = 0.0;
  bool steering_valid_ = false;
  bool brake_pressed_ = false;
  bool brake_valid_ = false;
  double accelerator_position_ = 0.0;
  bool accelerator_valid_ = false;
  bool cruise_enabled_ = false;
  bool cruise_valid_ = false;
  bool night_mode_ = false;
  bool night_mode_valid_ = false;

  QVariantList doors_;
  bool doors_valid_ = false;
  bool any_door_open_ = false;
  QVariantList seatbelts_;
  bool seatbelts_valid_ = false;
  bool any_belt_unlatched_ = false;
  QVariantList wheels_;
  QVariantList raw_signals_;

  bool media_playback_allowed_ = false;
  QString media_playback_reason_;
  bool diagnostics_available_ = false;
  QString diagnostics_summary_;
  bool vehicle_controls_allowed_ = false;
  bool demo_ = false;
  QString freshness_ = "waiting";
};
