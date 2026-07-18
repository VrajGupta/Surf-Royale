# T001 — Lock non-UE5 technical constraints and prototype choice

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/22
- Status: closed by user decisions on 2026-07-18
- Blocked by: —

## What to decide

Lock the primary development machine, prototype platforms, recurring-cost ceiling, performance targets, initial non-UE5 engine, scripting language, visual fidelity, and network test envelope.

## Decision

M4 MacBook Air primary development; Windows + macOS clients; near-zero recurring cost; Godot 4 typed GDScript as a reversible prototype choice; gameplay-readable graybox; 900p60 on M4 and 1080p60 on RTX 3070 Mobile; 100 ms RTT / 2% loss. UE5 is superseded and excluded.

## Acceptance criteria

- `docs/technical/00-technical-brief.md` records all hard gates and exit criteria.
- `docs/specs/godot-vertical-slice.md` carries the performance, failure, and trust invariants.

## Verification-command

```bash
test -f docs/technical/00-technical-brief.md && test -f docs/specs/godot-vertical-slice.md && ! grep -RniE 'Unreal Engine|UE5' docs/technical docs/specs tracker/technical-map.md tracker/technical-tickets | grep -vE 'excluded|supersed|No UE5'
```
