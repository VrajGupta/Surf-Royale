# Specification — Godot 4 Networked Tutorial-Cove Risk Slice

**Status:** Ready for implementation  
**Date:** 2026-07-18  
**Source:** `docs/GDD.md`, `docs/technical/00-technical-brief.md`, UX handoff ticket 006, fairness ticket 014.

## Goal

Build the smallest runnable prototype that tests Surf Royale's core claim: reading deterministic waves creates the movement and combat skill gap. This is a technical risk slice, not production game code and not a miniature battle royale.

## Included

- One compact authored tutorial cove with a reef break.
- One deterministic, server-seeded set of exactly three waves with readable approach cues.
- Ocean truth queries for height, normal, surface velocity, current, break phase, and underwater state.
- Six player states: paddling, duck-dive, pop-up, riding, wipeout, and treading.
- Momentum-honest inputs: controls steer forces; paddling builds over strokes; carving has weight.
- Two clients connected to one headless authoritative server over ENet.
- One sidearm interaction, projectile travel, and the GDD's one-metre water cutoff.
- Stamina, wipeout, recovery, and minimal board state needed by the slice.
- Minimal edge-only HUD and simple visual/audio swell tells using existing UI/readability rules.
- macOS and Windows client export instructions and a local headless-server runbook.

## Excluded

- 50–60 live players, matchmaking, accounts, persistence, progression, store/pass/locker, production backend, VOIP, production anti-cheat vendor, full map, full loot economy, final art, or launch hosting.
- UE5 and every Unreal-specific artifact.
- Any claim that Godot is the final production engine before the integrated evidence review.

## Invariants

### Performance

- M4 MacBook Air: 1600×900 internal resolution, 60 FPS target; five-minute representative run must keep p95 frame time at or below 16.7 ms and exhibit no unbounded memory growth.
- RTX 3070 Mobile: 1920×1080, 60 FPS target under the same scenario.
- Headless server: fixed 30 Hz simulation target with no rendering dependency; missed-tick rate below 1% during the two-client soak.
- Ocean gameplay queries never wait on GPU readback.

### Network and correction

- Playable at 100 ms RTT and 2% packet loss.
- Local input is predicted; server state is authoritative.
- Position correction p95 must remain at or below 0.5 m during normal paddling/riding and must not cause false state transitions.
- A seed or state mismatch is surfaced as a deterministic test failure, never silently accepted.

### Failure behavior

- If the local server is unavailable, connection times out within five seconds, shows a clear error, and returns to the launch screen without hanging.
- If a client receives malformed or impossible state, it discards the update and logs a bounded diagnostic; it never applies client-authored damage or movement truth.
- No production backend is required. The slice uses direct local/LAN connection only, so external service failure cannot block local verification.
- Missing optional audio or presentation assets degrade to explicit placeholders; missing gameplay data fails fast.

### Security and trust

- The server owns the exact ocean seed/schedule, authoritative transform/state, stamina, board/HP values, projectiles, hits, and water-cutoff checks.
- Clients send timestamped input intent only; client positions, damage, inventory, and wave claims are never trusted.
- No secrets, personal data, telemetry, remote code download, or third-party account tokens are introduced.
- Logs must not expose future server-secret wave timing to normal client output.

### UX and accessibility

- Control feel remains user-owned; parameters are data-driven and presented for later playtest sign-off.
- Zone hue H 300–320 remains reserved and unused by prototype ocean/HUD effects.
- HUD text meets the existing APCA targets; controls retain visible focus and reduced-motion behavior where applicable.
- Critical wave information has both visual and audio placeholder channels.

## Acceptance scenario

From a clean checkout, launch a headless server and two clients. Both clients observe the same three-wave schedule, paddle and duck-dive, catch and ride a wave, wipe out and recover, and exchange one server-validated sidearm interaction. Repeat under 100 ms RTT / 2% loss. Capture performance and correction metrics, then export or build the supported macOS and Windows client artifacts according to the runbook.

## Global done condition

```bash
./scripts/verify.sh all
```

The command must exit zero only when every ticket-level check and the headless integration test pass.
