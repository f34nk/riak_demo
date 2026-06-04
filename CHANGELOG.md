# Changelog
All notable changes to this project will be documented here.

## [Unreleased]

## 2026-06-04
### Added
- Smithy model for the OpenRiak 3.4 HTTP API, including KV, query, map reduce, datatypes, admin, and queue operations.
- Makefile validate target to check the Smithy model.

### Fixed
- Smithy validation issues by routing conflicting Riak headers through prefix headers, removing an unsupported auth header binding, and suppressing non-4xx error semantics where the server uses redirect and multiple-choice responses.
- Legacy counter routes, empty-body PUT and POST status codes, and bucket properties payload naming in the Smithy model.

### Changed
- OpenRiak Docker image builds the openriak-3.4 branch with Erlang 26 on Debian bookworm.
- Smithy model expanded with typed query payloads, conditional write headers, sibling read handling, CRDT response headers, AAE fold routes, fetch and replication queues, and client generation traits.

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
