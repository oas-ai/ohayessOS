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
    for _ in 0..300 {
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

fn server_is_up(address: &str) -> bool {
    for _ in 0..300 {
        if TcpStream::connect(address).is_ok() {
            return true;
        }
        thread::sleep(Duration::from_millis(10));
    }
    false
}

fn page_contains(address: &str, path: &str, expected: &str) -> bool {
    let Ok(mut stream) = TcpStream::connect(address) else {
        return false;
    };
    stream
        .write_all(format!("GET {path} HTTP/1.1\r\nHost: localhost\r\n\r\n").as_bytes())
        .unwrap();
    let mut response = String::new();
    stream.read_to_string(&mut response).unwrap();
    response.contains(expected)
}

#[test]
fn hmi_locks_media_after_drive_or_stale_state() {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let address = listener.local_addr().unwrap().to_string();
    drop(listener);
    let mut child = Command::new(env!("CARGO_BIN_EXE_ohayess-hmi"))
        .args([&address, "2000"])
        .env("OAS_ALLOW_MEDIA_IN_DRIVE_WHEN_STOPPED", "true")
        .stdin(Stdio::piped())
        .spawn()
        .unwrap();
    assert!(server_is_up(&address));
    for menu in [
        "Home",
        "Media",
        "Split",
        "Vehicle",
        "Settings",
        "Diagnostics",
        "Comfort control",
    ] {
        assert!(page_contains(&address, "/", menu));
    }
    assert!(page_contains(&address, "/design.css", "--touch-target"));
    assert!(page_contains(&address, "/", "data-theme-choice"));
    assert!(page_contains(&address, "/", "제어·안전 판단에는 사용하지 않습니다"));
    let stdin = child.stdin.as_mut().unwrap();
    stdin
        .write_all(&frame(&VehicleState {
            timestamp_ns: Some(now_ns()),
            vehicle_speed_mps: Some(0.0),
            gear: Some(GearState {
                position: GearPosition::Park as i32,
            }),
            night_mode: Some(true),
            raw_signals: [
                ("CGW1.CF_Gway_DrvDrSw".to_owned(), 1.0),
                ("DATC12.CR_Datc_DrTempDispC".to_owned(), 20.0),
            ]
            .into(),
            ..VehicleState::default()
        }))
        .unwrap();
    assert!(state_is(&address, "\"videoPlayback\":\"allowed\""));
    assert!(state_is(&address, "\"nightMode\":true"));
    assert!(state_is(&address, "\"driverDoorSwitch\":1"));
    assert!(state_is(&address, "\"driverTemperatureC\":20"));

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
    assert!(state_is(&address, "\"videoPlayback\":\"allowed\""));

    stdin
        .write_all(&frame(&VehicleState {
            timestamp_ns: Some(now_ns()),
            vehicle_speed_mps: Some(0.2),
            gear: Some(GearState {
                position: GearPosition::Drive as i32,
            }),
            ..VehicleState::default()
        }))
        .unwrap();
    assert!(state_is(
        &address,
        "\"videoPlayback\":\"vehicle_in_motion\""
    ));

    thread::sleep(Duration::from_millis(2050));
    assert!(state_is(
        &address,
        "\"videoPlayback\":\"stale_vehicle_state\""
    ));
    child.kill().unwrap();
    child.wait().unwrap();
}
