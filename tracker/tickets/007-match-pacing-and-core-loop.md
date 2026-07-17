# 007 — Match pacing & core loop

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/7
- Status: closed
- Assignee: — (unclaimed)
- Blocked by: [001 — Match format & team modes](001-match-format-and-team-modes.md), [002 — Surf movement & ocean physics model](002-surf-movement-and-ocean-physics-model.md)

## Question

Target match length and its tempo phases (drop/loot → rotate → endgame), how the brief's "5–10 min shrink warnings" reconcile with total match length, and the intended minute-by-minute rhythm of a median match. Needs player count (001) and travel speeds (002) to be answerable.

## Decision (2026-07-17)

Swell-chaser boat insertion (per-match visible line, dive off at will). Fast 15-min / 4-phase pacing: drop & scramble 0–2 / mid swell window + zone 1 2–7 / storm swell + tight zone 7–12 / final lineup 12–15; swell intensity ramps with the zone. Start loadout: board + sidearm (pistol + 1 mag) — the only ride-usable weapon class; long guns from caches (#11). Core loop: read boat line → drop → scavenge → read sets → rotate (ride: fast/loud/exposed) vs paddle (slow/quiet/low) → wave-priority fights → final lineup.
