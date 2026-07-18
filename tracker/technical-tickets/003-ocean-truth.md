# T003 — Implement deterministic authoritative ocean truth

- Label: `wayfinder:prototype`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/24
- Status: closed (implemented 2026-07-18)
- Blocked by: T002

## What to build

Implement a CPU-queryable ocean-truth layer driven by a server-owned seed. It produces one repeatable three-wave set and exposes height, normal, surface velocity, current, break phase, and underwater queries. Rendering may enrich the result but gameplay cannot depend on GPU readback.

## Acceptance criteria

- Same seed and inputs reproduce the same schedule and bounded query results.
- Headless server computes ocean truth without rendering.
- Exact future timings are not emitted to normal client logs.
- Invalid or missing gameplay data fails fast rather than falling back silently.
- Clear and storm-readable placeholder cues avoid the reserved H 300–320 zone hue.
- Ocean work stays inside the M4 900p60 and RTX 1080p60 slice budgets when integrated with the graybox scene.

## Verification-command

```bash
./scripts/verify.sh ocean
```

## Implementation (2026-07-18)

Added a render-independent, CPU-queryable seeded ocean model with exactly three ordered waves, authored reef influence, height/normal/surface-velocity/current/break-phase samples, and authoritative underwater classification. Tests cover repeatability, seed divergence, schedule-copy isolation, bounded/normalized outputs, underwater behavior, and a 10,000-query M4 headless budget. Visual/audio consumers are intentionally assembled in T006 from these cue values.
