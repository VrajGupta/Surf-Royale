# T007 — Part 3 network-authority audit fixes

- Label: `wayfinder:prototype`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/30
- Status: completed 2026-07-18
- Blocked by: T006

## Violated invariants

- Clients must observe the server-owned deterministic ocean seed rather than silently predicting with unrelated seeds.
- Client input intent must stay bounded; stale, duplicate, or oversized sequence claims cannot replace server input truth or poison later valid inputs.

## What to build

- Include the authoritative ocean seed in the authority-only server hello and construct client prediction from that seed.
- Record server/client seed evidence and fail the network gate on mismatch.
- Track the last accepted input sequence per peer, reject duplicates/stale values and implausibly large forward jumps, and prove subsequent valid input continues to be accepted.

## Acceptance criteria

- Both clients report the exact server ocean seed `20260718`.
- The deterministic soak injects stale and oversized input sequence claims from both clients.
- At least four malformed sequence claims are rejected while at least 200 normal inputs remain accepted.
- The existing correction, false-state, sidearm, HP/board, missed-tick, and clean-log gates remain green.

## Verification-command

```bash
./scripts/verify.sh all
```

## Result

Implemented in the Part 3 audit. The network evidence now fails on seed mismatch, rejects stale/duplicate/oversized sequence claims without poisoning the accepted sequence window, and keeps the complete global gate green.
