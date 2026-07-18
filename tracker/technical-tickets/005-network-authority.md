# T005 — Prove two-client authority, prediction, and reconciliation

- Label: `wayfinder:prototype`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/26
- Status: open
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
