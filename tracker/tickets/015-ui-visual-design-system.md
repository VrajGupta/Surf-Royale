# 015 — UI visual design system

- Label: `wayfinder:prototype` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/15
- Status: closed
- Assignee: vraj
- Blocked by: [006 — UX direction handoff](006-ux-direction-handoff.md)

## Question

The game's UI *visual* system — color tokens, type scale, component polish for HUD/menus/pass screens — built **on top of** Vraj's UX direction, never ahead of it. Must consult `/better-ui`, `/better-typography`, `/better-colors` (map Notes). Output: a visual-system spec + rough visual prototype as linked assets.

## Decision (2026-07-17)

OKLCH ocean-derived tokens (H≈230 neutral ramp, surf/coral accents, reserved zone hue 300–320 locked at token level); APCA Lc≥75/60 acceptance checks; light theme derived from dark by L reversal. Variable grotesk + mono, 1.25 scale, fluid 16–18px base, tabular numerals in HUD. Full interaction contract on every element (44px targets, 0.96 press, 150–250ms transform/opacity, reduced-motion). Two surfaces on one token set: glass HUD (edge-only per #6) and solid menus; dark-first. Assets: design/ui-visual-system.md + design/ui-prototype.html.
