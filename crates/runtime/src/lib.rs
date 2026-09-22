//! Gateway의 length-prefixed VehicleState stream을 소비한다.

#![forbid(unsafe_code)]

use std::fmt;
use std::io::{self, Read};

pub use oas_sdk::vehicle::v1::VehicleState;
use prost::Message;

pub const MAX_SNAPSHOT_BYTES: u32 = 1024 * 1024;

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

    use oas_sdk::vehicle::v1::VehicleState;
    use prost::Message;

    use super::{MAX_SNAPSHOT_BYTES, Runtime, RuntimeError};

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
}
