# 012 — Map layout, scale & biomes

- Label: `wayfinder:grilling` (HITL — may spawn a `wayfinder:prototype` for a paper map)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/12
- Status: closed
- Assignee: vraj
- Blocked by: [001 — Match format & team modes](001-match-format-and-team-modes.md), [002 — Surf movement & ocean physics model](002-surf-movement-and-ocean-physics-model.md), [007 — Match pacing & core loop](007-match-pacing-and-core-loop.md)

## Question

Map dimensions for the chosen player count and travel speeds, and the distribution/adjacency of the five biomes (island clusters, reefs, open ocean, shipwrecks, kelp forests): how many of each, their risk/reward gradient, and where waves actually break (surfable zones as terrain). Output likely includes a rough paper-map prototype to react to.

## Decision (2026-07-17)

3×3 km (9 km²): paddle crossing ~10–12 min (impractical), wave-chaining ~4–5 min. Archipelago spine: diagonal island/reef chain — 2 island clusters, 4 reefs, 3 wrecks along it — kelp flanking, open ocean both sides; boat line usually parallels the spine. Risk gradient: depth = value — every biome tiers loot surface/mid/deep (breath-hold dives per #8), wrecks hold the most deep slots. ⚠️ Amends #11's "wrecks hot" phrasing; 70/30 split + front-loaded curve stand. Waves break over reefs/island shores only — fixed named breaks (per #2); open ocean is unbroken swell.
