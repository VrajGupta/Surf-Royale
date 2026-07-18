# T006 — Assemble gameplay-readable tutorial-cove slice and evidence review

- Label: `wayfinder:prototype` (HITL review)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/27
- Status: open
- Blocked by: T005

## What to build

Complete the narrow acceptance scenario: one authored reef break; one deterministic three-wave set; two clients and a dedicated server; the six surf states; one server-validated sidearm with projectile travel and one-metre water cutoff; stamina, wipeout, and recovery; minimal edge-only HUD; dual-channel wave cues; and performance/network evidence.

## Acceptance criteria

- Server owns ocean, movement state, stamina, board/HP, projectiles, hits, and water cutoff.
- HUD uses existing contrast/focus/reduced-motion rules and never reuses the reserved zone hue.
- Critical wave tells have visual and audio placeholder channels.
- Five-minute M4 run at 900p has p95 frame time ≤16.7 ms and no unbounded memory growth.
- RTX 3070 Mobile runbook targets 1080p60 and records evidence when that machine is available.
- The impaired-network acceptance scenario completes without false state transitions.
- macOS artifact and Windows export/build instructions are produced.
- Final review explicitly chooses: retain Godot, run a Unity comparison spike, or revise the slice; no automatic permanent-stack claim.

## Verification-command

```bash
./scripts/verify.sh all
```
