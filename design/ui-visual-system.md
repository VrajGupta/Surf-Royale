# UI Visual System — Surf Royale
Derived from UX handoff (#6). Consulted: /better-ui, /better-typography, /better-colors.

## Color tokens (OKLCH, ocean-derived)
Constant-hue neutral ramp at H≈230 (no drift >10°); accent = sunset coral; zone hue is a reserved token.

```css
:root {
  /* neutrals — water-derived, constant hue 230 */
  --ink-0:  oklch(0.15 0.02 230);
  --ink-1:  oklch(0.25 0.03 230);
  --ink-2:  oklch(0.45 0.04 230);
  --mist-1: oklch(0.85 0.03 230);
  --mist-0: oklch(0.96 0.01 230);
  /* brand */
  --surf:   oklch(0.72 0.13 210);   /* turquoise — primary interactive */
  --coral:  oklch(0.70 0.17 40);    /* sunset coral — accent/CTA */
  --danger: oklch(0.62 0.21 25);
  /* RESERVED: zone wall only (#5 rule 2). No other UI/VFX may use H 300–320. */
  --zone:   oklch(0.55 0.24 310);
}
```
Rules (acceptance checks):
- APCA: body text |Lc| ≥ 75; UI/non-body text |Lc| ≥ 60. Fix failures by adjusting L only.
- Chroma as % of max per hue (consistent vividness); clamp to sRGB, P3 via `@media (color-gamut: p3)` with fallback.
- Light theme derived from dark by reversing the L mapping — never hand-picked.
- Any token within ±15° of --zone hue fails review.

## Type
- One variable grotesk (weight axis 400–800 = hierarchy; `font-variant-numeric: tabular-nums` for timers/ammo/placement) + one mono for coords/telemetry.
- Scale: 1.25 ratio from a fluid base `clamp(16px, 1rem + 0.3vw, 18px)`; 10-ft contexts use the 18px+ end.
- Line-height 1.5 body / 1.1 display; letter-spacing tightens as size grows.
- Fallback metric-matched via `size-adjust`; numerals never proportional in HUD.

## Component contract (every interactive element)
- Hover, active, and visible focus states; focus never removed, only restyled.
- Touch targets ≥ 44×44px; press scale 0.96; transitions 150–250ms, transform/opacity only.
- Animations interruptible; `prefers-reduced-motion` collapses motion to fades.

## Surfaces (one token set, two surfaces)
- **Glass** (in-match HUD): translucent blur panel, thin borders, text at ≥Lc 75 against worst-case ocean frame; used only at screen edges per HUD-last rule (#6).
- **Solid** (menus/pass/locker): opaque `--ink-1` cards on `--ink-0`; dark-mode-first, light derived for the sun-bleached lobby.

Prototype: [ui-prototype.html](ui-prototype.html)
