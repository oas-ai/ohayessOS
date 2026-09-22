use std::io::{self, Read};

use ohayess_runtime::{HmiCapability, HmiFreshness, HmiState, MAX_SNAPSHOT_BYTES};
use prost::Message;

fn main() -> Result<(), String> {
    let mut input = io::stdin().lock();
    let mut length = [0; 4];
    input
        .read_exact(&mut length)
        .map_err(|error| error.to_string())?;
    let length = u32::from_be_bytes(length);
    if length > MAX_SNAPSHOT_BYTES {
        return Err("HmiState frame is too large".into());
    }
    let mut payload = vec![0; length as usize];
    input
        .read_exact(&mut payload)
        .map_err(|error| error.to_string())?;
    let state = HmiState::decode(payload.as_slice()).map_err(|error| error.to_string())?;
    let freshness = HmiFreshness::try_from(state.freshness).unwrap_or(HmiFreshness::Unspecified);
    let media = HmiCapability::try_from(state.media_playback).unwrap_or(HmiCapability::Unspecified);
    let diagnostics =
        HmiCapability::try_from(state.diagnostics).unwrap_or(HmiCapability::Unspecified);
    let controls =
        HmiCapability::try_from(state.vehicle_controls).unwrap_or(HmiCapability::Unspecified);
    println!(
        "freshness={freshness:?} media={media:?} reason={} diagnostics={diagnostics:?} controls={controls:?} speed={:?}",
        state.media_playback_reason,
        state
            .vehicle_state
            .and_then(|vehicle| vehicle.vehicle_speed_mps)
    );
    Ok(())
}
