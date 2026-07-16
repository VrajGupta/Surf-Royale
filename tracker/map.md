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

*(none yet — map just charted, 2026-07-16)*

## Not yet specified

- **Death & spectate experience, squad revives** — down/revive rules, spectate flow, what a dead player sees; hangs on [Match format & team modes (#17)](https://github.com/VrajGupta/Surf-Royale/issues/17).
- **Onboarding / tutorial & difficulty ramp** — how a new player learns wave-reading; can't size it until [Surf movement & ocean physics model (#2)](https://github.com/VrajGupta/Surf-Royale/issues/2) fixes how deep the sim goes.
- **Social layer** — parties, comms, pings; hangs on team modes.
- **Full numeric tuning tables** — the GDD's appendix of numbers; graduates per-system as each system's rules close.
- **Per-screen UI visual specs** — can't ticket until the [UX direction handoff (#6)](https://github.com/VrajGupta/Surf-Royale/issues/6) lands; only then does the visual system have surfaces to apply to.
- **Accessibility** — colorblind-safe water/zone reads, audio-cue alternatives; hangs on the audio and UI systems.

## Out of scope

- **Engine / tech stack / netcode / servers** — a later map, after the GDD exists.
- **Monetization economics** — battle-pass pricing, cosmetic pricing, currency design, seasonal pricing cadence. The cosmetic *systems* are in scope; their economics are not (ruled out at charting, 2026-07-16).
- **Marketing / pitch material** — different artifact, different effort.
- **Building the game** — no gameplay code on this map; prototypes only as decision aids.
