# riak_demo

Docker Compose project that runs OpenRiak and small HTTP client demos in several languages. Each demo writes a JSON object to Riak KV and reads it back.

## Requirements

- Docker
- Docker Compose

## Usage

Run all demos:

```shell
make build
```

This builds images, starts OpenRiak, runs the demos, writes output to `build.log`, and tears the stack down.

OpenRiak listens on ports 8098 (HTTP) and 8087 (Protocol Buffers) while the stack is up.

Please note, only HTTP API is tested in this demo.
