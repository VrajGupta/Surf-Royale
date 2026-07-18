# T004 — Implement momentum-honest six-state surf controller

- Label: `wayfinder:prototype` (HITL feel review later)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/25
- Status: open
- Blocked by: T003

## What to build

Implement typed, data-driven transitions for paddling, duck-dive, pop-up, riding, wipeout, and treading against the ocean-truth interface. Inputs steer forces; paddle speed builds over strokes; carving has visible weight. Keep camera and tuning parameters separable from authoritative movement.

## Acceptance criteria

- Automated tests cover legal and illegal transitions for all six states.
- Paddling, pop-up, riding, wipeout, and recovery can be completed in the tutorial cove.
- A correction cannot create a false wipeout or impossible state transition.
- Tuning values are data-driven and clearly provisional pending user playtest.
- Reduced frame rate and reef-edge contacts do not trap the controller in a state.
- Local input remains visibly responsive within the 60 FPS budgets.

## Verification-command

```bash
./scripts/verify.sh surf
```
