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
  local suite="$1"
  local log_file
  log_file="$(mktemp)"
  if ! "$GODOT_BIN" --headless --path "$ROOT" -s res://tests/test_runner.gd -- "$suite" >"$log_file" 2>&1; then
    cat "$log_file"
    rm -f "$log_file"
    return 1
  fi
  cat "$log_file"
  if grep -Eq 'SCRIPT ERROR:|^ERROR:' "$log_file" || ! grep -q 'TESTS_OK' "$log_file"; then
    rm -f "$log_file"
    return 1
  fi
  rm -f "$log_file"
}

verify_bootstrap() {
  test -f "$ROOT/project.godot"
  test -f "$ROOT/export_presets.cfg"
  test -f "$ROOT/docs/runbooks/godot-setup.md"
  "$GODOT_BIN" --headless --editor --path "$ROOT" --quit-after 2
  run_tests bootstrap
  "$GODOT_BIN" --headless --path "$ROOT" -- --server-smoke=0.25
}

verify_slice() {
  run_tests slice

  local result_dir="$ROOT/build/slice"
  rm -rf "$result_dir"
  mkdir -p "$result_dir"
  local smoke_log="$result_dir/smoke.log"

  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --slice-smoke=3.0 --result=res://build/slice/smoke.json \
    >"$smoke_log" 2>&1

  python3 - "$result_dir" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
result = json.loads((root / "smoke.json").read_text())
log = (root / "smoke.log").read_text()
assert "ERROR:" not in log and "SCRIPT ERROR:" not in log, log
assert "SLICE_BENCHMARK_OK" in log, log
assert result["passed"] is True, result
assert result["resolution"] == "1600x900", result
assert result["duration_seconds"] >= 3.0, result
assert result["frame_samples"] >= 30, result
assert result["memory_growth_bytes"] <= 67_108_864, result
print("SLICE_GATE_OK")
PY
}

verify_evidence_and_export() {
  python3 - "$ROOT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
evidence = json.loads((root / "docs/evidence/m4-2026-07-18-benchmark.json").read_text())
screenshot = root / "docs/evidence/m4-2026-07-18-tutorial-cove.png"
runbook = (root / "docs/runbooks/godot-setup.md").read_text()
assert evidence["passed"] is True, evidence
assert evidence["platform"] == "macOS", evidence
assert evidence["architecture"] == "arm64", evidence
assert evidence["resolution"] == "1600x900", evidence
assert evidence["duration_seconds"] >= 300.0, evidence
assert evidence["p95_frame_ms"] <= 16.7, evidence
assert evidence["memory_growth_bytes"] <= 67_108_864, evidence
assert screenshot.stat().st_size > 0
assert "1920×1080" in runbook and "RTX 3070 Mobile" in runbook
print("EVIDENCE_GATE_OK")
PY

  local export_dir="$ROOT/build/macos"
  local export_log="$export_dir/export.log"
  rm -rf "$export_dir"
  mkdir -p "$export_dir"
  "$GODOT_BIN" --headless --path "$ROOT" \
    --export-release "macOS" "$export_dir/SurfRoyale.zip" \
    >"$export_log" 2>&1
  test -s "$export_dir/SurfRoyale.zip"
  if grep -Eq 'SCRIPT ERROR:|^ERROR:' "$export_log"; then
    cat "$export_log"
    return 1
  fi
  printf 'MACOS_EXPORT_GATE_OK\n'
}

verify_network() {
  run_tests network

  local result_dir="$ROOT/build/network"
  rm -rf "$result_dir"
  mkdir -p "$result_dir"

  local server_log="$result_dir/server.log"
  local client_one_log="$result_dir/client-1.log"
  local client_two_log="$result_dir/client-2.log"
  local server_pid=""
  local client_one_pid=""
  local client_two_pid=""

  cleanup_network_processes() {
    [[ -z "${client_one_pid:-}" ]] || kill "$client_one_pid" 2>/dev/null || true
    [[ -z "${client_two_pid:-}" ]] || kill "$client_two_pid" 2>/dev/null || true
    [[ -z "${server_pid:-}" ]] || kill "$server_pid" 2>/dev/null || true
  }
  trap cleanup_network_processes EXIT

  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --server --port=7000 --duration=5.0 --result=res://build/network/server.json \
    >"$server_log" 2>&1 &
  server_pid=$!

  local ready=0
  for _ in {1..50}; do
    if grep -q 'NETWORK_SERVER_READY' "$server_log"; then
      ready=1
      break
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done
  if [[ "$ready" -ne 1 ]]; then
    printf 'Network server did not become ready.\n' >&2
    return 1
  fi

  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --client=1 --host=127.0.0.1 --port=7000 --duration=6.0 --result=res://build/network/client-1.json \
    >"$client_one_log" 2>&1 &
  client_one_pid=$!
  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --client=2 --host=127.0.0.1 --port=7000 --duration=6.0 --result=res://build/network/client-2.json \
    >"$client_two_log" 2>&1 &
  client_two_pid=$!

  local client_one_status=0
  local client_two_status=0
  local server_status=0
  wait "$client_one_pid" || client_one_status=$?
  wait "$client_two_pid" || client_two_status=$?
  wait "$server_pid" || server_status=$?
  client_one_pid=""
  client_two_pid=""
  server_pid=""

  if [[ "$client_one_status" -ne 0 || "$client_two_status" -ne 0 || "$server_status" -ne 0 ]]; then
    printf 'Network processes failed: server=%d client1=%d client2=%d\n' "$server_status" "$client_one_status" "$client_two_status" >&2
    return 1
  fi

  python3 - "$result_dir" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
server = json.loads((root / "server.json").read_text())
clients = [json.loads((root / f"client-{index}.json").read_text()) for index in (1, 2)]
logs = [(root / name).read_text() for name in ("server.log", "client-1.log", "client-2.log")]

assert all("ERROR:" not in log and "SCRIPT ERROR:" not in log for log in logs), logs
assert server["clients_seen"] >= 2, server
assert server["missed_tick_rate"] < 0.01, server
assert server["sidearm_fire_requests"] >= 2, server
assert server["sidearm_hits"] >= 1, server
assert server["minimum_player_hp"] < 100, server
assert server["minimum_board_hp"] < 100, server
for client in clients:
    assert client["passed"] is True, client
    assert client["connected"] is True, client
    assert client["snapshots"] >= 30, client
    assert client["p95_correction_m"] <= 0.5, client
    assert client["false_state_transitions"] == 0, client
    assert client["invalid_snapshots"] == 0, client

print("NETWORK_GATE_OK")
PY

  trap - EXIT
}

case "$SUITE" in
  bootstrap) verify_bootstrap ;;
  ocean|surf)
    run_tests "$SUITE"
    ;;
  slice)
    verify_slice
    ;;
  network)
    verify_network
    ;;
  all)
    verify_bootstrap
    run_tests all
    verify_slice
    verify_network
    verify_evidence_and_export
    ;;
  *)
    printf 'Unknown verification suite: %s\n' "$SUITE" >&2
    exit 2
    ;;
esac
