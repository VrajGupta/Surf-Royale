# T006 — Assemble gameplay-readable tutorial-cove slice and evidence review

- Label: `wayfinder:prototype` (HITL review)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/27
- Status: completed 2026-07-18
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

## Completion evidence

- The tutorial cove includes an authored graybox reef, board/surfer, target buoy, edge HUD, and generated visual/audio swell cues.
- The 75-second deterministic three-wave set drives the CPU-queryable ocean and six-state surf controller.
- The impaired ENet harness sends bounded fire intent; the server alone simulates projectiles, applies the one-metre cutoff, records hits, and mutates player/board HP.
- The rendered M4 benchmark completed 300 seconds at 1600×900 with 16.667 ms p95 and 2,043,306 bytes memory growth. Evidence is under `docs/evidence/`.
- The final gate exports `build/macos/SurfRoyale.zip`; Windows x86_64 export and RTX 3070 Mobile reference instructions are in `docs/runbooks/godot-setup.md`.

## Engine review decision

**Retain Godot for the next reversible prototype iteration.** The M4 render budget, deterministic CPU ocean, headless 30 Hz server, impaired two-client correction gate, authoritative sidearm path, and cross-platform export path all passed. This is not a permanent production-stack selection; a comparison spike remains appropriate only if a later slice exposes a concrete Godot limitation.
