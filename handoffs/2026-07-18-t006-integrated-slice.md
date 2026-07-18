# Handoff — T006 Integrated Tutorial-Cove Slice

**Date:** 2026-07-18  
**Ticket:** T006 / GitHub #27  
**Branch:** `godot-risk-slice`  
**Gate:** `./scripts/verify.sh all`

## Completed

- Added the playable `TutorialCove` scene and launch-screen local-play route.
- Built the gameplay-readable graybox reef, water plane, board/surfer, buoy target, third-person camera, and high-contrast edge HUD.
- Added repeating 75-second deterministic three-wave sets plus visual and generated-audio approach cues.
- Added `SidearmProjectile.step()` with ballistic travel, finite-state rejection, three-second lifetime, and an exact one-metre authoritative water cutoff.
- Extended the impaired ENet soak so clients send bounded boolean fire intent while the server owns projectile simulation, water cutoff, hits, player HP, and board HP.
- Added `FrameMetrics` nearest-rank p95 and bounded memory-growth evidence.
- Added clean tutorial-cove smoke, checked-in benchmark evidence validation, clean-log enforcement, server-authoritative sidearm assertions, and macOS export generation to the global gate.
- Produced an unsigned local macOS artifact at `build/macos/SurfRoyale.zip` and preserved Windows x86_64 cross-export / RTX reference instructions.

## Evidence

- Rendered M4 run: 300 seconds at 1600×900.
- Measured frames: 17,876.
- p95 frame time: 16.667 ms.
- Memory growth: 2,043,306 bytes.
- Screenshot and JSON: `docs/evidence/`.
- Latest local macOS ZIP after the Part 3 authority audit: 59,623,833 bytes, SHA-256 `c7dc3f3168767561a90638df4ed3296713158fbf0cf9645494bfa83bf59ddb88`.
- Full verification: `./scripts/verify.sh all` exits 0.

## Red-team pass

The direct checker pass found and fixed:

1. Tutorial-cove startup updated visuals before HUD labels existed, producing a script error that still let the smoke exit zero.
2. The test runner could print `TESTS_OK` after an unhandled script error; `run_tests` now rejects `ERROR:` / `SCRIPT ERROR:` and requires the success marker.
3. Exact one-metre cutoff and non-finite projectile state were not covered; failing tests were added before the authoritative projectile fix.
4. Headless screenshot capture attempted to read a dummy renderer texture; presentation capture now degrades cleanly under the headless display server.
5. ENet peer IDs were incorrectly used as world-space slots, placing players billions of metres apart and preventing sidearm hits; positions now use bounded connection order.
6. Snapshot delivery could race disconnected peers; peer-state checks and a server-first soak shutdown removed stale packet errors.
7. A short benchmark without an evidence path could appear successful; representative benchmark mode now requires at least 300 seconds, the frame budget, and a writable result path.
8. Prototype colors were checked directly and do not use reserved hue H 300–320.
9. Default launch, clean scene startup, missing headless presentation output, malformed fire intent, non-finite projectile state, exact water boundary, clean logs, and memory growth were exercised.

No refactor finding remained severe enough to block the risk slice. `TutorialCove` is intentionally programmatic prototype composition; if retained beyond the next iteration, split world construction, HUD, and benchmark capture into authored scene/resources rather than growing this one script.

## Honest follow-ups

- Windows 1920×1080 / RTX 3070 Mobile performance evidence is not claimed; run and record it when that machine is available.
- Surf tuning still requires user playtest sign-off before any production tuning lock.
- The network combat path proves server ownership in a deterministic harness; it is not a production damage, replication, or anti-cheat system.
- The generated audio tone and graybox visuals are explicit placeholders.
- The unsigned macOS artifact is for local review only; signing/notarization remains out of scope.

## Engine decision

Retain Godot for the next reversible prototype iteration. The integrated evidence removes the risks this slice was designed to test, but it does not make Godot a permanent production-stack commitment.

## Next frontier

No implementation ticket remains open in technical Wayfinder #21 after T006. Part 3 should close/synchronize the tracker, summarize the evidence-backed decision, and leave the open PR for user review without merging it.
