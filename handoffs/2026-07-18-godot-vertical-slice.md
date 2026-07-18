# Handoff — Godot 4 Tutorial-Cove Risk Slice

## Start here

- Technical brief: `docs/technical/00-technical-brief.md`
- Specification: `docs/specs/godot-vertical-slice.md`
- Wayfinder: `tracker/technical-map.md`
- Ticket mirrors: `tracker/technical-tickets/`
- Next implementation ticket: **T002 — bootstrap and verification harness**

## Locked decisions

Godot 4, typed GDScript, M4 primary development, Windows + macOS prototype clients, near-zero recurring cost, graybox readability, M4 900p60, RTX 3070 Mobile 1080p60, and 100 ms RTT / 2% packet loss. Godot is reversible; UE5 is excluded.

## Invariants

- Server owns ocean, movement state, stamina, board/HP, projectiles, and hits.
- Clients send input intent only.
- Headless server targets 30 Hz and must not depend on rendering.
- Ocean gameplay queries never wait on GPU readback.
- Server failure returns a clear error within five seconds.
- `./scripts/verify.sh all` is the global machine-checkable gate.

## Slice order

T002 bootstrap → T003 ocean truth → T004 surf controller → T005 networking → T006 integrated gameplay/readability/evidence review.

## Explicit exclusions

No production backend, live 60-player test, final art, progression/store, production anti-cheat integration, or Unreal/UE5 work.
