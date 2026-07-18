# Ocean Battle Royale ("Surf Royale") — Game Design Document

**Status:** Final GDD assembled from all closed wayfinder tickets (tracker/map.md + tracker/tickets/001–019).
**Acceptance target:** buildable by a stranger team — every system as unambiguous rules plus provisional numbers, all numbers marked **(tunable)** — without asking Vraj anything.
**Scope exclusions (ruled out at charting, 2026-07-16):** engine/tech stack/netcode/servers (a later map), monetization economics (pricing, currency; cosmetic *systems* are in scope), marketing/pitch material, gameplay code.
**Traceability:** every section header cites its source ticket file numbers. Ticket file `001` maps to GitHub issue #17; files `002`–`016` map to issues #2–#16; `017`→#18, `018`→#19, `019`→#20. In-ticket cross-references like "(per #8)" use issue numbers.

---

## 1. Vision & pillars (source: map.md, tickets 003, 004)

**One line:** A realistic surf simulation crossed with a battle royale. **Core bet: reading the ocean is the skill gap.**

**Pillars**
1. **The ocean is the author.** Swell, waves, currents and weather are simulated, forecastable systems — waves are the vehicles, the cover, the clock and the comms channel.
2. **Positioning beats tracking.** Fast time-to-kill, hard audio rings, and depth-as-cover make information and position the dominant skills, not raw aim (§6, §8).
3. **Buildable by one developer.** Every system favors solo-dev scope: 50–60 players instead of BR-traditional 100, no bot AI, one handcrafted tutorial cove, no ongoing SBMM.
4. **No pay-to-win, provably.** Cosmetics-only progression enforced as *testable acceptance checks*, not principles (§10).

**Production constraints (map.md, 2026-07-16, from Vraj)**
- Solo dev team (one developer).
- Original hardware ceiling for design assumptions: Alienware m15 R6 (i9-11900H, 32GB DDR4, RTX 3070 Mobile) primary; MacBook Air M4 secondary. **Current technical phase (2026-07-18):** M4 MacBook Air is the primary development machine; RTX 3070 Mobile remains the Windows performance reference.
- Historical engine note: Unreal Engine 5 free tier was recorded during GDD charting, but engine decisions were out of this document's scope. **Superseded 2026-07-18:** the technical phase excludes UE5 and uses Godot 4 for a reversible risk prototype; see `tracker/technical-map.md`.
- Visual style bound: semi-photorealism — higher fidelity than Fortnite, less demanding than CoD/Battlefield; wave/water rendering must respect the RTX 3070 Mobile ceiling.

