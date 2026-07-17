# 010 — Zone & shrink mechanic

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/10
- Status: closed
- Assignee: vraj
- Blocked by: [007 — Match pacing & core loop](007-match-pacing-and-core-loop.md)

## Question

The "safe zone is a moving swell/current" idea made geometrically concrete: what shape is the zone, how does it move (drift path? contracting ring that also translates?), how players read it in-world, and the outside-zone punishment curve — riptide pull strength and hypothermia damage scaling over time, with provisional numbers per shrink phase.

## Decision (2026-07-17)

Translating circle: contracts + drifts with swell each phase, drift path shown one phase ahead. Read: diegetic (turquoise vs grey chop, fog wall, current line) + conventional map/compass ring. Riptide: outward drag 0.5→2.0 m/s across phases 1–4, always swimmable-against when healthy (paddle ~4–6 m/s per #2); tax is stamina, not a wall. Cold: 20s shiver grace per exit, then 3/6/10/15 HP/s by phase.

> Amended (2026-07-16, via #16 GDD assembly): riptide drag redefined as a ratio — always ≤60% of a healthy player's effective paddle speed (was absolute 0.5→2.0 m/s, which conflicted with #2's ~1 m/s paddling). Escapability intent unchanged; per-phase values derive from the ratio.
