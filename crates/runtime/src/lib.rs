//! Gateway의 length-prefixed VehicleState stream을 소비한다.

#![forbid(unsafe_code)]

use std::fmt;
use std::io::{self, Read};

pub use oas_sdk::vehicle::v1::{GearPosition, VehicleState};
use prost::Message;

pub const MAX_SNAPSHOT_BYTES: u32 = 1024 * 1024;
pub const STOPPED_SPEED_MPS: f32 = 0.1;

/// 운전자 화면에서 영상을 재생할 수 있는지 나타낸다.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum VideoPlayback {
    Allowed,
    NoVehicleState,
    StaleVehicleState,
    VehicleInMotion,
    NotParked,
}

/// Gateway stream에서 최신 차량 상태를 유지하는 runtime이다.
#[derive(Debug)]
pub struct Runtime<R> {
    input: R,
    latest: Option<VehicleState>,
}

impl<R: Read> Runtime<R> {
    pub fn new(input: R) -> Self {
        Self {
            input,
            latest: None,
        }
    }

    /// 다음 snapshot을 읽는다. 길이 prefix를 읽기 전 EOF는 정상 종료다.
    pub fn read_next(&mut self) -> Result<Option<&VehicleState>, RuntimeError> {
        let mut length = [0; 4];
        if self.input.read(&mut length[..1])? == 0 {
            return Ok(None);
        }
        self.input.read_exact(&mut length[1..])?;
        let length = u32::from_be_bytes(length);
        if length > MAX_SNAPSHOT_BYTES {
            return Err(RuntimeError::SnapshotTooLarge(length));
        }

        let mut payload = vec![0; length as usize];
        self.input.read_exact(&mut payload)?;
        self.latest = Some(VehicleState::decode(payload.as_slice())?);
        Ok(self.latest.as_ref())
    }

    pub fn latest(&self) -> Option<&VehicleState> {
        self.latest.as_ref()
    }

    /// 정상 EOF까지 snapshot을 순서대로 전달한다.
    pub fn subscribe(
        &mut self,
        mut subscriber: impl FnMut(&VehicleState),
    ) -> Result<(), RuntimeError> {
        while let Some(state) = self.read_next()? {
            subscriber(state);
        }
        Ok(())
    }

    pub fn latest_is_fresh(&self, now_ns: u64, maximum_age_ns: u64) -> bool {
        self.latest
            .as_ref()
            .and_then(|state| state.timestamp_ns)
            .and_then(|timestamp_ns| now_ns.checked_sub(timestamp_ns))
            .is_some_and(|age_ns| age_ns <= maximum_age_ns)
    }

    /// 최신 상태가 정차·P 기어임을 명시할 때만 운전자 영상 재생을 허용한다.
    pub fn video_playback(&self, now_ns: u64, maximum_age_ns: u64) -> VideoPlayback {
        let Some(state) = self.latest() else {
            return VideoPlayback::NoVehicleState;
        };
        if !self.latest_is_fresh(now_ns, maximum_age_ns) {
            return VideoPlayback::StaleVehicleState;
        }
        if !state
            .vehicle_speed_mps
            .is_some_and(|speed| speed.is_finite() && speed.abs() <= STOPPED_SPEED_MPS)
        {
            return VideoPlayback::VehicleInMotion;
        }
        if state
            .gear
            .as_ref()
            .and_then(|gear| GearPosition::try_from(gear.position).ok())
            != Some(GearPosition::Park)
        {
            return VideoPlayback::NotParked;
        }
        VideoPlayback::Allowed
    }
}

#[derive(Debug)]
pub enum RuntimeError {
    Io(io::Error),
    Decode(prost::DecodeError),
    SnapshotTooLarge(u32),
}

impl fmt::Display for RuntimeError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Io(error) => write!(formatter, "stream I/O: {error}"),
            Self::Decode(error) => write!(formatter, "protobuf decode: {error}"),
            Self::SnapshotTooLarge(length) => write!(formatter, "snapshot too large: {length}"),
        }
    }
}

impl std::error::Error for RuntimeError {}

impl From<io::Error> for RuntimeError {
    fn from(error: io::Error) -> Self {
        Self::Io(error)
    }
}

impl From<prost::DecodeError> for RuntimeError {
    fn from(error: prost::DecodeError) -> Self {
        Self::Decode(error)
    }
}

#[cfg(test)]
mod tests {
    use std::io::Cursor;

