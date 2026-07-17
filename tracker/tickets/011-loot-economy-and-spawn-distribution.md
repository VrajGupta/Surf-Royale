# 011 — Loot economy & spawn distribution

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/11
- Status: closed
- Assignee: vraj
- Blocked by: [001 — Match format & team modes](001-match-format-and-team-modes.md), [009 — Weapons & ballistics](009-weapons-and-ballistics.md)

## Question

The scarcity economy: total ammo budget in the map per weapon type (the brief wants ammo scarcity to force resource wars — how scarce, numerically?), crate contents and distribution across biomes, board-repair item rates, consumable rates, and per-player expected loot at each match phase. Needs player count (001) and weapon list (009).

## Decision (2026-07-17)

Ammo tight: ≈7,000 rounds map-wide (~120/player for 50–60 players) — 2–3 committed fights each. Loot: 70% in named wreck/reef/platform POIs (5–8 crates, biome-flavored tiers), 30% floating debris. Repair kits ~1.5/player, 50% board integrity over 4s stationary; wetsuits tier 1 (-20% dmg) common, tier 2 (-35%) rare crate-only chase item. Curve front-loaded: 80% at spawn, phases 2–4 only add zone-edge drift crates. No food/drink consumables (per #8).

### Amendment (via #12, 2026-07-17)

Depth = value: loot within each POI tiered surface/mid/deep; wrecks hold the most deep slots. 70/30 POI-vs-debris split, tight ammo budget, front-loaded curve unchanged.
