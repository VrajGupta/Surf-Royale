# 017 — Death, spectate & waterlogged flow

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/18
- Status: closed
- Assignee: @VrajGupta
- Blocked by: —

## Question

With Solos+Duos and the waterlogged state locked (#17): what a dead player sees (spectate killer? teammate? free-cam?), what the waterlogged player can do while drifting (signal, paddle weakly, be executed?), stabilize interaction time/risk, and end-of-match flow.

## Decision (2026-07-16)

- **Death view — killer/teammate cam.** Solos: killer POV on the ~10s anti-ghosting delay locked in #14. Duos: live teammate POV (no delay — they're your squad); falls back to delayed killer-cam only when both are dead. Report is always one tap from spectate.
- **Waterlogged agency — weak paddle + signal.** Downed player drifts with the current (the ocean stays the author, per #11), can grab their board to stay afloat, one-armed paddle at ~25% speed, and fire a flare/whistle signal for their teammate. No weapons while waterlogged. Executions allowed (finisher = normal damage, consistent with #9's TTK model — no special execute animation lock).
- **Stabilize — 5s exposed tow.** Teammate paddles over and channels 5s to haul the downed player onto their board. Both are exposed and silhouette-readable at range; damage interrupts. Revived at low HP with drained stamina per #17's tier rules.
- **End-of-match — fast recap → requeue.** Winner gets a brief "claim the peak" beat; everyone else gets a one-screen recap (placement, kills, XP bars, pass-tier ticks) with **Requeue** as the focused default. Serves UX learnability and time-to-wave (#6). No podium ceremony; deep stats deferred to a post-launch profile page, not the match-end path.
