import envoy
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/json

const bucket = "demo"
const key = "hello-gleam"
const expected_message = "Hello from OpenRiak"

fn env_or_default(name: String, default: String) -> String {
  case envoy.get(name) {
    Ok(value) -> value
    Error(Nil) -> default
  }
}

pub fn main() {
  let riak_host = env_or_default("RIAK_HOST", "openriak")
  let riak_port = env_or_default("RIAK_PORT", "8098")
  let base_url = "http://" <> riak_host <> ":" <> riak_port

  io.println("=== OpenRiak Gleam Demo ===")
  io.println("Using OpenRiak at " <> base_url)

  write_object(base_url, bucket, key)
  let body = read_object(base_url, bucket, key)

  io.println("Result: " <> body)

  let message_decoder = {
    use message <- decode.field("message", decode.string)
    decode.success(message)
  }
  let assert Ok(message) = json.parse(from: body, using: message_decoder)

  case message == expected_message {
    True -> io.println("Demo complete: write and read verified.")
    False -> panic as "Value mismatch after read!"
  }
}

fn write_object(base_url: String, bucket: String, key: String) -> Nil {
  let payload =
    json.object([
      #("client", json.string("gleam")),
      #("message", json.string(expected_message)),
    ])
    |> json.to_string

  let url =
    base_url <> "/buckets/" <> bucket <> "/keys/" <> key <> "?w=1&dw=1"

  let assert Ok(req) = request.to(url)
  let req =
    req
    |> request.set_method(http.Put)
    |> request.set_header("content-type", "application/json")
    |> request.set_body(payload)

  let assert Ok(resp) = httpc.send(req)

  case resp.status >= 200 && resp.status < 300 {
    True ->
      io.println(
        "Wrote object -> bucket='"
        <> bucket
        <> "' key='"
        <> key
        <> "' status="
        <> int.to_string(resp.status),
      )
    False ->
      panic as { "PUT failed with status " <> int.to_string(resp.status) }
  }
}

fn read_object(base_url: String, bucket: String, key: String) -> String {
  let url = base_url <> "/buckets/" <> bucket <> "/keys/" <> key

  let assert Ok(req) = request.to(url)
  let req = req |> request.set_method(http.Get)

  let assert Ok(resp) = httpc.send(req)

  case resp.status {
    200 -> {
      io.println(
        "Read object  <- bucket='"
        <> bucket
        <> "' key='"
        <> key
        <> "' status="
        <> int.to_string(resp.status),
      )
      resp.body
    }
  _ -> panic as { "GET failed with status " <> int.to_string(resp.status) }
  }
}
