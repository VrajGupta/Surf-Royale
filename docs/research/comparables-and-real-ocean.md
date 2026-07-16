# Research — Comparables & real-ocean numbers

Asset for [Comparables & real-ocean research (#3)](https://github.com/VrajGupta/Surf-Royale/issues/3). Anchors the GDD's provisional tuning values. Gathered 2026-07-16.

## Shipped-BR benchmarks

| Game | Players | Map (playable) | Median match | Notes |
|---|---|---|---|---|
| PUBG (Erangel/Miramar) | 100 | 8×8 km | ~25–32 min | Slow zone, projectile ballistics w/ drop & travel time |
| Fortnite | 100 | ~2.2×2.2 km | ~15–25 min | Fast loop, hitscan-heavy legacy, ~15 min average cited |
| Apex Legends | 60 (3-squads) | mid-size | ~15–20 min | 60-player count is the closest comparable to our 50–60 target |
| Naraka: Bladepoint | 60 | mid-size | ~20 min | Proof that non-standard movement (grapple/parkour) carries a BR |

Takeaways: 50–60 players is a shipped, proven count (Apex, Naraka). Median BR sits at **15–25 min**; endgame circles compress minute-by-minute. PUBG is the reference for projectile (non-hitscan) ballistics with drop, travel time, and wind feel.

## Real-ocean movement numbers

- **Paddling (prone, surfboard):** recreational cruise **~0.7–1.3 m/s**; trained sprint **~2 m/s**; cannot be sustained — real paddling is burst + glide.
- **Swimming (no board):** average swimmer ~0.9 m/s; elite ~2 m/s. Always slower than boarded paddling over distance.
- **Wave riding:** typical shortboard on a head-high wave **20–40 km/h (~6–11 m/s)**; big-wave records ~80 km/h. Riding is ~5–10× paddling speed → waves are the "vehicles" of this game.
- **Rip currents:** typically **0.3–0.5 m/s**, strong rips to **2.5 m/s** — faster than an Olympic swimmer, matching the zone's "riptide pulls you out" punishment credibly.

## Cold-water / hypothermia timelines (USCG / NWS)

| Water temp | Cold shock | Exhaustion/unconsciousness | Survival |
|---|---|---|---|
| 10–15.5 °C (50–60 °F) | 1–3 min gasp reflex | 1–2 h | 1–6 h |
| 15.5–21 °C (60–70 °F) | mild | 2–7 h | 2–40 h |
| 21–27 °C (70–80 °F) | none | 3–12 h | 3+ h |

Real hypothermia is far slower than game pacing needs → zone damage should be *inspired* scaling (cold shock → rapid stamina collapse), not literal timelines.

## Design implications for a 50–60 player ocean BR

1. **Map must be small in absolute meters.** PUBG sprint ~6 m/s on 8×8 km; our paddle is ~1 m/s. At wave-riding ~8 m/s for bursts, a **~2×2 km playable field** gives PUBG-like traversal *ratios* only if wave/current travel is the primary mover — reinforcing "reading the ocean = speed" as the core skill.
2. **20–25 min match target** sits in genre norms and suits slower traversal.
3. **Ballistics reference = PUBG-style projectiles** (drop + travel time + wind), never hitscan — already the brief's intent.
4. **Rip/zone numbers have real anchors:** zone pull 0.5–2.5 m/s scaling by phase reads as authentic.
5. **Stamina model:** burst-and-glide paddling (unsustainable sprint) is realistic and mechanically rich — maps directly to the brief's technique-over-mashing goal.

## Sources

- Battle-royale comparisons: pcgamesn.com (PUBG vs Fortnite), esportsdriven.com (Fortnite match length), bestgamingsettings.com (BR comparison)
- Surf speeds: surfertoday.com (surfer speed/distance), boostsurfing.com (paddling), swaylocks.com (wave-speed measurement)
- Rip currents: NOAA (noaa.gov rip currents), science.howstuffworks.com, plymouth.ac.uk rip-current blog
- Cold water: USCG Cold_Water_Survival_Hypothermia.pdf (dco.uscg.mil), NWS cold-water safety, boat-ed.com
