# Handoff — T005 Two-Client Network Authority

## Completed

GitHub issue #26 / `tracker/technical-tickets/005-network-authority.md`.

- Added a real local ENet server and two-client headless harness.
- Server exclusively owns the ocean seed, surf simulation, transforms, state, and stamina.
- Clients submit sanitized intent only; position/damage claims are ignored by construction.
- Clients predict locally and reconcile to server snapshots.
- Deterministic app-level impairment supplies 50 ms one-way delay and 2% packet drop.
- JSON evidence records corrections, snapshots, state mismatches, invalid data, clients seen, and missed ticks.

## Verification

```bash
./scripts/verify.sh network
```

Passes on the M4. Latest run: two clients, 115+ snapshots each, p95 horizontal correction about 0.008 m, zero false state transitions, zero invalid snapshots, and 0% measured missed server ticks.

## Red-team pass

Attacked forged position/damage fields, out-of-range and non-finite steering, invalid correction samples, disconnect races, stale queued packets, and hidden engine errors. The first integration run appeared green but the server log exposed a stale-packet ENet error after client disconnect. Tightened the gate to reject engine errors, added disconnect queue cleanup and due-packet discard, then re-ran successfully with clean logs.

## Honest limitations

- Delay/loss are deterministic application-level impairment, not an OS network emulator.
- The slice validates two real clients and only models 60-player scale later; it does not claim 60 live clients.
- Snapshot reconciliation currently applies authoritative state directly; presentation smoothing belongs in T006 or a later production pass.
- Exact server ocean seed is never sent; client prediction currently uses a visual-only local seed while paddle movement is tested.

## Next ticket

T006 / GitHub #27 — integrated tutorial-cove gameplay/readability/evidence slice.
