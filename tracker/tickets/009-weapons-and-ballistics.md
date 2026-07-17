# 009 — Weapons & ballistics

- Label: `wayfinder:grilling` (HITL)
- Issue: https://github.com/VrajGupta/Surf-Royale/issues/9
- Status: closed
- Assignee: vraj
- Blocked by: [002 — Surf movement & ocean physics model](002-surf-movement-and-ocean-physics-model.md), [003 — Comparables & real-ocean research](003-comparables-and-real-ocean-research.md)

## Question

Full spec for Pistol/Shotgun/Rifle: damage, effective ranges, projectile arc + water-slowdown model, wind effect on trajectory, recoil values, and the weapon-sway formula as a function of velocity + board stability (from 002). Attachments (scopes, grips) as recoil/aim modifiers only. Also: the audibility rule — gunshot broadcast range as a hard mechanic.

## Decision (2026-07-17)

Fast TTK: Pistol 30 (30m), Shotgun 12×8 (10m), Rifle 55 (200m) — 2 shots downs unarmored; positioning beats tracking. Ballistics: gravity arc + bullets die 1m into water (duck-dive = hard cover); wind visual-only. Sway = base × (1 + v/vmax) × stance mult (prone-on-board 0.8, sitting 1.0, standing-riding 2.5, treading 1.6); grip -30% sway, scope +zoom/+10% sway, laser -20% hipfire. Audibility: hard rings — pistol 400m, shotgun 600m, rifle 1000m, always directional (→ #13).
