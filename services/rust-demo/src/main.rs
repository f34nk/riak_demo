use std::env;

use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::Value;

const BUCKET: &str = "demo";
const KEY: &str = "hello-rust";

#[derive(Debug, Serialize, Deserialize)]
struct TestObject {
    client: String,
    message: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let riak_host = env::var("RIAK_HOST").unwrap_or_else(|_| "riak".to_string());
    let riak_port = env::var("RIAK_PORT").unwrap_or_else(|_| "8098".to_string());
    let base_url = format!("http://{riak_host}:{riak_port}");

    let test_object = TestObject {
        client: "rust".to_string(),
        message: "Hello from OpenRiak".to_string(),
    };

    println!("=== OpenRiak Rust Demo ===");
    println!("Using OpenRiak at {base_url}");

    write_object(&base_url, BUCKET, KEY, &test_object).await?;
    let result = read_object(&base_url, BUCKET, KEY).await?;

    println!("Result: {}", serde_json::to_string_pretty(&result)?);

    let message = result
        .get("message")
        .and_then(Value::as_str)
        .ok_or("missing message field")?;
    if message != test_object.message {
        return Err("Value mismatch after read!".into());
    }

    println!("Demo complete: write and read verified.");
    Ok(())
}

async fn write_object(
    base_url: &str,
    bucket: &str,
    key: &str,
    data: &TestObject,
) -> Result<(), Box<dyn std::error::Error>> {
    let url = format!("{base_url}/buckets/{bucket}/keys/{key}?w=1&dw=1");
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()?;
    let response = client
        .put(url)
        .header("Content-Type", "application/json")
        .json(data)
        .send()
        .await?;

    let status = response.status();
    if !status.is_success() {
        return Err(format!("PUT failed with status {status}").into());
    }
    println!(
        "Wrote object -> bucket='{bucket}' key='{key}' status={}",
        status.as_u16()
    );
    Ok(())
}

async fn read_object(
    base_url: &str,
    bucket: &str,
    key: &str,
) -> Result<Value, Box<dyn std::error::Error>> {
    let url = format!("{base_url}/buckets/{bucket}/keys/{key}");
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()?;
    let response = client.get(url).send().await?;

    let status = response.status();
    if status != StatusCode::OK {
        return Err(format!("GET failed with status {status}").into());
    }
    println!(
        "Read object  <- bucket='{bucket}' key='{key}' status={}",
        status.as_u16()
    );
    Ok(response.json().await?)
}
