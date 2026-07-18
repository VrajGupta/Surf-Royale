#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-$(command -v godot || true)}"
SUITE="${1:-all}"

if [[ -z "$GODOT_BIN" ]]; then
  printf 'Godot is required. Install the pinned version from docs/runbooks/godot-setup.md.\n' >&2
  exit 1
fi

version="$($GODOT_BIN --version)"
if [[ "$version" != 4.7.1* ]]; then
  printf 'Expected Godot 4.7.1, found %s\n' "$version" >&2
  exit 1
fi

run_tests() {
  "$GODOT_BIN" --headless --path "$ROOT" -s res://tests/test_runner.gd -- "$1"
}

verify_bootstrap() {
  test -f "$ROOT/project.godot"
  test -f "$ROOT/export_presets.cfg"
  test -f "$ROOT/docs/runbooks/godot-setup.md"
  "$GODOT_BIN" --headless --editor --path "$ROOT" --quit-after 2
  run_tests bootstrap
  "$GODOT_BIN" --headless --path "$ROOT" -- --server-smoke=0.25
}

case "$SUITE" in
  bootstrap) verify_bootstrap ;;
  ocean|surf|network)
    run_tests "$SUITE"
    ;;
  all)
    verify_bootstrap
    run_tests all
    ;;
  *)
    printf 'Unknown verification suite: %s\n' "$SUITE" >&2
    exit 2
    ;;
esac
