# Technical Brief — Godot 4 Risk Prototype

**Status:** Locked for the first reversible implementation slice (2026-07-18)  
**Authority:** Current user decisions supersede the historical UE5 references in `tracker/map.md` and `docs/GDD.md`.

## Purpose

De-risk Surf Royale's core technical bet with a disposable Godot 4 prototype before selecting a permanent production stack. The prototype proves whether deterministic ocean truth, momentum-honest surfing, authoritative networking, and gameplay-readable water can coexist within solo-developer constraints.

## Locked decisions

- Engine for this prototype: **Godot 4**, explicitly reversible and not yet the permanent production-stack decision.
- Scripting: **typed GDScript**.
- Primary development machine: **M4 MacBook Air**.
- Supported prototype clients: **macOS and Windows**.
- Windows performance reference: Alienware m15 R6 / RTX 3070 Mobile at **1920×1080, 60 FPS**.
- M4 performance reference: **1600×900 internal resolution, 60 FPS**.
- Visual target: gameplay-readable graybox, not presentation-quality water.
- Tooling and infrastructure: near-zero recurring cost; paid services require separate approval.
- Network resilience gate: **100 ms round-trip latency and 2% packet loss**.
- No UE5 installation, assets, tooling, code, build steps, or recommendations.

## Hard gates

1. Native Apple Silicon editor and local headless-server workflow.
2. Windows and macOS client export path documented and reproducible.
3. Dedicated authoritative server runs without rendering.
4. Ocean schedule is deterministic from a server-owned seed.
5. Six surf states remain controllable under the network envelope.
6. Server owns ocean state, movement state, stamina, projectile hits, HP, and board state.
7. The full verification command exits zero from a clean checkout.

## Weighted preferences

In descending order: solo-maintainability, fast iteration on M4, deterministic testability, networking transparency, rendering headroom, ecosystem breadth, and future provider portability.

## Exit criteria

Godot remains a candidate only if the integrated slice passes the acceptance script without engine modifications or recurring paid services. Failure of a hard gate triggers a documented stack reconsideration rather than hiding the problem behind prototype-only hacks.
