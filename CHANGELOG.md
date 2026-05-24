# Changelog
All notable changes to this project will be documented here.

## [Unreleased]

## 2026-05-24
### Added
- Gleam HTTP client demo that writes and reads a JSON object from OpenRiak.

### Fixed
- Demo build waits for completion by polling demo-done instead of compose wait, which failed after one-shot containers exited.
- Build output is captured to build.log, resources are cleaned on teardown, and the build fails when demos do not finish successfully.

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
