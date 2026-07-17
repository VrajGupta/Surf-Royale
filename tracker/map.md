# Wayfinder Map — Ocean Battle Royale GDD

- Canonical map: [Wayfinder Map — Ocean Battle Royale GDD (#1)](https://github.com/VrajGupta/Surf-Royale/issues/1) · Label: `wayfinder:map`
- Tracker: **GitHub Issues on `VrajGupta/Surf-Royale`**. Tickets are native sub-issues of the map with native blocked-by dependencies; this folder is the on-disk mirror. A ticket is **claimed** by assigning it; the **frontier** is open + unassigned + all blockers closed.
- Note: ticket file `001` maps to issue **#17** (created out of order); files `002`–`016` map to issues `#2`–`#16`.

## Destination

A **buildable-by-others Game Design Document** for Ocean Battle Royale (realistic surf sim + battle royale): every gameplay system specified as unambiguous rules **plus provisional, tunable numbers** (damage, stamina rates, zone timings, loot tables), such that a dev/design team who has never spoken to Vraj could implement it. Includes UI *visual* design, in-world art direction, audio design, and design-level anti-cheat. No engine/tech decisions.

## Notes

- Domain: game design — realistic surf simulation crossed with battle royale. Core bet: *reading the ocean is the skill gap*.
- GDD acceptance test: buildable by a stranger team — rules + provisional numbers, all numbers marked tunable.
- Any ticket touching UI visual design **must consult** `/better-ui`, `/better-typography`, `/better-colors`.
- **UX is owned by Vraj** — interaction flows, screen journeys, control feel. Never decide or simulate it; it arrives via [UX direction handoff (#6)](https://github.com/VrajGupta/Surf-Royale/issues/6).
- HITL tickets resolve via `/grilling` + `/domain-modeling`, one question at a time — never answer the human's side.
- Wayfinder is planning-only here: tickets produce decisions, not game code. Prototypes are throwaway decision aids.

## Decisions so far

<!-- one line per closed ticket: gist + link -->

- [Comparables & real-ocean research (#3)](https://github.com/VrajGupta/Surf-Royale/issues/3) — 50–60 players proven (Apex/Naraka); target 15–25 min matches; paddle ~1 m/s vs ride ~6–11 m/s → waves are the vehicles, map ~2×2 km; rip 0.5–2.5 m/s anchors the zone; PUBG-style projectiles as ballistics reference. Asset: `docs/research/comparables-and-real-ocean.md`.
- [Match format & team modes (#17)](https://github.com/VrajGupta/Surf-Royale/issues/17) — flexible 50–60 lobby (fills to 60, launches 50+; tuned at 60); Solos + Duos (squads post-GDD); no DBNO — once-per-match 'waterlogged' stabilize with permanent injury tier. Graduated fog → [#18](https://github.com/VrajGupta/Surf-Royale/issues/18), [#19](https://github.com/VrajGupta/Surf-Royale/issues/19).
- [Surf movement & ocean physics model (#2)](https://github.com/VrajGupta/Surf-Royale/issues/2) — forecastable swell sets (3–5 waves, 60–90 s apart, seeded, readable tells); 6-state machine (paddle ~1 m/s / duck-dive / pop-up / ride 6–11 m/s / wipeout / tread); sidearm-only while riding; wipeout = 1–4 s hold-down + leash, top-tier waves ~25% leash-snap → board adrift. Graduated fog → [#20](https://github.com/VrajGupta/Surf-Royale/issues/20).

## Not yet specified

- **Full numeric tuning tables** — the GDD's appendix of numbers; graduates per-system as each system's rules close.
- **Per-screen UI visual specs** — can't ticket until the [UX direction handoff (#6)](https://github.com/VrajGupta/Surf-Royale/issues/6) lands; only then does the visual system have surfaces to apply to.
- **Accessibility** — colorblind-safe water/zone reads, audio-cue alternatives; hangs on the audio and UI systems.

## Out of scope

- **Engine / tech stack / netcode / servers** — a later map, after the GDD exists.
- **Monetization economics** — battle-pass pricing, cosmetic pricing, currency design, seasonal pricing cadence. The cosmetic *systems* are in scope; their economics are not (ruled out at charting, 2026-07-16).
- **Marketing / pitch material** — different artifact, different effort.
- **Building the game** — no gameplay code on this map; prototypes only as decision aids.
