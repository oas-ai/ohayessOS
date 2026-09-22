use std::io;
use std::process::ExitCode;
use std::time::{SystemTime, UNIX_EPOCH};

use ohayess_runtime::Runtime;

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
    let mut runtime = Runtime::new(io::stdin().lock());

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
        eprintln!(
            "vehicle_state timestamp_ns={:?} speed_mps={:?} fresh={}",
            state.timestamp_ns,
            state.vehicle_speed_mps,
            runtime.latest_is_fresh(now_ns, maximum_age_ns)
        );
    }
    Ok(())
}
