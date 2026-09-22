use std::io::{self, Write};
use std::process::ExitCode;
use std::time::{SystemTime, UNIX_EPOCH};

use ohayess_runtime::{MediaPlaybackConfig, Runtime, hmi_state_for_state};
use prost::Message;

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("ohayess-runtime: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), String> {
    let maximum_age_ms = std::env::args()
        .nth(1)
        .map(|value| value.parse::<u64>())
        .transpose()
        .map_err(|error| format!("invalid maximum age: {error}"))?
        .unwrap_or(500);
    let maximum_age_ns = maximum_age_ms
        .checked_mul(1_000_000)
        .ok_or("maximum age is too large")?;
    let config = MediaPlaybackConfig {
        allow_drive_when_stopped: matches!(std::env::var("OAS_ALLOW_MEDIA_IN_DRIVE_WHEN_STOPPED").as_deref(), Ok("true")),
    };
    let emit_hmi_state = matches!(std::env::var("OAS_HMI_STATE_OUTPUT").as_deref(), Ok("true"));
    let mut runtime = Runtime::new(io::stdin().lock());
    let mut output = io::stdout().lock();

    while runtime
        .read_next()
        .map_err(|error| error.to_string())?
        .is_some()
    {
        let now_ns = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|error| format!("system clock: {error}"))?
            .as_nanos();
        let now_ns = u64::try_from(now_ns).map_err(|_| "system timestamp is too large")?;
        let state = runtime.latest().expect("read_next returned a snapshot");
        if emit_hmi_state {
            let hmi_state = hmi_state_for_state(Some(state), now_ns, maximum_age_ns, config);
            let payload = hmi_state.encode_to_vec();
            let length = u32::try_from(payload.len()).map_err(|_| "HMI snapshot is too large")?;
            output.write_all(&length.to_be_bytes()).map_err(|error| error.to_string())?;
            output.write_all(&payload).map_err(|error| error.to_string())?;
            output.flush().map_err(|error| error.to_string())?;
        }
        eprintln!(
            "vehicle_state timestamp_ns={:?} speed_mps={:?} acceleration_mps2={:?} steering_angle_rad={:?} brake_pressed={:?} fresh={}",
            state.timestamp_ns,
            state.vehicle_speed_mps,
            state.acceleration_mps2,
            state.steering.as_ref().and_then(|value| value.angle_rad),
            state.brake.as_ref().and_then(|value| value.pressed),
            runtime.latest_is_fresh(now_ns, maximum_age_ns)
        );
    }
    Ok(())
}
