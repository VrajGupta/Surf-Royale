# Handoff — T002 Godot Bootstrap

## Completed

GitHub issue #23 / `tracker/technical-tickets/002-godot-bootstrap.md`.

- Installed and pinned Godot 4.7.1 on the M4 through Homebrew.
- Added a typed-GDScript project and minimal launch screen.
- Added a retryable five-second unavailable-server failure path.
- Added a render-independent 30 Hz headless server smoke mode.
- Added a custom CLI test runner and `scripts/verify.sh`.
- Added macOS and Windows export presets and setup/export runbook.
- Ignored `.godot/` and local build artifacts.

## Verification

```bash
./scripts/verify.sh bootstrap
```

Passes. Normal headless project startup also parses and runs without errors.

## Red-team pass

Attacked missing-server timeout, late asynchronous events, headless tick cadence, generated artifacts, and clean-start behavior. Found one race: a late failure callback could overwrite an already successful connection. Added a failing regression test, guarded terminal state transitions, and re-ran the full gate successfully.

## Honest limitations

- Export templates are a documented local dependency and are not installed by the repository.
- Windows artifact generation is documented but not yet exercised on the current Mac.
- The launch screen has no live server to join until T005.

## Next ticket

T003 / GitHub #24 — deterministic authoritative ocean truth.
