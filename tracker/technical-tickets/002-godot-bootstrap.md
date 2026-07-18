# T002 — Bootstrap Godot project and M4 verification workflow

- Label: `wayfinder:task`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/23
- Status: open
- Blocked by: T001

## What to build

Create a minimal Godot 4 typed-GDScript project with a launch screen, a render-independent headless server entry point, deterministic test runner, cross-platform export presets/runbook, and `scripts/verify.sh` gates. Pin the supported Godot version and document native Apple Silicon setup without UE5 or Rosetta-only dependencies.

## Acceptance criteria

- Project opens and runs natively on the M4.
- Headless server exits cleanly and maintains a fixed 30 Hz empty simulation.
- Missing server connection fails within five seconds and returns a clear launch-screen error.
- macOS and Windows export paths are documented; any host-target limitation is explicit.
- No paid service or external account is required.
- A clean checkout has one command for bootstrap verification.

## Verification-command

```bash
./scripts/verify.sh bootstrap
```
