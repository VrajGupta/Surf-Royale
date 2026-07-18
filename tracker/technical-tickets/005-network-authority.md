# T005 — Prove two-client authority, prediction, and reconciliation

- Label: `wayfinder:prototype`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/26
- Status: closed (implemented 2026-07-18)
- Blocked by: T004

## What to build

Connect two clients to a 30 Hz headless ENet server. Replicate the server-owned ocean schedule and surf state, send client input intent, predict local motion, and reconcile to authoritative state. Add repeatable network impairment testing for 100 ms RTT and 2% packet loss.

## Acceptance criteria

- Clients never authoritatively submit transforms, state, stamina, damage, or wave claims.
- Both clients observe the same ocean and legal surf-state transitions.
- Position correction p95 is at most 0.5 m during normal paddling/riding under the network envelope.
- No false state transitions occur under impairment.
- Server missed-tick rate stays below 1% during the two-client soak.
- Malformed or impossible updates are discarded with bounded diagnostics.
- Server unavailability times out within five seconds and returns clients safely to launch.

## Verification-command

```bash
./scripts/verify.sh network
```

## Implementation (2026-07-18)

Added a real local ENet harness that launches one headless server and two headless clients. The server owns the ocean seed, controller state, stamina, and transforms; clients submit only sanitized input intent, predict locally, and reconcile from snapshots. The deterministic harness applies 50 ms one-way delay and 2% packet drop, validates JSON evidence, rejects malformed/non-finite data, requires p95 correction ≤0.5 m, zero false wipeouts, two observed clients, no engine errors, and server missed ticks <1%.
