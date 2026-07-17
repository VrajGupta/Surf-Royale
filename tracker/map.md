# Wayfinder Map — Ocean Battle Royale GDD

- Canonical map: [Wayfinder Map — Ocean Battle Royale GDD (#1)](https://github.com/VrajGupta/Surf-Royale/issues/1) · Label: `wayfinder:map`
- Tracker: **GitHub Issues on `VrajGupta/Surf-Royale`**. Tickets are native sub-issues of the map with native blocked-by dependencies; this folder is the on-disk mirror. A ticket is **claimed** by assigning it; the **frontier** is open + unassigned + all blockers closed.
- Note: ticket file `001` maps to issue **#17** (created out of order); files `002`–`016` map to issues `#2`–`#16`.

## Destination

A **buildable-by-others Game Design Document** for Ocean Battle Royale (realistic surf sim + battle royale): every gameplay system specified as unambiguous rules **plus provisional, tunable numbers** (damage, stamina rates, zone timings, loot tables), such that a dev/design team who has never spoken to Vraj could implement it. Includes UI *visual* design, in-world art direction, audio design, and design-level anti-cheat. No engine/tech decisions.

## Constraints (2026-07-16, from Vraj)

- **Solo dev team** (one developer). Every system spec should favor buildable-by-one scope; the 50–60 flexible lobby (#17) over BR-traditional 100 fits this.
- **Hardware:** Alienware m15 R6 (i9-11900H, 32GB DDR4, RTX 3070 Mobile) primary; MacBook Air M4 secondary. Target-hardware ceiling for any perf assumptions in the GDD's provisional numbers.
- **Engine:** Unreal Engine 5 free tier — noted as a constraint only; engine/tech *decisions* remain out of scope for this map.
- **AI tooling budget:** $40/month total (OpenAI Plus — GPT-5.6 Sol/Codex; Anthropic Pro — Claude).
- **Visual style:** semi-photorealism — higher fidelity than Fortnite, less demanding than CoD/Battlefield. Bounds #5 (in-world art direction) and #15 (UI visual design); wave/water rendering ambitions must respect the RTX 3070 Mobile ceiling.

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
- [Death, spectate & waterlogged flow (#18)](https://github.com/VrajGupta/Surf-Royale/issues/18) — Solos: killer-cam on the ~10s anti-ghosting delay; Duos: live teammate POV (delayed killer-cam when both dead); one-tap report. Waterlogged: drift with current, ~25% one-armed paddle, board grab, flare/whistle signal, no weapons, executions = normal damage. Stabilize = 5s exposed tow, damage interrupts, revive at low HP + drained stamina. Match end: one-screen recap, Requeue as focused default; no podium.
- [Social layer: duos comms & pings (#19)](https://github.com/VrajGupta/Surf-Royale/issues/19) — one context-resolved ping button (enemy/loot/location) + 'wave incoming / take this wave' ping on swell tells; opt-in party VOIP only (PTT default, quick-chat mapped to pings, no proximity/all-chat at launch); invite + fill toggle (no-fill allowed); pings are line-of-sight only, enemy pings decay ~4s and don't track — comms never bypass #13.
- [Onboarding, tutorial & difficulty ramp (#20)](https://github.com/VrajGupta/Surf-Royale/issues/20) — tutorial cove reusing the live wave sim (~5 min, no bot lobbies/bot AI — solo-dev fit); fading forecast HUD assists for levels 1–10 (swell countdown, catchable-wave highlight, rip arrows); sheltered early pool levels 1–10 on calm seeds then one open pool, no ongoing SBMM; advanced techniques deliberately community-taught (ship nothing).
- [GDD assembly (#16)](https://github.com/VrajGupta/Surf-Royale/issues/16) — docs/GDD.md: 14 sections + 12 tuning tables (all numbers tunable, source-ticketed); win condition verified HP-only ("functional board" clause dropped, supersession documented); assembly gaps resolved — board integrity 0–100 chip-damage scale, riptide drag as ratio ≤60% of healthy paddle speed.

## Not yet specified

- **Full numeric tuning tables** — the GDD's appendix of numbers; graduates per-system as each system's rules close.
- **Per-screen UI visual specs** — can't ticket until the [UX direction handoff (#6)](https://github.com/VrajGupta/Surf-Royale/issues/6) lands; only then does the visual system have surfaces to apply to.
- **Accessibility** — colorblind-safe water/zone reads, audio-cue alternatives; hangs on the audio and UI systems.

## Out of scope

- **Engine / tech stack / netcode / servers** — a later map, after the GDD exists.
- **Monetization economics** — battle-pass pricing, cosmetic pricing, currency design, seasonal pricing cadence. The cosmetic *systems* are in scope; their economics are not (ruled out at charting, 2026-07-16).
- **Marketing / pitch material** — different artifact, different effort.
- **Building the game** — no gameplay code on this map; prototypes only as decision aids.
