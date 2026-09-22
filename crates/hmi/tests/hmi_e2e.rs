use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::process::{Command, Stdio};
use std::thread;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use ohayess_runtime::{GearPosition, GearState, VehicleState};
use prost::Message;

fn frame(state: &VehicleState) -> Vec<u8> {
    let payload = state.encode_to_vec();
    let mut frame = (payload.len() as u32).to_be_bytes().to_vec();
    frame.extend_from_slice(&payload);
    frame
}

fn now_ns() -> u64 {
    u64::try_from(
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos(),
    )
    .unwrap()
}

fn state_is(address: &str, expected: &str) -> bool {
    for _ in 0..50 {
        if let Ok(mut stream) = TcpStream::connect(address) {
            stream
                .write_all(b"GET /state HTTP/1.1\r\nHost: localhost\r\n\r\n")
                .unwrap();
            let mut response = String::new();
            stream.read_to_string(&mut response).unwrap();
            if response.contains(expected) {
                return true;
            }
        }
        thread::sleep(Duration::from_millis(10));
    }
    false
}

#[test]
fn hmi_locks_media_after_drive_or_stale_state() {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let address = listener.local_addr().unwrap().to_string();
    drop(listener);
    let mut child = Command::new(env!("CARGO_BIN_EXE_ohayess-hmi"))
        .args([&address, "500"])
        .stdin(Stdio::piped())
        .spawn()
        .unwrap();
    let stdin = child.stdin.as_mut().unwrap();
    stdin
        .write_all(&frame(&VehicleState {
            timestamp_ns: Some(now_ns()),
            vehicle_speed_mps: Some(0.0),
            gear: Some(GearState {
                position: GearPosition::Park as i32,
            }),
            ..VehicleState::default()
        }))
        .unwrap();
    assert!(state_is(&address, "\"videoPlayback\":\"allowed\""));

    stdin
        .write_all(&frame(&VehicleState {
            timestamp_ns: Some(now_ns()),
            vehicle_speed_mps: Some(0.0),
            gear: Some(GearState {
                position: GearPosition::Drive as i32,
            }),
            ..VehicleState::default()
        }))
        .unwrap();
    assert!(state_is(&address, "\"videoPlayback\":\"not_parked\""));

    thread::sleep(Duration::from_millis(550));
    assert!(state_is(
        &address,
        "\"videoPlayback\":\"stale_vehicle_state\""
    ));
    child.kill().unwrap();
    child.wait().unwrap();
}
