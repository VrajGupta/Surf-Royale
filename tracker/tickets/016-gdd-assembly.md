# 016 — GDD assembly

- Label: `wayfinder:task` (AFK)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/16
- Status: closed
- Assignee: VrajGupta
- Blocked by: [007](007-match-pacing-and-core-loop.md), [004](004-cosmetic-progression-and-battle-pass-structure.md), [005](005-in-world-art-direction.md), [008](008-stamina-injury-and-temperature.md), [010](010-zone-and-shrink-mechanic.md), [011](011-loot-economy-and-spawn-distribution.md), [012](012-map-layout-scale-and-biomes.md), [013](013-audio-as-information.md), [014](014-anti-cheat-and-fairness-design.md), [015](015-ui-visual-design-system.md)

## Question

Compile every closed decision into the single buildable-by-others GDD: all system rules, all provisional tuning numbers (marked tunable), win condition ("last player alive with a functional board" — verify it survived 001/008 decisions), art/audio/UI direction, and design-level fairness. Resolves when the doc passes the acceptance test: a stranger team could build from it without asking Vraj anything.

## Decision (2026-07-16)

docs/GDD.md written — 14 sections + Appendix A (12 per-system tuning tables, every number marked tunable with source ticket) + Appendix B (assembly flags). Win condition verified: the brief's "last player alive with a functional board" did NOT survive — elimination is HP-only (#2 board loss recoverable, #11 repair kits, #17 waterlogged cling); final: last un-eliminated party wins, board state affects mobility/stealth/survival odds but is never a victory criterion (supersession documented). Two gaps found and resolved at assembly: F1 board integrity = 0–100 chip-damage scale (bullets 5–10, reef/rock 15–25, heavy wipeouts 10, 0 = snap → adrift recoverable, repair +50); F2 riptide drag = ratio ≤60% of healthy paddle speed (reconciles #10 with #2/#3). Acceptance test: a stranger team can build from the doc without asking Vraj — no dangling refs, deferred items explicitly listed.
