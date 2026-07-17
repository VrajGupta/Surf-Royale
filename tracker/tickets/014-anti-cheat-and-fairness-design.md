# 014 — Anti-cheat & fairness (design level)

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/14
- Status: closed
- Assignee: vraj
- Blocked by: [002 — Surf movement & ocean physics model](002-surf-movement-and-ocean-physics-model.md), [009 — Weapons & ballistics](009-weapons-and-ballistics.md)

## Question

Design-level fairness (no tech implementation): which systems the GDD must declare authoritative-by-design (ocean state, ballistics, stamina), what per-match determinism/forecast players may know in advance without advantaging cheaters, spectate/report flows, and teaming rules in solos.

## Decision (2026-07-17)

Server-authoritative by design: ocean state, ballistics, stamina/injury — clients render/predict only. Forecast is coarse (trends, not set timings); exact seed server-secret, precision earned via #13 reads. Spectate: killer-cam on ~10s delay + one-tap report with auto clip; no free-cam. Solos teaming: hard-bannable via replay review, plus design pressure (shrinking zone, single-winner rewards, no revive/trade) makes it low-value.