    use oas_sdk::vehicle::v1::{GearPosition, GearState, VehicleState};
    use prost::Message;

    use super::{MAX_SNAPSHOT_BYTES, Runtime, RuntimeError, VideoPlayback};

    #[test]
    fn reads_a_length_prefixed_snapshot_and_checks_freshness() {
        let state = VehicleState {
            timestamp_ns: Some(1_000),
            vehicle_speed_mps: Some(12.5),
            ..VehicleState::default()
        };
        let payload = state.encode_to_vec();
        let mut stream = (payload.len() as u32).to_be_bytes().to_vec();
        stream.extend_from_slice(&payload);
        let mut runtime = Runtime::new(Cursor::new(stream));

        assert_eq!(runtime.read_next().unwrap(), Some(&state));
        assert!(runtime.latest_is_fresh(1_050, 50));
        assert!(!runtime.latest_is_fresh(999, 50));
        assert_eq!(runtime.read_next().unwrap(), None);
        assert_eq!(runtime.latest(), Some(&state));
    }

    #[test]
    fn rejects_an_oversized_snapshot_before_allocating_it() {
        let stream = (MAX_SNAPSHOT_BYTES + 1).to_be_bytes();
        let error = Runtime::new(Cursor::new(stream)).read_next().unwrap_err();

        assert!(matches!(error, RuntimeError::SnapshotTooLarge(_)));
    }

    #[test]
    fn preserves_the_last_valid_snapshot_after_a_decode_error() {
        let state = VehicleState {
            timestamp_ns: Some(1_000),
            vehicle_speed_mps: Some(12.5),
            ..VehicleState::default()
        };
        let payload = state.encode_to_vec();
        let mut stream = (payload.len() as u32).to_be_bytes().to_vec();
        stream.extend_from_slice(&payload);
        stream.extend_from_slice(&[0, 0, 0, 1, 0x80]);
        let mut runtime = Runtime::new(Cursor::new(stream));

        assert_eq!(runtime.read_next().unwrap(), Some(&state));
        assert!(matches!(runtime.read_next(), Err(RuntimeError::Decode(_))));
        assert_eq!(runtime.latest(), Some(&state));
    }

    #[test]
    fn subscription_receives_snapshots_in_order_until_disconnect() {
        let states = [
            VehicleState {
                vehicle_speed_mps: Some(10.0),
                ..VehicleState::default()
            },
            VehicleState {
                vehicle_speed_mps: Some(20.0),
                ..VehicleState::default()
            },
        ];
        let mut stream = Vec::new();
        for state in &states {
            let payload = state.encode_to_vec();
            stream.extend_from_slice(&(payload.len() as u32).to_be_bytes());
            stream.extend_from_slice(&payload);
        }
        let mut runtime = Runtime::new(Cursor::new(stream));
        let mut speeds = Vec::new();

        runtime
            .subscribe(|state| speeds.push(state.vehicle_speed_mps.unwrap()))
            .unwrap();

        assert_eq!(speeds, [10.0, 20.0]);
        assert_eq!(runtime.latest(), Some(&states[1]));
    }

    #[test]
    fn video_playback_fails_closed_unless_fresh_stationary_and_parked() {
        let state = VehicleState {
            timestamp_ns: Some(1_000),
            vehicle_speed_mps: Some(0.0),
            gear: Some(GearState {
                position: GearPosition::Park as i32,
            }),
            ..VehicleState::default()
        };
        let payload = state.encode_to_vec();
        let mut stream = (payload.len() as u32).to_be_bytes().to_vec();
        stream.extend_from_slice(&payload);
        let mut runtime = Runtime::new(Cursor::new(stream));

        assert_eq!(
            runtime.video_playback(1_000, 500),
            VideoPlayback::NoVehicleState
        );
        runtime.read_next().unwrap();
        assert_eq!(runtime.video_playback(1_500, 500), VideoPlayback::Allowed);
        assert_eq!(
            runtime.video_playback(1_501, 500),
            VideoPlayback::StaleVehicleState
        );

        runtime.latest.as_mut().unwrap().gear = Some(GearState {
            position: GearPosition::Drive as i32,
        });
        assert_eq!(runtime.video_playback(1_000, 500), VideoPlayback::NotParked);
        runtime.latest.as_mut().unwrap().vehicle_speed_mps = Some(0.2);
        assert_eq!(
            runtime.video_playback(1_000, 500),
            VideoPlayback::VehicleInMotion
        );
    }
}
