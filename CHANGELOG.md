# Changelog
All notable changes to this project will be documented here.

## [Unreleased]

## 2026-06-05
Java, TypeScript, and Erlang demos now store and read objects through generated Smithy clients backed by a custom OpenRiak HTTP protocol. Compose and Makefile targets were aligned with the openriak service name, and Docker packaging was corrected so generated client code and runtime dependencies are included in demo images.

### Added
- Java and TypeScript demos use generated Smithy clients for default object writes and reads.
- TypeScript openRiakHttp protocol codegen with error body parsing and serde unit tests.
- Erlang demo integrates the generated Smithy client into its rebar build.

### Fixed
- Java demo HTTP Basic auth, response header coercion, ServiceLoader merging in shaded jars, and Docker packaging of the generated client.
- TypeScript demo Docker image includes the generated client, runtime dependencies, and HTTP Basic auth configuration.
- Erlang demo HTTP client dependency and compile-only demo target.

### Changed
- Compose service and network renamed to openriak; demo clients default RIAK_HOST to openriak.
- Makefile docker build targets reorganized; Java demo runs unit tests during its demo build.

### Removed
- Python Smithy client codegen configuration.

## 2026-06-04
Smithy client codegen and a custom OpenRiak HTTP protocol for Java were added alongside the expanded Smithy model, enabling generated clients to bind Riak HTTP requests and responses with mapped error semantics.

### Added
- Smithy model for the OpenRiak 3.4 HTTP API, including KV, query, map reduce, datatypes, admin, and queue operations.
- Makefile validate target to check the Smithy model.
- Smithy client codegen builds for Erlang, Java, TypeScript, and Python.
- OpenRiak HTTP client protocol for Smithy Java with request and response binding, Riak error status mapping, and unit tests.

### Fixed
- Smithy validation issues by routing conflicting Riak headers through prefix headers, removing an unsupported auth header binding, and suppressing non-4xx error semantics where the server uses redirect and multiple-choice responses.
- Legacy counter routes, empty-body PUT and POST status codes, and bucket properties payload naming in the Smithy model.
- HTTP request bindings applied in input member order; Smithy prelude loads when assembling the OpenRiak model.

### Changed
- OpenRiak Docker image builds the openriak-3.4 branch with Erlang 26 on Debian bookworm.
- Smithy model expanded with typed query payloads, conditional write headers, sibling read handling, CRDT response headers, AAE fold routes, fetch and replication queues, and client generation traits.
- Service demo builds compile generated Smithy clients alongside protocol runtime code.

## 2026-05-24
### Added
- Gleam, Erlang client demos.

### Fixed
- Demo build waits for completion by polling demo-done instead of compose wait, which failed after one-shot containers exited.
- Build output is captured to build.log, resources are cleaned on teardown, and the build fails when demos do not finish successfully.

### Changed
- README links to OpenRiak and clarifies that only the HTTP API is tested.

## 2026-05-23
### Added
- Initial repository with Docker Compose stack running OpenRiak and Python and curl client demos.
- KV vnode readiness healthcheck so demos start only after the cluster is usable.
- Java, Rust, TypeScript, and Elixir client demos, each storing and verifying a JSON object over HTTP.
- demo-done service so compose waits for every demo before shutting down.
- Root Makefile with build and rebuild targets, plus a README.

### Fixed
- OpenRiak Docker image build and runtime configuration.
- Compose no longer stops early when individual demo containers exit.
- Detached compose run waits for demo-done before collecting logs.

### Changed
- Demo clients rely on compose healthchecks instead of their own readiness polling.
- JVM startup options tuned for faster Java demo startup.

### Removed
- Unused Makefiles under service directories.
