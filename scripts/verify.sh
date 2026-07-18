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
    [[ -z "$client_one_pid" ]] || kill "$client_one_pid" 2>/dev/null || true
    [[ -z "$client_two_pid" ]] || kill "$client_two_pid" 2>/dev/null || true
    [[ -z "$server_pid" ]] || kill "$server_pid" 2>/dev/null || true
  }
  trap cleanup_network_processes EXIT

  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --server --port=7000 --duration=7.0 --result=res://build/network/server.json \
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
    --client=1 --host=127.0.0.1 --port=7000 --duration=4.0 --result=res://build/network/client-1.json \
    >"$client_one_log" 2>&1 &
  client_one_pid=$!
  "$GODOT_BIN" --headless --path "$ROOT" -- \
    --client=2 --host=127.0.0.1 --port=7000 --duration=4.0 --result=res://build/network/client-2.json \
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
  network)
    verify_network
    ;;
  all)
    verify_bootstrap
    run_tests all
    verify_network
    ;;
  *)
    printf 'Unknown verification suite: %s\n' "$SUITE" >&2
    exit 2
    ;;
esac
