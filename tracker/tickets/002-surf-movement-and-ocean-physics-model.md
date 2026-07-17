# 002 — Surf movement & ocean physics model

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/2
- Status: closed
- Assignee: — (unclaimed)
- Blocked by: —

## Question

How real is "realistic"? Which ocean variables are truly simulated vs. authored/faked: swell direction & period, wind, tide, local currents. How waves spawn (deterministic sets? per-match forecast?), the full player state machine (prone-paddle / sit / ride / swim / dive / dismount), wipeout causes and recovery, and board durability rules. This is the core bet of the game and the root dependency of combat, stamina, pacing, and map scale.

## Decision (2026-07-17)

Forecastable swell engine: sets of 3–5 waves, 60–90 s between sets, deterministic per-match seed, readable tells (horizon lines, drawback, birds). 6-state machine: Paddling ~1 m/s / Duck-dive (projectile immunity at depth, stamina cost) / Pop-up (vulnerable commit) / Riding 6–11 m/s / Wipeout / Treading. Sidearm-only while riding with turbulence-scaled accuracy penalty. Wipeout: 1–4 s hold-down scaled to wave tier + stamina drain + disorientation; leashed board 2 s remount; top-tier wipeouts ~25% (tunable) leash-snap → board adrift. Chains into injury system (#8). Graduated fog → #20 (onboarding).
