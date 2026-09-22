#pragma once

#include <QObject>
#include <QByteArray>
#include <QByteArrayView>
#include <QString>

class QSocketNotifier;
class QTimer;

class VehicleStateBridge final : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool available READ available NOTIFY changed)
  Q_PROPERTY(double speedKph READ speedKph NOTIFY changed)
  Q_PROPERTY(QString gear READ gear NOTIFY changed)
  Q_PROPERTY(bool nightMode READ nightMode NOTIFY changed)
  Q_PROPERTY(bool mediaPlaybackAllowed READ mediaPlaybackAllowed NOTIFY changed)
  Q_PROPERTY(QString mediaPlaybackReason READ mediaPlaybackReason NOTIFY changed)
  Q_PROPERTY(bool diagnosticsAvailable READ diagnosticsAvailable NOTIFY changed)
  Q_PROPERTY(QString streamPath READ streamPath CONSTANT)

 public:
  explicit VehicleStateBridge(QString streamPath, quint64 maximumAgeMs, QObject *parent = nullptr);
  bool available() const;
  double speedKph() const;
  QString gear() const;
  bool nightMode() const;
  bool mediaPlaybackAllowed() const;
  QString mediaPlaybackReason() const;
  bool diagnosticsAvailable() const;
  QString streamPath() const;

 signals:
  void changed();

 private:
  void connectStream();
  void readFrames();
  void disconnectStream();
  void refreshFreshness();
  bool applyFrame(QByteArrayView frame);

  QString stream_path_;
  QByteArray buffer_;
  QSocketNotifier *notifier_ = nullptr;
  QTimer *retry_timer_ = nullptr;
  int fd_ = -1;
  quint64 maximum_age_ns_ = 0;
  quint64 timestamp_ns_ = 0;
  bool available_ = false;
  double speed_kph_ = 0.0;
  QString gear_;
  bool night_mode_ = false;
  bool media_playback_allowed_ = false;
  QString media_playback_reason_;
  bool diagnostics_available_ = false;
};
