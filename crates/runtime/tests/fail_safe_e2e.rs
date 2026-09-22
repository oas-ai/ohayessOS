use std::io::Write;
use std::process::{Command, Output, Stdio};

use oas_sdk::vehicle::v1::VehicleState;
use prost::Message;

fn run(input: &[u8]) -> Output {
    let mut child = Command::new(env!("CARGO_BIN_EXE_ohayess-runtime"))
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child.stdin.take().unwrap().write_all(input).unwrap();
    child.wait_with_output().unwrap()
}

fn frame(state: &VehicleState) -> Vec<u8> {
    let payload = state.encode_to_vec();
    let mut frame = (payload.len() as u32).to_be_bytes().to_vec();
    frame.extend_from_slice(&payload);
    frame
}

#[test]
fn clean_disconnect_after_a_stale_snapshot_succeeds() {
    let output = run(&frame(&VehicleState {
        timestamp_ns: Some(1),
        vehicle_speed_mps: Some(12.5),
        ..VehicleState::default()
    }));
    let diagnostics = String::from_utf8(output.stderr).unwrap();

    assert!(output.status.success());
    assert!(diagnostics.contains("speed_mps=Some(12.5)"));
    assert!(diagnostics.contains("fresh=false"));
}

#[test]
fn corrupted_protobuf_fails_closed() {
    let output = run(&[0, 0, 0, 1, 0x80]);

    assert!(!output.status.success());
    assert!(
        String::from_utf8(output.stderr)
            .unwrap()
            .contains("protobuf decode")
    );
}

#[test]
fn truncated_snapshot_fails_closed() {
    let output = run(&[0, 0, 0, 2, 0]);

    assert!(!output.status.success());
    assert!(
        String::from_utf8(output.stderr)
            .unwrap()
            .contains("stream I/O")
    );
}

#[test]
fn oversized_snapshot_fails_before_reading_a_payload() {
    let output = run(&(ohayess_runtime::MAX_SNAPSHOT_BYTES + 1).to_be_bytes());

    assert!(!output.status.success());
    assert!(
        String::from_utf8(output.stderr)
            .unwrap()
            .contains("snapshot too large")
    );
}
