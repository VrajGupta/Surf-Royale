# 013 — Audio as information

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/13
- Status: closed
- Assignee: vraj
- Blocked by: [009 — Weapons & ballistics](009-weapons-and-ballistics.md)

## Question

Audio as a game system: gunshot audibility ranges per weapon (locked to 009's audibility rule), how wave/wind noise masks sound, directional cues above vs. under water, and the audio reads for zone edge, incoming sets, and nearby paddlers. Systems-level spec, not asset lists.

## Decision (2026-07-17)

Gunshot rings sacred (400/600/1000m per #9) — never weather-shrunk; masking hits non-gun sounds only. Underwater: muffled, omnidirectional, event pings only — diving trades intel for cover. Guaranteed ocean tells: zone churn 150m, set rumble 10s pre-break (= #2 drop-in window), paddle splash 40m calm / 20m storm, sprint 60m. Own noise ladder: slow paddle 15m / normal 40m / sprint & re-entry 60m / riding ~25m inside wave noise.
