#![forbid(unsafe_code)]

use std::io::{self, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

use ohayess_runtime::{GearPosition, Runtime, VehicleState, video_playback_for_state};

const INDEX: &str = include_str!("index.html");

fn main() -> Result<(), String> {
    let address = std::env::args()
        .nth(1)
        .unwrap_or_else(|| "127.0.0.1:8080".to_owned());
    let maximum_age_ms = std::env::args()
        .nth(2)
        .map(|value| value.parse::<u64>())
        .transpose()
        .map_err(|error| format!("invalid maximum age: {error}"))?
        .unwrap_or(500);
    let maximum_age_ns = maximum_age_ms
        .checked_mul(1_000_000)
        .ok_or("maximum age is too large")?;
    let latest = Arc::new(Mutex::new(None));
    read_states(Arc::clone(&latest));

    let listener =
        TcpListener::bind(&address).map_err(|error| format!("bind {address}: {error}"))?;
    eprintln!(
        "ohayess-hmi: listening on {}",
        listener.local_addr().unwrap()
    );
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => serve(stream, &latest, maximum_age_ns),
            Err(error) => eprintln!("ohayess-hmi: accept: {error}"),
        }
    }
    Ok(())
}

fn read_states(latest: Arc<Mutex<Option<VehicleState>>>) {
    std::thread::spawn(move || {
        let mut runtime = Runtime::new(io::stdin().lock());
        loop {
            match runtime.read_next() {
                Ok(Some(state)) => {
                    *latest.lock().expect("state lock poisoned") = Some(state.clone())
                }
                Ok(None) => return,
                Err(error) => {
                    eprintln!("ohayess-hmi: vehicle state stream: {error}");
                    return;
                }
            }
        }
    });
}

fn serve(mut stream: TcpStream, latest: &Arc<Mutex<Option<VehicleState>>>, maximum_age_ns: u64) {
    let mut request = [0; 1024];
    let Ok(size) = stream.read(&mut request) else {
        return;
    };
    let target = std::str::from_utf8(&request[..size])
        .ok()
        .and_then(|request| request.split_whitespace().nth(1));
    let (content_type, body) = match target {
        Some("/") => ("text/html; charset=utf-8", INDEX.to_owned()),
        Some("/state") => ("application/json", state_json(latest, maximum_age_ns)),
        _ => ("text/plain; charset=utf-8", "not found".to_owned()),
    };
    let status = if target == Some("/") || target == Some("/state") {
        "200 OK"
    } else {
        "404 Not Found"
    };
    let response = format!(
        "HTTP/1.1 {status}\r\nContent-Type: {content_type}\r\nContent-Length: {}\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n{body}",
        body.len()
    );
    let _ = stream.write_all(response.as_bytes());
}

fn state_json(latest: &Arc<Mutex<Option<VehicleState>>>, maximum_age_ns: u64) -> String {
    let state = latest.lock().expect("state lock poisoned").clone();
    let now_ns = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .ok()
        .and_then(|duration| u64::try_from(duration.as_nanos()).ok())
        .unwrap_or(u64::MAX);
    let playback = video_playback_for_state(state.as_ref(), now_ns, maximum_age_ns);
    let speed = state
        .as_ref()
        .and_then(|state| state.vehicle_speed_mps)
        .filter(|speed| speed.is_finite())
        .map(|speed| speed.to_string())
        .unwrap_or_else(|| "null".to_owned());
    let gear = state
        .as_ref()
        .and_then(|state| state.gear.as_ref())
        .and_then(|gear| GearPosition::try_from(gear.position).ok())
        .map(|gear| gear.as_str_name().to_ascii_lowercase())
        .unwrap_or_else(|| "unknown".to_owned());
    format!(
        "{{\"videoPlayback\":\"{}\",\"speedMps\":{speed},\"gear\":\"{gear}\"}}",
        playback.as_str()
    )
}
