# 019 — Onboarding, tutorial & difficulty ramp

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/20
- Status: closed
- Assignee: @VrajGupta
- Blocked by: —

## Question

Sim depth is now fixed (#2: 6-state machine, forecastable sets, sidearm-only riding, hold-down + leash-snap wipeouts). How does a new player learn wave-reading — dedicated tutorial cove? bot lobbies? in-match forecast HUD training wheels that fade? And what's the difficulty ramp across account levels?

## Decision (2026-07-16)

- **First learn — tutorial cove.** A small authored cove reusing the live wave sim (#2): paddle → read swell tells → pop-up → ride → wipeout recovery, ~5 minutes. One handcrafted level, **no bot AI** — fits the solo-dev constraint. No bot lobbies.
- **In-match assists — fading forecast HUD.** Account levels 1–10 get swell-set countdown, catchable-wave highlight, and rip-current arrows overlaid on the water; each assist fades out as level rises. Veterans read the raw ocean — the skill-gap bet stays intact.
- **Difficulty ramp — sheltered early pool, then open.** Levels 1–10 matchmake preferentially together on calmer weather seeds (no storm variants); afterwards a single open pool. **No ongoing SBMM** — small playerbase + solo-dev backend simplicity.
- **Advanced techniques — community-taught.** Deliberately ship nothing: no death-recap tips, no mastery drills, no challenge track. The sim's depth (#2) is left for the community (video, guides) to teach — v1 scope stays lean. *(Vraj's call, overriding the tips+drills recommendation.)*
