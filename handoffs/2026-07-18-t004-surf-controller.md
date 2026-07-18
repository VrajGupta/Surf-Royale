# Handoff — T004 Six-State Surf Controller

## Completed

GitHub issue #25 / `tracker/technical-tickets/004-surf-controller.md`.

- Added data-driven surf tuning and an explicit input frame.
- Implemented paddling, duck-dive, pop-up, riding, wipeout, and treading.
- Paddling builds speed over strokes and remains capped at the GDD envelope.
- Pop-up requires catchable reef-break ocean truth.
- Ride steering rotates momentum gradually rather than setting velocity directly.
- Heavy impacts trigger wipeout; timed hold-down reaches tread; recovery returns to paddle.

## Verification

```bash
./scripts/verify.sh surf
./scripts/verify.sh ocean
./scripts/verify.sh bootstrap
```

All pass.

## Red-team pass

Attacked illegal state transitions, large-frame duck timing, stamina cost, malformed non-finite steer input, and momentum preservation. The malformed steer initially produced a Godot normalization warning and erased ride momentum. Added a failing regression test, sanitized non-finite input to neutral steering, and re-ran all gates successfully.

## Honest limitations

- Feel values are provisional and still require Vraj's hands-on playtest before production use.
- This is a pure simulation model; T006 supplies the visible player/board scene and input bindings.
- Network correction and authoritative snapshots are deliberately T005.

## Next ticket

T005 / GitHub #26 — two-client authority, prediction, and reconciliation.