**Research anchors (ticket 003; asset: `docs/research/comparables-and-real-ocean.md`)**
- 50–60 player lobbies proven viable (Apex, Naraka).
- Target match length envelope from comparables: 15–25 min (the pacing decision in §3 lands at the fast end: 15 min).
- Paddle ~1 m/s vs ride ~6–11 m/s → waves are the vehicles. (Research suggested a ~2×2 km map; **superseded** by ticket 012's decided 3×3 km, §5.)
- Riptide 0.5–2.5 m/s real-world range anchors the zone punishment (§5).
- PUBG-style projectiles as the ballistics reference (§6).

---

## 2. Match format & team modes (source: tickets 001, 018)

### 2.1 Lobby & modes (001)
- **Flexible 50–60 player lobby:** fills to 60, launches at 50+ on queue timeout. **All tuning in this document is specced at the 60-player ceiling.**
- **Modes at launch: Solos + Duos.** Squads — *deliberately deferred: post-GDD (ticket 001)*.
- **No classic DBNO.**
  - **Solos:** reaching 0 HP = eliminated.
  - **Duos:** at 0 HP the player becomes **waterlogged** — clinging to their board, drifting, cannot fight (full state rules in §3.2). A teammate can **stabilize once per match**, reviving them at low HP **plus a permanent injury tier** (§7).

### 2.2 Social layer — Duos comms & pings (018)
- **Ping vocabulary:** one ping button, context-resolved — enemy-spotted / loot / location — plus the Surf-Royale-specific **"wave incoming / take this wave"** ping, available on swell tells (§4 readable sets). Apex-school small learnable set; the ocean is part of the comms language.
- **Voice/text:** opt-in **party VOIP only**, push-to-talk default; quick-chat lines mapped to the ping set; **no proximity chat and no all-chat at launch** (keeps the soundscape authored per §8 and the moderation surface small).
- **Party formation:** friend invites + a "fill teammate" matchmaking toggle (on by default); no-fill permitted for duo-as-solo challenge runs.
- **Pings never bypass audio design (013):** line-of-sight only — you can only ping what your character could currently see/hear; no pinging through waves, fog, or spray. Enemy pings decay in ~4 s (tunable) and do not track targets.

---

## 3. Core loop, match pacing & death flow (source: tickets 007, 017)

### 3.1 Pacing & core loop (007)
- **Insertion:** swell-chaser boat — a per-match visible boat line; players dive off at will. The boat line usually parallels the archipelago spine (§5).
- **Match length: 15 minutes, 4 phases** (all timings tunable):

| Phase | Minutes | Beat |
|---|---|---|
| 1 — Drop & scramble | 0–2 | Boat drops, spawn loot grab |
| 2 — Mid swell window + zone 1 | 2–7 | First rotations, first fights |
| 3 — Storm swell + tight zone | 7–12 | Weather ramps, forced rotations |
| 4 — Final lineup | 12–15 | Endgame at the last break |

- **Swell intensity ramps with the zone** — weather/mood is the match clock (§11).
- **Start loadout:** board + sidearm (pistol + 1 mag). The sidearm is **the only ride-usable weapon class**; long guns come from caches (§6, loot §6.2).
- **Core loop:** read boat line → drop → scavenge → read sets → rotate — **ride** (fast / loud / exposed) vs **paddle** (slow / quiet / low) → wave-priority fights → final lineup.

### 3.2 Death, spectate & waterlogged flow (017)
- **Death view — killer/teammate cam.**
  - Solos: killer POV on the ~10 s anti-ghosting delay (locked in ticket 014).
  - Duos: **live** teammate POV (no delay — they're your squad); falls back to delayed killer-cam only when both are dead.
  - Report is always one tap from spectate. No free-cam (014).
- **Waterlogged agency — weak paddle + signal.** The downed (0 HP, Duos) player: drifts with the current (the ocean stays the author), can grab their board to stay afloat, one-armed paddles at ~25% speed (tunable), and can fire a flare/whistle signal for their teammate. **No weapons while waterlogged.** Executions allowed: a finisher deals normal damage — consistent with the TTK model (§6) — no special execute animation lock.
- **Stabilize — 5 s exposed tow (tunable).** The teammate paddles over and channels 5 s to haul the downed player onto their board. Both are exposed and silhouette-readable at range; **damage interrupts.** Revived at low HP with drained stamina, and the permanent injury tier applies per ticket 001 / §7.
- **End-of-match — fast recap → requeue.** Winner gets a brief "claim the peak" beat; everyone else gets a one-screen recap (placement, kills, XP bars, pass-tier ticks) with **Requeue** as the focused default. No podium ceremony. Deep stats — *deliberately deferred: post-launch profile page, kept off the match-end path for time-to-wave (tickets 017, 006)*.

---

## 4. Surf movement & ocean physics (source: tickets 002, 003)

### 4.1 Swell engine (002)
- **Forecastable swell engine:** waves arrive in **sets of 3–5**, **60–90 s between sets** (tunable), **deterministic per-match seed**, with readable tells: horizon lines, drawback, birds.
- Forecast exposure to players is deliberately **coarse** — trends, not set timings; the exact seed is server-secret (fairness, §12). Precision is earned by reading the ocean and its audio tells (§8).
- Waves break **only** over reefs and island shores — fixed named breaks (§5); open ocean is unbroken swell.

### 4.2 Player state machine (002)
Six states:

| State | Rules |
|---|---|
| **Paddling** | prone on board, ~1 m/s (tunable) |
| **Duck-dive** | projectile immunity at depth (bullets die 1 m into water, §6); stamina cost (8 flat, §7) |
| **Pop-up** | the vulnerable commit moment |
| **Riding** | 6–11 m/s (tunable); **sidearm-only**, with a turbulence-scaled accuracy penalty |
| **Wipeout** | 1–4 s hold-down scaled to wave tier + stamina drain + disorientation |
| **Treading** | in-water, slow; worst stamina regen (§7) |

- **Board & leash:** after a wipeout the leashed board allows a 2 s remount (tunable). **Top-tier wave wipeouts have ~25% (tunable) leash-snap chance → board adrift.**
- Wipeouts chain into the injury system (§7).

### 4.3 Board integrity
- Boards carry an integrity stat on a **0–100 scale** (decided at assembly, ticket 016; resolves note F1). Damage sources (all tunable): **bullets 5–10 per hit**, **reef/rock impacts 15–25**, **heavy wipeouts 10**. At **0 integrity the board snaps** — the player is adrift/swimming, fully recoverable per the leash-snap rules (§4, ticket 002).
- Repair kits restore **+50 integrity (of 100) over 4 s stationary** (ticket 011, §6.2). Board loss (leash-snap) and damage affect mobility and survival odds only — **never victory eligibility** (§13).

---

## 5. Map, biomes, zone & shrink (source: tickets 012, 010)

### 5.1 Map layout & scale (012)
- **3×3 km (9 km²).** Paddle crossing ~10–12 min (deliberately impractical); wave-chaining crossing ~4–5 min.
- **Archipelago spine:** a diagonal island/reef chain — **2 island clusters, 4 reefs, 3 wrecks** along it — **kelp forests flanking**, open ocean on both sides. The insertion boat line usually parallels the spine.
- **Risk gradient — depth = value:** every biome tiers its loot surface/mid/deep (breath-hold dives per §7 stamina rules); **wrecks hold the most deep slots**. (This amends ticket 011's "wrecks hot" phrasing; 011's 70/30 split and front-loaded curve stand, §6.2.)
- **Surfable zones as terrain:** waves break over reefs/island shores only — fixed named breaks; open ocean is unbroken swell.

### 5.2 Zone & shrink mechanic (010)
- **Shape/motion:** a **translating circle** — each phase it **contracts and drifts with the swell**; the drift path is shown **one phase ahead**.
- **In-world reads (diegetic):** turquoise-vs-grey chop, fog wall, current line — plus conventional map + compass ring.
- **Outside-zone punishment — stamina tax, not a wall:**
  - **Riptide:** outward drag is defined as a **ratio, not an absolute: ≤60% of a healthy player's effective paddle speed** at every phase (per-phase drag scales up toward that cap across phases 1–4; all tunable). This preserves 002/003's realistic ~1 m/s paddling AND 010's binding rule — **always swimmable-against when healthy** — whatever paddle speed is later tuned to. (Decided at assembly, ticket 016; resolves note F2.)
  - **Cold:** per zone-exit, a 20 s shiver grace period, then damage of **3 / 6 / 10 / 15 HP/s by phase 1–4** (tunable).

---

## 6. Combat: weapons, ballistics & loot economy (source: tickets 009, 011)

### 6.1 Weapons & ballistics (009)
**Fast TTK — 2 shots downs an unarmored player; positioning beats tracking.**

| Weapon | Damage | Effective range | Audibility ring |
|---|---|---|---|
| Pistol (sidearm; only ride-usable class) | 30 | 30 m | 400 m |
| Shotgun | 12×8 pellets | 10 m | 600 m |
| Rifle | 55 | 200 m | 1000 m |

(All values tunable.)

- **Ballistics:** gravity arc (PUBG-style reference, ticket 003); **bullets die 1 m into water** — duck-dive is hard cover. **Wind is visual-only** (no trajectory effect).
- **Weapon sway formula:** `sway = base × (1 + v/vmax) × stance_mult`
  - Stance multipliers: prone-on-board **0.8**, sitting **1.0**, standing-riding **2.5**, treading **1.6** (tunable).
- **Attachments (recoil/aim modifiers only):** grip −30% sway; scope +zoom, +10% sway; laser −20% hipfire spread (tunable).
- **Audibility is a hard mechanic:** gunshots broadcast at the hard rings above, **always directional**, and are **never weather-shrunk** (§8).

### 6.2 Loot economy & spawn distribution (011, amended via 012)
- **Ammo is tight:** ≈**7,000 rounds map-wide** (~120/player at 50–60 players) — budget for **2–3 committed fights each** (tunable).
- **Distribution:** **70% in named wreck/reef/platform POIs** (5–8 crates each, biome-flavored tiers), **30% floating debris**.
- **Depth = value (amendment via 012):** within each POI, loot is tiered surface/mid/deep; wrecks hold the most deep slots. The 70/30 split, tight ammo budget, and front-loaded curve are unchanged by the amendment.
- **Curve is front-loaded:** **80% of loot present at spawn**; phases 2–4 only add **zone-edge drift crates**.
- **Repair kits:** ~1.5 per player (tunable); restore **50% board integrity over 4 s stationary**.
- **Wetsuits (armor):** tier 1 (−20% damage) common; tier 2 (−35%) rare, **crate-only chase item** (tunable).
- **No food/drink consumables** (consistent with §7: no consumable stamina boosts).

---

## 7. Survival systems: stamina, injury & temperature (source: ticket 008)

- **Single stamina bar 0–100.**
  - Drain: paddle ~2/s; sprint swim ~5/s; duck-dive 8 flat (tunable).
  - Regen: ~4/s while board-resting or on land; 1/s treading (tunable).
- **Injury — "wounds don't heal mid-match":** three tiers, keyed to HP lost in a single hit-episode:

| Tier | Trigger | Penalty |
|---|---|---|
| Bruised | <25% HP lost | none |
| Wounded | 25–60% | −10% paddle speed, +10% stamina drain |
| Critical | >60% | −25% paddle speed + aim sway while on water |

- **The floor (no death-spiral):** combat stats — ADS, fire, weapon swap — **never degrade. You can always shoot at 100%.** Injury taxes mobility and endurance only.
- **Meds restore HP, not injury:** bandage +25 HP; med-kit to full over 6 s (tunable). **Injury tier locks at the worst tier hit this match** (this is the "permanent injury tier" applied by a Duos stabilize, §2.1/§3.2).
- **No consumable boosts:** energy drinks/food are cut from loot entirely.
- **Temperature is the only stamina modifier:** map/weather variant scales stamina drain **×1.0 / ×1.2** (tunable).

---

## 8. Audio as information (source: ticket 013)

Audio is a game system, not ambience. Systems-level rules:

- **Gunshot rings are sacred:** pistol 400 m / shotgun 600 m / rifle 1000 m (per §6.1) — **never weather-shrunk**; weather masking applies to **non-gun sounds only**. Always directional.
- **Underwater:** muffled, omnidirectional, event pings only — **diving trades intel for cover** (pairs with duck-dive projectile immunity, §4.2).
- **Guaranteed ocean tells** (tunable ranges):
  - Zone churn audible at 150 m.
  - Set rumble 10 s pre-break — this **is** the drop-in window (equals ticket 002's readable-set timing).
  - Paddle splash: 40 m in calm / 20 m in storm.
  - Sprint swim: 60 m.
- **Own-noise ladder** (what you broadcast, tunable): slow paddle 15 m / normal paddle 40 m / sprint & wave re-entry 60 m / riding ~25 m (buried inside wave noise).

---

## 9. Onboarding, tutorial & difficulty ramp (source: ticket 019)

- **First learn — tutorial cove:** a small authored cove reusing the **live wave sim** (§4): paddle → read swell tells → pop-up → ride → wipeout recovery; ~5 minutes. One handcrafted level, **no bot AI, no bot lobbies** (solo-dev constraint).
- **In-match assists — fading forecast HUD:** account levels 1–10 get swell-set countdown, catchable-wave highlight, and rip-current arrows overlaid on the water; **each assist fades out as level rises**. Veterans read the raw ocean — the skill-gap bet stays intact.
- **Difficulty ramp:** levels 1–10 matchmake preferentially together on **calmer weather seeds** (no storm variants); afterwards a **single open pool**. **No ongoing SBMM** (small playerbase + solo-dev backend simplicity).
- **Advanced techniques — *deliberately deferred: community-taught (Vraj's call, overriding the tips+drills recommendation; v1 scope stays lean)*.** Ship nothing: no death-recap tips, no mastery drills, no challenge track; the sim's depth is left to community video/guides.

---

## 10. Progression: cosmetics, battle pass & account levels (source: ticket 004)

*Structure only — pricing/currency/economics are out of scope (map.md).*

- **Launch cosmetic categories — base 3 only:** gun skins, board designs, wetsuit skins.
- **Account levels:** a cosmetic item **every level**; signature cosmetics at milestones **10 / 25 / 50 / 100**. Level XP comes from **match performance only**.
- **Battle pass:** **50 tiers**; XP from time played + placement + kills + **surf challenges**; **casual-completable at ~4 matches/day** (tunable).
- **Seasons:** ~10 weeks (tunable), map/weather themed.
- **No-P2W as a testable triad (acceptance checks, not principles):**
  1. Visibility tolerance band: no cosmetic may change player visibility beyond the band at 50 m+ (e.g. wetsuit color may not affect visibility in water).
  2. Identical hitboxes across all cosmetics.
  3. Zero audio deltas across all cosmetics.

---

## 11. Art direction, UX direction & UI visual system (source: tickets 005, 006, 015)

### 11.1 In-world art direction (005)
- **Style: stylized-realistic** — physics-readable water, pushed saturation, "Uncharted-ocean school". Within the map constraint: semi-photorealism between Fortnite and CoD/Battlefield, respecting the RTX 3070 Mobile ceiling.
- **Mood is dynamic and is the match clock:** sun-bleached open → storm-grey endgame, synced to zone/weather phases (§3.1, §5.2).
- **Reference spine (game-first):** Sea of Thieves wave silhouettes; Uncharted 4 water lighting; Riders Republic energy.
- **Four contractual readability rules (art must obey):**
  1. Swell silhouettes readable at 300 m+.
  2. A reserved zone-edge hue (locked at UI token level, §11.3).
  3. Distinct hazard palette + texture break for kelp/reef danger.
  4. Water clarity never drops below gameplay-legible in any weather.

### 11.2 UX direction (006 — handed off by Vraj, 2026-07-17)
- **Control feel: momentum-honest.** Inputs steer forces; carving has weight; paddling builds over strokes.
- **Screen journeys: hybrid.** Diegetic paddle-out lobby for queue/warm-up; conventional full-screens for store/pass/locker.
- **HUD: toggleable density.** Diegetic-first default — stamina ring, on-weapon ammo, compass strip; the world carries the rest (zone reads §5.2, audio §8) — plus an opt-in comp-HUD preset.
- **Priority under tradeoffs: learnability.** A new player's first 10 matches win all design conflicts.

### 11.3 UI visual design system (015)
Full spec: [`design/ui-visual-system.md`](../design/ui-visual-system.md) · rough visual prototype: [`design/ui-prototype.html`](../design/ui-prototype.html). Summary:

- **Color:** OKLCH ocean-derived tokens — constant-hue neutral ramp at H≈230, turquoise "surf" primary + sunset-coral accent; **zone hue 300–320 is reserved at token level** (no other UI/VFX may use it — enforces art rule 2). Light theme derived from dark by L reversal, never hand-picked.
- **Acceptance checks:** APCA body text |Lc| ≥ 75, UI/non-body |Lc| ≥ 60 (fix failures by adjusting L only); any token within ±15° of the zone hue fails review.
- **Type:** one variable grotesk (weight axis = hierarchy) + one mono; 1.25 modular scale from a fluid 16–18px base; **tabular numerals mandatory in HUD**.
- **Interaction contract on every element:** hover/active/visible-focus, ≥44×44px targets, 0.96 press scale, 150–250 ms transform/opacity transitions, `prefers-reduced-motion` support.
- **Two surfaces, one token set:** **glass** HUD (translucent, screen-edge-only per the HUD-last rule) and **solid** menus/pass/locker; dark-mode-first.

---

## 12. Fairness & anti-cheat (design level) (source: ticket 014)

*Design-level only; tech implementation is out of scope.*

- **Server-authoritative by design:** ocean state, ballistics, stamina/injury. Clients render and predict only.
- **Determinism exposure:** the per-match forecast shown to players is **coarse** (trends, not set timings); the exact swell seed is **server-secret**. Precision is earned via audio/visual reads (§8), never data-minable.
- **Spectate/report:** killer-cam on ~10 s delay (anti-ghosting) + one-tap report with **auto-attached clip**; **no free-cam**.
- **Teaming in Solos:** hard-bannable via replay review, plus design pressure makes it low-value — shrinking zone, single-winner rewards, no revive/trade in Solos.

---

## 13. Win condition & victory (verified; source: tickets 001, 008, 002, 011, 017)

**Win condition (final):** A match ends when exactly one party remains un-eliminated. In **Solos**, the winner is the last player whose HP has not reached 0 (0 HP = eliminated, ticket 001). In **Duos**, the winner is the last team with at least one member not eliminated; a **waterlogged** member (0 HP, clinging to their board) is *not yet* eliminated and keeps the team alive until killed. **Elimination is by hit points only. Board possession and board integrity affect mobility, stealth, and survival odds — they are never a victory or elimination criterion.**

**Verification note (required by ticket 016):** the brief's original phrasing — *"last player alive with a functional board"* — did **not** survive the closed decisions, and the "functional board" clause is hereby dropped:
- Ticket 001 defines elimination purely by HP (Solos 0 HP = eliminated; Duos 0 HP = waterlogged).
- Ticket 002 makes board loss a recoverable game state (leash-snap → board adrift), not an elimination.
- Ticket 011 provides repair kits for damaged boards; ticket 017 lets even a waterlogged player grab their board.
No decision ever conditions victory on the board. A board-less player is severely handicapped (swim/tread speeds, stamina regen §7) but remains win-eligible.

Victory presentation: the winner's "claim the peak" beat, then recap → Requeue (§3.2).

---

## 14. Appendix A — Tuning tables

**Every numeric value below is provisional and marked tunable (map.md: "all numbers marked tunable").** Rows cite their source ticket.

### A.1 Match format (001)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Lobby size | 50–60 (fills to 60; launches 50+ on queue timeout) | tunable | 001 |
| Tuning ceiling | all specs at 60 players | tunable | 001 |
| Duos stabilize uses | once per match | tunable | 001 |

### A.2 Ocean & movement (002)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Wave set size | 3–5 waves | tunable | 002 |
| Between-set interval | 60–90 s | tunable | 002 |
| Paddle speed | ~1 m/s | tunable | 002 (note F2 — resolved via riptide ratio rule) |
| Ride speed | 6–11 m/s | tunable | 002 |
| Wipeout hold-down | 1–4 s (scaled to wave tier) | tunable | 002 |
| Leashed remount time | 2 s | tunable | 002 |
| Top-tier leash-snap chance | ~25% | tunable (flagged in ticket) | 002 |

### A.3 Pacing (007)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Match length | 15 min | tunable | 007 |
| Phase boundaries | 0–2 / 2–7 / 7–12 / 12–15 min | tunable | 007 |
| Start loadout | board + pistol + 1 mag | tunable | 007 |

### A.4 Zone (010)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Riptide outward drag, phases 1–4 | ratio: ≤60% of healthy paddle speed, scaling toward the cap by phase | tunable within the ratio cap | 010 + 016 (note F2 resolved) |
| Cold grace per zone exit | 20 s shiver | tunable | 010 |
| Cold damage by phase 1–4 | 3 / 6 / 10 / 15 HP/s | tunable | 010 |

### A.5 Combat (009)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Pistol dmg / range / ring | 30 / 30 m / 400 m | tunable | 009 |
| Shotgun dmg / range / ring | 12×8 / 10 m / 600 m | tunable | 009 |
| Rifle dmg / range / ring | 55 / 200 m / 1000 m | tunable | 009 |
| Water bullet-kill depth | 1 m | tunable | 009 |
| Sway stance multipliers | prone 0.8 / sit 1.0 / ride 2.5 / tread 1.6 | tunable | 009 |
| Grip / scope / laser | −30% sway / +zoom +10% sway / −20% hipfire | tunable | 009 |

### A.6 Loot (011, amended 012)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Map-wide ammo budget | ≈7,000 rounds (~120/player) | tunable | 011 |
| POI vs debris split | 70% / 30% | tunable | 011 (stands per 012) |
| Crates per POI | 5–8 | tunable | 011 |
| Loot at spawn | 80% (phases 2–4: zone-edge drift crates only) | tunable | 011 |
| Repair kits | ~1.5/player; +50 integrity (of 100) over 4 s stationary | tunable | 011 |
| Board integrity damage: bullets / reef-rock / heavy wipeout | 5–10 / 15–25 / 10 (0–100 scale; 0 = board snaps → adrift, recoverable) | tunable | 016 (note F1 resolved) |
| Wetsuit tiers | T1 −20% dmg common / T2 −35% rare crate-only | tunable | 011 |
| POI depth tiering | surface/mid/deep; wrecks most deep slots | rule (amendment) | 012 |

### A.7 Survival (008)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Stamina bar | 0–100 | tunable | 008 |
| Drain: paddle / sprint swim / duck-dive | ~2/s / ~5/s / 8 flat | tunable | 008 |
| Regen: board-rest or land / tread | ~4/s / 1/s | tunable | 008 |
| Injury tiers | Bruised <25% / Wounded 25–60% / Critical >60% HP lost | tunable | 008 |
| Wounded penalty | −10% paddle, +10% stamina drain | tunable | 008 |
| Critical penalty | −25% paddle + on-water aim sway | tunable | 008 |
| Bandage / med-kit | +25 HP / full over 6 s | tunable | 008 |
| Temperature stamina scale | ×1.0 / ×1.2 by map | tunable | 008 |

### A.8 Map (012)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Map size | 3×3 km (9 km²) | tunable | 012 (supersedes 003's ~2×2 km research figure) |
| Paddle crossing / wave-chain crossing | ~10–12 min / ~4–5 min | derived, tunable | 012 |
| POI counts on spine | 2 island clusters, 4 reefs, 3 wrecks | tunable | 012 |

### A.9 Audio (013)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Zone churn audible | 150 m | tunable | 013 |
| Set rumble pre-break | 10 s (= drop-in window) | tunable | 013 |
| Paddle splash calm / storm | 40 m / 20 m | tunable | 013 |
| Sprint swim audible | 60 m | tunable | 013 |
| Own-noise ladder | slow 15 m / normal 40 m / sprint & re-entry 60 m / riding ~25 m | tunable | 013 |

### A.10 Death & spectate (017, 014)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Killer-cam delay | ~10 s | tunable | 014, 017 |
| Waterlogged paddle speed | ~25% of normal | tunable | 017 |
| Stabilize channel | 5 s, damage interrupts | tunable | 017 |
| Enemy ping decay | ~4 s | tunable | 018 |

### A.11 Onboarding & progression (019, 004)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Tutorial cove length | ~5 min | tunable | 019 |
| Assist / sheltered-pool band | account levels 1–10 | tunable | 019 |
| Account milestones | 10 / 25 / 50 / 100 | tunable | 004 |
| Battle pass tiers | 50; casual-completable ~4 matches/day | tunable | 004 |
| Season length | ~10 weeks | tunable | 004 |
| Cosmetic visibility check | tolerance band at 50 m+ | tunable | 004 |

### A.12 UI (015)
| Parameter | Value | Status | Source |
|---|---|---|---|
| Neutral hue / zone hue | H≈230 / reserved 300–320 | tunable within APCA checks | 015 |
| Contrast | APCA Lc ≥ 75 body / ≥ 60 UI | acceptance check | 015 |
| Type scale / base | 1.25 / fluid 16–18px | tunable | 015 |
| Targets / press / transitions | ≥44px / 0.96 scale / 150–250 ms | tunable | 015 |

---

## Appendix B — Assembly notes (flags found while compiling)

- **F1 — Board integrity scale — RESOLVED (2026-07-16, ticket 016).** Ticket 011 introduced repair kits that "restore 50% board integrity" without a defined scale. Resolution: **0–100 integrity scale**; damage sources — bullets 5–10 per hit, reef/rock impacts 15–25, heavy wipeouts 10 (all tunable); at **0 the board snaps** and the player is adrift/swimming (recoverable per 002); repair kit = +50 of 100. Specced in §4.3 and Appendix A. Does **not** affect the win condition (§13).
- **F2 — Paddle-speed discrepancy (010 vs 002) — RESOLVED (2026-07-16, ticket 016).** Ticket 010 justified "always swimmable-against when healthy" citing "paddle ~4–6 m/s per #2", but ticket 002 (and the 003 research) specify paddling at ~1 m/s. Resolution: riptide drag is a **ratio, not an absolute — always ≤60% of a healthy player's effective paddle speed**, whatever paddling is later tuned to. 002/003's realism figures and 010's escapability intent both stand; per-phase drag values in §5 derive from the ratio. Specced in §5.2 and Appendix A.
- **Deliberately deferred (with reasons), collected:** Squads mode (001 — post-GDD); advanced-technique teaching (019 — community-taught, Vraj's call, v1 scope); deep post-match stats (017 — post-launch profile page, keeps match-end path fast); accessibility pass (map.md "Not yet specified" — hangs on audio + UI systems); engine/tech/netcode, monetization economics, marketing (map.md — out of scope for this map).
