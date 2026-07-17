# 008 — Stamina, injury & temperature

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/8
- Status: closed
- Assignee: vraj
- Blocked by: [002 — Surf movement & ocean physics model](002-surf-movement-and-ocean-physics-model.md)

## Question

Provisional numbers and rules for the body sim: stamina drain per activity (paddling, swimming, duck-diving), regen conditions, injury tiers and their exact penalties under the "wounds don't heal mid-match" rule, what bandages actually do, energy-drink/food boost sizes and durations, and water-temperature scaling on drain. Must not create a death-spiral where an injured player can never fight back — name the floor.

## Decision (2026-07-17)

Single stamina bar 0–100: paddle ~2/s, sprint swim ~5/s, duck-dive 8 flat; regen ~4/s board-resting/on land, 1/s treading. Injury: 3 tiers — Bruised (<25% HP lost) no penalty; Wounded (25–60%) -10% paddle, +10% stamina drain; Critical (>60%) -25% paddle + aim sway on water. Floor: combat stats (ADS/fire/swap) never degrade — you can always shoot at 100%. Meds restore HP (bandage +25, kit to full over 6s) but injury tier locks at worst tier hit this match. No consumable boosts — drinks/food cut from loot; temperature is the only stamina modifier (×1.0/×1.2 by map).
