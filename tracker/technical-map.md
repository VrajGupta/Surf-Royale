# Wayfinder Map — Non-UE5 Godot Risk Slice

- Canonical issue: [Wayfinder Map — Non-UE5 Godot Risk Slice (#21)](https://github.com/VrajGupta/Surf-Royale/issues/21)
- Tracker: GitHub Issues on `VrajGupta/Surf-Royale`; local mirrors live in `tracker/technical-tickets/`.
- Frontier rule: open + unassigned + every blocker closed.

## Destination

Produce an evidence-backed, runnable Godot 4 tutorial-cove risk slice that lets one developer decide whether Godot remains viable for Surf Royale's permanent stack. The slice must prove deterministic ocean truth, momentum-honest surfing, authoritative two-client networking, representative combat/stamina/wipeout behavior, cross-platform build workflow, and explicit performance evidence.

## Constraints locked 2026-07-18

- Solo developer.
- M4 MacBook Air is the primary development machine.
- Prototype clients target Windows and macOS.
- Near-zero recurring tooling cost.
- Godot 4 + typed GDScript for this reversible prototype.
- Gameplay-readable graybox.
- M4: 900p60; RTX 3070 Mobile: 1080p60.
- Network gate: 100 ms RTT / 2% packet loss.
- UE5 is superseded and excluded.

## Burn-down order

1. T001 — Technical brief and prototype choice (**closed by user decisions**)
2. T002 — Godot bootstrap, M4 workflow, exports, and verification harness
3. T003 — Deterministic authoritative ocean truth
4. T004 — Momentum-honest six-state surf controller
5. T005 — Two-client authority, prediction, and reconciliation
6. T006 — Combat, stamina, wipeout, reef readability, and integrated evidence review

Dependency chain: `T001 → T002 → T003 → T004 → T005 → T006`.

## Decision gates

- Godot is a prototype choice, not a permanent stack commitment.
- T004 requires later user playtest sign-off before production tuning is locked.
- T006 decides whether to retain Godot, run a Unity comparison spike, or revise scope.

## Out of scope

Production backend, matchmaking, accounts, 50–60 live-player validation, progression, store, full 3×3 km map, production anti-cheat vendor, final art, console targets, and all UE5 work.
