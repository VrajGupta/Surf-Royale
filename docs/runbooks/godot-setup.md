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

The launch screen attempts a direct ENet connection to `127.0.0.1:7000`. While the networking slice is not yet implemented, an unavailable server produces an actionable error within five seconds and returns the UI to a retryable state.

## Export templates

Install the matching official Godot 4.7.1 export templates from **Editor → Manage Export Templates**. Templates are machine dependencies and are not committed.

```bash
mkdir -p build/macos build/windows
godot --headless --path . --export-debug "macOS" build/macos/SurfRoyale.zip
godot --headless --path . --export-debug "Windows Desktop" build/windows/SurfRoyale.exe
```

Godot can cross-export the Windows prototype from macOS when the matching templates are installed. macOS code signing and notarization are intentionally disabled for the local risk slice; distribution signing is a later release concern.

## Clean-checkout verification

```bash
./scripts/verify.sh bootstrap
```

This imports the project, runs the public launch-timeout tests, and exercises the render-independent 30 Hz server smoke path.
