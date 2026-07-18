# Godot 4.7.1 Setup and Export Runbook

## Native M4 setup

```bash
brew install --cask godot
godot --version
./scripts/verify.sh bootstrap
```

The gate requires Godot `4.7.1`. The Homebrew cask installs the native Apple Silicon application and links `/opt/homebrew/bin/godot`. No Rosetta-only dependency is required.

## Run locally

```bash
godot --editor --path .
godot --path .
godot --headless --path . -- --server-smoke=1.0
```

Choose **Play Local Tutorial Cove** for the standalone graybox controls slice. The launch screen can also connect directly to an ENet server at `127.0.0.1:7000`; an unavailable server produces an actionable error within five seconds and returns the UI to a retryable state.

Run the authoritative network harness manually with separate terminals:

```bash
godot --headless --path . -- --server --port=7000 --duration=30
godot --path . -- --client=1 --host=127.0.0.1 --port=7000 --duration=30
godot --path . -- --client=2 --host=127.0.0.1 --port=7000 --duration=30
```

## Export templates

Install the matching official Godot 4.7.1 export templates from **Editor → Manage Export Templates**. Templates are machine dependencies and are not committed.

```bash
mkdir -p build/macos build/windows
godot --headless --path . --export-release "macOS" build/macos/SurfRoyale.zip
godot --headless --path . --export-release "Windows Desktop" build/windows/SurfRoyale.exe
```

Godot can cross-export the x86_64 Windows prototype from macOS when the matching templates are installed. The Windows reference run is 1920×1080 at 60 FPS on the Alienware m15 R6 / RTX 3070 Mobile; record its evidence when that machine is available. macOS code signing and notarization are intentionally disabled for this local risk slice, so the generated ZIP is a review artifact rather than a distributable release.

## Performance evidence

Run the representative M4 render workload at the pinned 1600×900 internal resolution:

```bash
godot --path . -- \
  --slice-benchmark=300 \
  --result=res://docs/evidence/m4-2026-07-18-benchmark.json \
  --screenshot=res://docs/evidence/m4-2026-07-18-tutorial-cove.png
```

The command exits nonzero if the run is shorter than five minutes, p95 frame time exceeds 16.7 ms, memory growth exceeds 64 MiB, or the evidence cannot meet the slice gate.

## Clean-checkout verification

```bash
./scripts/verify.sh bootstrap
```

This imports the project, runs the public launch-timeout tests, and exercises the render-independent 30 Hz server smoke path.
