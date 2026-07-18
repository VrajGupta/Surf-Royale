# T004 — Implement momentum-honest six-state surf controller

- Label: `wayfinder:prototype` (HITL feel review later)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/25
- Status: closed (implemented 2026-07-18)
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

## Implementation (2026-07-18)

Added a pure typed-GDScript controller model with data-driven tuning for paddling, duck-dive, pop-up, riding, wipeout, and treading. Paddling builds over strokes, pop-up is gated by reef-break ocean truth, carving changes direction gradually, impacts trigger wipeout, and recovery returns to paddling. Tests cover the complete state flow, illegal pop-up, low-frame-duration duck recovery, stamina, speed bounds, and malformed non-finite steering.
