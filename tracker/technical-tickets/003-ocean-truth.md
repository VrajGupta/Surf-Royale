# T003 — Implement deterministic authoritative ocean truth

- Label: `wayfinder:prototype`
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/24
- Status: open
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
