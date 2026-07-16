# 001 — Match format & team modes

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/17
- Status: closed
- Assignee: — (unclaimed)
- Blocked by: —

## Question

How many players per match (the brief floats 50–60), and which team modes ship in the GDD — solos only, or solos/duos/squads? If squads: squad size, whether downed-but-not-out exists (tension with "wounds don't heal"), and lobby fill rules. This decision sizes the map, paces the zone, and gates the death/spectate and social-layer fog.

## Decision (2026-07-16)

Flexible 50–60 lobby — fills to 60, launches at 50+ on queue timeout; all tuning specced at the 60 ceiling. Modes: **Solos + Duos** (squads deferred post-GDD). No classic DBNO: at 0 HP in duos, player is **waterlogged** (clinging to board, drifting, can't fight); teammate can stabilize **once per match** → low HP + permanent injury tier. Solos: 0 HP = eliminated. Graduated fog → #18 (death/spectate flow), #19 (duos comms & pings).
