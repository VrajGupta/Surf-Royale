# 018 — Social layer: duos comms & pings

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/19
- Status: closed
- Assignee: @VrajGupta
- Blocked by: #13 (audio-as-information)

## Question

Duos-only social spec: ping system (enemy/loot/wave-incoming pings?), voice/text assumptions, party formation, and how comms interact with the audio-as-information system (#13) — do pings leak information waves would mask?

## Decision (2026-07-16)

- **Ping vocabulary — small contextual set + wave ping.** One ping button, context-resolved: enemy-spotted, loot, location, and a Surf-Royale-specific **"wave incoming / take this wave"** ping available on swell tells (#2's readable sets). Apex-school small learnable set; the ocean is part of the comms language.
- **Voice/text — opt-in party VOIP only.** Push-to-talk default; quick-chat lines mapped to the ping set; **no proximity chat and no all-chat at launch**. Keeps the soundscape authored (#13) and the moderation surface small.
- **Party formation — invite + fill toggle.** Friend invites plus a "fill teammate" matchmaking toggle (on by default); no-fill permitted for duo-as-solo challenge runs.
- **Pings vs #13 — line-of-sight only.** You can only ping what your character could currently see/hear; no pinging through waves, fog, or spray. Enemy pings decay in ~4s and do not track targets. Comms amplify your read of the ocean, never bypass it — #13 remains the information author.
