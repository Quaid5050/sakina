# Sakina design tokens

These tokens are extracted from the Claude Design files (Onboarding, Today, Adhan Health, Quran, Family, Ramadan, Zakat, Travel, Plus, Landing, Masjid Console) and the brand direction in the product report: *"Calm, dignified and modern, like dawn over a quiet courtyard."* Values are exactly as used in the designs. Where a design value fails WCAG AA, this doc keeps the design value for decoration and adds an **accessible alternative** for text and UI (§2.4). The mobile team implements these tokens in `apps/mobile/lib/core/design/tokens.dart` and the `SakinaColors`/`SakinaType` `ThemeExtension`s. Tests assert that the Dart values equal this file.

Designs are drawn on a **390 × 844** artboard (iPhone 14/15 logical points). 1 design px = 1 Flutter logical pixel (dp/pt).

---

## 1. Brand palette (from the report)

| Token | Hex | Name | Role |
|---|---|---|---|
| `brand.nightTeal` | `#0F3D3E` | Night teal | Primary. Hero surfaces, primary buttons, selected states, the next-prayer row |
| `brand.dawnGold` | `#E2B04A` | Dawn gold | Accent. Highlights, ornaments, countdown accents, CTAs on teal, "prayed late" |
| `brand.sand` | `#F4EDE1` | Sand | App background (light) and primary text on teal |
| `brand.ink` | `#1C1B19` | Ink | Primary text on light surfaces, text on gold |
| `brand.roseDawn` | `#D98C6A` | Rose dawn | Secondary accent. Gentle notices, ring-fenced zakat fund, child avatar tint |

## 2. Colour tokens

### 2.1 Surfaces

| Token | Hex | Used for (design reference) |
|---|---|---|
| `surface.background` | `#F4EDE1` | Screen background (Today, Family, Zakat, Travel, Plus, Adhan Health, Console) |
| `surface.raised` | `#FBF7F0` | Cards, list containers, bottom nav, Quran reader background |
| `surface.sunken` | `#EDE3D2` | Streak card, round back buttons, Plus trial note |
| `surface.segmented` | `#EFE6D6` | Segmented-control track (Quran modes, Zakat nisab) |
| `surface.hero` | `#0F3D3E` | Today header, Onboarding, encouragement card, zakat result, console sidebar |
| `surface.night` | `#0B2C2D` | Ramadan mode background (deeper teal) |
| `surface.warning` | `#F7E7C6` | Failing Adhan Health check card; travel icon tile |
| `surface.warningSubtle` | `#FBF1DC` | Changed row in the console iqamah table |
| `surface.successChip` | `#DCE9E4` | "Confirmed" chip (rota) |
| `surface.dangerChip` | `#F3D9CC` | "Needed" chip (rota) |
| `surface.input` | `#F4EDE1` on raised, `#FFFFFF` for an edited input | Zakat and console inputs |

**Translucent overlays on teal or night surfaces** (store as colour + opacity; Flutter `Color.withValues(alpha:)`):

| Token | Value | Used for |
|---|---|---|
| `overlay.onDark.subtle` | sand @ 0.05–0.06 | Unselected option tiles, Ramadan cards |
| `overlay.onDark.muted` | sand @ 0.08 | Encouragement chip, pledge dividers |
| `overlay.onDark.chip` | sand @ 0.10–0.12 | City toggle track, Qibla/health chips on the Today hero |
| `overlay.onDark.border` | sand @ 0.12–0.14 | Card borders on night, dividers |
| `overlay.onDark.input` | sand @ 0.20 (border), 0.06 (fill) | Onboarding city input |
| `overlay.onDark.strongBorder` | sand @ 0.25–0.30 | Secondary buttons on teal, unselected chips |
| `overlay.onDark.radio` | sand @ 0.45–0.50 | Unselected radio and checkbox outlines |
| `overlay.gold.selected` | gold @ 0.16 | Selected option tile on teal (with a 1 px gold border) |
| `overlay.gold.border` | gold @ 0.28–0.35 | Pledge card border, console plan card |
| `overlay.rose.notice` | rose @ 0.14 | Onboarding "Next we'll check…" notice |

### 2.2 Text

| Token | Hex | On | Contrast | Use |
|---|---|---|---|---|
| `text.primary` | `#1C1B19` | sand | 14.8 | Body and headings on light |
| `text.strong` | `#3D3A34` | sand | 9.7 | Secondary body (translations, details) |
| `text.secondary` | `#5A544B` | sand / raised / sunken | 6.4 / 7.0 / 5.9 | Captions, labels, hints |
| `text.tertiary` | `#6B655B` | sand / raised | 5.0 / 5.4 | Meta (Arabic names in lists, nav inactive, footnotes) |
| `text.accentBrown` | `#8A5A1E` | sand | 5.1 | Overline labels on light ("SAKINA PLUS", "DU'A AT IFTAR") |
| `text.onDark` | `#F4EDE1` | teal | 10.3 | Primary text on teal |
| `text.onDarkSecondary` | `#D9D2C4` | teal | 7.9 | Body on teal |
| `text.onDarkTertiary` | `#C9C1B1` | teal / night | 6.7 / 8.3 | Captions on teal |
| `text.onDarkMuted` | `#8FA3A1` | night card | 4.8 | Future days in the Ramadan log |
| `text.gold` | `#E2B04A` | teal / night | 6.0 / 7.5 | Overlines, Arabic accents, the zakat-due figure **on dark only** |
| `text.onGold` | `#1C1B19` | gold | 8.6 | Text on gold buttons and tiles |
| `text.link` | `#0F3D3E` | sand | 10.3 | Links on light (`hover` → ink) |
| `text.linkOnDark` | `#E2B04A` | teal | 6.0 | Links on teal (`hover` → sand) |
| `text.success` | `#8FD1B5` | teal | 6.8 | "Adhan healthy", "Compass calibrated" on dark |
| `text.chipDanger` | `#7A3418` | dangerChip | 6.7 | "Needed" |
| `text.chipSuccess` | `#0F3D3E` | successChip | 9.6 | "Confirmed" |
| `text.chipWarning` | `#6B4510` | warning | 6.9 | "Draft · 1 change" |
| `text.disabled` | `#8A8273` | raised | 3.6 | **Only for hidden memorisation words and disabled states** (exempt from contrast rules) |

### 2.3 Lines, states and data

| Token | Hex | Use |
|---|---|---|
| `line.divider` | `#ECE3D3` | Hairlines in reader and console tables |
| `line.subtle` | `#E6DCCB` | Nav top border, progress track |
| `line.input` | `#DCCFB9` | Input borders on light |
| `line.control` | `#D9CBB3` | Unselected pill borders (decorative, paired with text) |
| `line.cell` | `#C9BDA8` | "Not logged" cell outline (see §2.4) |
| `line.radio` | `#B8AD9A` | Unselected radio outline (see §2.4) |
| `ring.track` | `#E2D6C2` / `#D9CBB3` | Health and streak ring tracks |
| `state.warningStrong` | `#C98F1E` | Ring at < 5/5, bookmark-on stroke, edited-input border |
| `state.live` | `#2F8F6A` | "Live rate" dot (zakat) |
| `data.prayed` | `#0F3D3E` | Salah grid: prayed |
| `data.prayedLate` | `#E2B04A` | Salah grid: prayed late |
| `data.notLogged` | outline `#C9BDA8` | Salah grid: not logged (neutral, never "missed") |
| `data.ramadanKept` | `#E2B04A` on night | Fasting log: kept |
| `data.zakatFund` | `#D98C6A` | Ring-fenced zakat fund bar |

### 2.4 Accessibility corrections (required)

These design values fail WCAG 2.2 AA in the context they're used in. Implement the **accessible value** wherever the element carries meaning.

| Design value | Context | Ratio | Requirement | Accessible value | New ratio |
|---|---|---|---|---|---|
| `#C9BDA8` cell outline | "Not logged" cell on raised (meaningful state) | 1.74 | 3:1 (non-text) | `line.cellA11y = #968A75` | 3.18 |
| `#B8AD9A` radio outline | Unselected radio on raised | 2.07 | 3:1 | `line.radioA11y = #968A75` | 3.18 |
| `#C98F1E` | Health ring at < 5/5 and the bookmark-on icon on raised | 2.65 | 3:1 | `state.warningA11y = #A87514` | 3.77 |
| `#2F8F6A` | 8 px live dot on raised | 3.74 | 3:1 ✓ | keep | n/a |
| `#E2B04A` on sand/raised | Any text or icon in gold on a light surface | 1.7–1.9 | never | Use `text.accentBrown #8A5A1E` (5.1) for text and `state.warningA11y` for icons. Gold stays a **fill** on light surfaces (with ink text) | n/a |
| `#F4EDE1` on `#D98C6A` | Text on a rose tile | 2.28 | 4.5:1 | Use ink `#1C1B19` on rose (6.5), as the landing page already does | 6.48 |
| Gold vs teal cells in the salah grid | Colour-only distinction | n/a | not colour alone | Add a 45° hatch or a small "L" glyph to `prayedLate` cells, and a per-cell semantic label | n/a |

A test in `test/unit/design/contrast_test.dart` computes these ratios from the tokens and fails below the thresholds.

### 2.5 Profile colours (family avatars; API `ProfileColor`)

| Enum | Tile fill | Initial colour | Source |
|---|---|---|---|
| `TEAL` | `#0F3D3E` | `#F4EDE1` | Family: Aisha |
| `ROSE` | `#D98C6A` | `#1C1B19` (a11y fix; the design uses sand) | Family: Yusuf |
| `GOLD` | `#E2B04A` | `#1C1B19` | Family: Maryam |
| `SAND` | `#F4EDE1` | `#0F3D3E` | Landing family card |
| `INK` | `#1C1B19` | `#F4EDE1` | Added for a fifth option |

### 2.6 Dark theme
The designs have no system-wide dark theme. Teal and night surfaces are used *contextually* (hero, onboarding, Ramadan). MVP rule: **the app follows the designs in both system modes**, and Ramadan mode uses `surface.night` as its theme. A full dark theme is a Plus "themes" feature (v1.1). Tokens are named semantically so it can be added later without renaming.

## 3. Typography

### 3.1 Families (all bundled, SIL OFL; never fetched at runtime)

| Token | Family | Weights used | Use |
|---|---|---|---|
| `font.display` | **Fraunces** (variable, opsz 9–144) | 300, 400, 500 (600 available) | Headings, prayer names in the hero, big numerals (prices, nisab, Qibla degrees) |
| `font.ui` | **Manrope** | 400, 500, 600, 700 | All UI text in English |
| `font.quran` | **Amiri** | 400, 700 | Quran text, Bismillah, du'a, Arabic display |
| `font.arabicUi` | **Noto Naskh Arabic** | 400, 600 | Arabic UI labels (prayer names in lists, Arabic locale UI) |
| `font.urdu` | **Noto Nastaliq Urdu** | 400, 600 | Urdu UI and Urdu translation |

Fallback stacks in the designs are `'Fraunces', Georgia, serif` and `'Manrope', 'Segoe UI', system-ui, sans-serif`. In Flutter, set `fontFamilyFallback` to the script fonts so that mixed-script strings render correctly.

**Locale mapping:** in `en`, headings use Fraunces and UI uses Manrope. In `ar`, headings and UI use Noto Naskh Arabic (Amiri for display and Quran). In `ur`, headings and UI use Noto Nastaliq Urdu. Fraunces is never used for Arabic-script text.

### 3.2 Mobile type scale (px = logical px)

| Token | Family | Size | Weight | Line height | Letter spacing | Example in the designs |
|---|---|---|---|---|---|---|
| `display.hero` | Fraunces | 52 | 500 | 1.0 | −0.02em | Next-prayer name "Asr" (Today) |
| `display.l` | Fraunces | 38 | 400 | 1.1 | −0.015em | "Your prayers are not a product." |
| `display.m` | Fraunces | 34 | 400 | 1.1–1.15 | 0 | Onboarding steps 2–3, "Iftar in 2h 18m", Qibla "119°" |
| `headline.l` | Fraunces | 32 | 400 | 1.12 | 0 | Plus headline, zakat-due figure |
| `headline.m` | Fraunces | 28–30 | 500 | 1.1 | 0 | "Adhan health", "Zakat for 1448", "The Rahman family", suhoor/iftar times |
| `title.l` | Fraunces | 22 | 400–500 | 1.2 | 0.01em | Brand wordmark "Sakina", plan prices |
| `title.m` | Fraunces | 19–20 | 500 | 1.25 | 0 | Section titles: "Today's prayers", "Salah this week", "Quran journey" |
| `title.s` | Fraunces | 18 | 500 | 1.3 | 0 | Ramadan section titles |
| `numeric.countdown` | Manrope | 30 | 600 | 1.1 | −0.01em | "1h 12m" (`tabular-nums`) |
| `body.l` | Manrope | 16 | 400–700 | 1.55 | 0 | Onboarding body, primary button label (700) |
| `body.m` | Manrope | 15 | 400–700 | 1.5 | 0 | List item titles (700), prayer rows (600), inputs |
| `body.s` | Manrope | 14 | 400–700 | 1.5 | 0 | Secondary body, card titles, links |
| `label.l` | Manrope | 13 | 500–700 | 1.45 | 0 | Detail lines, chips, small buttons |
| `label.m` | Manrope | 12 | 600–700 | 1.4 | 0 | Meta, small chips, pills |
| `label.s` | Manrope | 11 | 600–700 | 1.35 | 0 | Bottom-nav labels, legends, footnotes |
| `overline` | Manrope | 11–12 | 700 | 1.3 | **0.12–0.16em, UPPERCASE** | "THE AMANAH PLEDGE", "RAMADAN 1448 · DAY 14", "QIBLA" |
| `micro` | Manrope | 10 | 700 | 1.2 | 0 | Ramadan day numbers |

Numbers that change or align (times, countdowns, money) use **`FontFeature.tabularFigures()`**.

### 3.3 Arabic and Urdu scale

| Token | Family | Size | Line height | Use |
|---|---|---|---|---|
| `quran.bismillahHero` | Amiri | 34 | 1.6 | Onboarding Bismillah (gold on teal) |
| `quran.bismillah` | Amiri | 28 | 1.9 | Reader Bismillah (teal) |
| `quran.ayah` | Amiri | 26 (user scalable, min 22, max 52) | **1.95** | Ayah text, right-aligned |
| `quran.dua` | Amiri | 24 | 1.8 | Ramadan du'a |
| `arabic.accent` | Noto Naskh Arabic | 26 | 1.3 | "العصر" beside the hero prayer name (gold) |
| `arabic.list` | Noto Naskh Arabic | 13–15 | 1.4 | Arabic prayer names in rows (tertiary colour) |
| `urdu.translation` | Noto Nastaliq Urdu | 15 | **2.2** | Urdu translation under ayat |
| `urdu.ui` | Noto Nastaliq Urdu | 15–22 | 2.0 | Urdu UI (language tile uses 22 / 1.5) |

**Line-height rule:** Nastaliq needs at least 2.0× line height, and Naskh/Amiri at least 1.6×, or the descenders clip. `SakinaType` applies these per-script multipliers automatically when the locale or the text's script is Arabic/Urdu, so widgets don't hand-tune line height.

### 3.4 Web (landing + console) responsive headings
The landing page uses fluid type. The console reuses the mobile scale, plus `display.console = Fraunces 36/400`.

| Token | Value |
|---|---|
| `web.hero` | Fraunces 300, `clamp(44px, 6vw, 80px)`, lh 1.02 |
| `web.h2` | Fraunces 400, `clamp(34px, 4vw, 52px)`, lh 1.08 |
| `web.h2Small` | Fraunces 400, `clamp(32px, 3.6vw, 46px)`, lh 1.1 |
| `web.closing` | Fraunces 300, `clamp(36px, 4.6vw, 60px)`, lh 1.06 |
| `web.h3` | Fraunces 500, 23–26 px |
| `web.numeral` | Fraunces 40–52 px, lh 1 (pledge numbers, countdown) |

## 4. Spacing

The designs use a **2 px base with a 4 px rhythm**. Tokens (`Space.*` in Dart):

| Token | px | Typical use |
|---|---|---|
| `space.0_5` | 2 | Title/subtitle gap, segmented-control gutters |
| `space.1` | 4 | Tight stacks, nav icon-label gap |
| `space.1_5` | 6 | Chip gaps, small stacks |
| `space.2` | 8 | Default inline gap, list item gap |
| `space.2_5` | 10 | Button groups, card stacks |
| `space.3` | 12 | Icon-text gap in rows, card internal gap |
| `space.3_5` | 14 | Card padding (compact), row gaps |
| `space.4` | 16 | Card padding, section gap |
| `space.4_5` | 18 | Card padding (roomy), screen section gap |
| `space.5` | 20 | **Screen horizontal gutter** (most screens) |
| `space.6` | 24 | Hero padding (horizontal), console card padding |
| `space.7` | 28 | Onboarding gutter and section gap |
| `space.8` | 32 | Large section gaps (console) |
| `space.12` | 48 | Web section gaps |

**Screen insets (mobile):** content top padding is 52–56 px below the status bar (use `SafeArea` + 8–12), the horizontal gutter is 20 (onboarding 28), and the bottom is 24–28 above the home indicator. Bottom-nav padding is `10 12 26`.

**Web:** the console main padding is `clamp(16px, 3vw, 40px)`. Landing sections use 96–112 px vertical padding.

## 5. Radii

| Token | px | Use |
|---|---|---|
| `radius.xs` | 3–4 | Legend swatches, progress bars (2–5 px = half the height) |
| `radius.s` | 6–8 | Grid cells (6), Ramadan day cells (7), segmented inner (8) |
| `radius.m` | 10–12 | Avatar tiles (10), segmented track (10–14), console inputs (10–12) |
| `radius.l` | 14 | Primary inline buttons (Fix), Zakat buttons, the next-prayer row, nav pills |
| `radius.xl` | 16 | Option tiles, inputs on teal, list rows |
| `radius.2xl` | 18 | Cards (Adhan checks, pledge items, plan options, language tiles) |
| `radius.3xl` | 20 | Content cards (prayer list container, Ramadan cards, console stats) |
| `radius.4xl` | 22 | Feature cards (Family sections, Travel, Zakat result, pledge card) |
| `radius.5xl` | 24 | Console panels |
| `radius.hero` | 32 | Bottom corners of the Today hero (`0 0 32 32`) |
| `radius.device` | 40 | Artboard/device frame (reference only) |
| `radius.pill` | 999 | Primary CTAs, chips, toggles, round icon buttons (use `StadiumBorder` / `CircleBorder`) |

## 6. Elevation and borders

The designs are almost flat. Depth comes from surface colour, not shadows.

| Token | Value | Use |
|---|---|---|
| `elevation.hairline` | `0 1px 0 rgba(28,27,25,0.06)` | Prayer list container |
| `elevation.selected` | `0 1px 2px rgba(28,27,25,0.12)` | Selected segment |
| `elevation.showcase` | `0 40px 80px rgba(0,0,0,0.35)` | Landing phone mock only |
| `border.hairline` | 1 px | Cards on night, inputs, dividers |
| `border.selected` | 1.5–2 px `#0F3D3E` | Selected child tab, selected plan |
| `border.secondaryButton` | 1.5 px `#0F3D3E` | Outline button ("Send a test adhan in 1 minute") |

## 7. Components (key measurements)

| Component | Spec |
|---|---|
| Primary button | Height 56, pill, `body.l` 700. On light: teal fill + sand text. On teal: sand fill + teal text |
| Secondary button | Height 52, pill, 1.5 px teal border, teal text |
| Inline action button | Height 48, radius 14, teal fill |
| Gold CTA (on teal) | Height 48–60, radius 14–18, gold fill, ink text |
| Chip / pill | Height 36–40, padding 0 12–14, pill, `label.l`/`label.m` 600–700 |
| Icon button | 44 × 44 circle (minimum hit area 48 dp on Android: pad the hit area, not the visual) |
| Bottom nav | 4 items, icon 24 px stroke 1.8, label 11 px. Active: teal 700; inactive: `text.tertiary` 600 |
| Segmented control | Track `surface.segmented`, radius 10–14, padding 3–4. Segment height 36–40; selected = raised + `elevation.selected` |
| Option tile (onboarding) | Min height 60 (methods) / 96 (languages), radius 16–18. Selected: gold @ 0.16 + 1 px gold |
| Prayer row | Min height 48, padding 0 14, radius 14. Status dot 10 px. Next row: teal fill, sand text |
| Salah grid | 44 px label column + 7 equal columns, gap 5, cell height 22, radius 6 |
| Progress bar | Height 4 (audio) / 8 (Quran journey) / 10 (funds), track `line.subtle`/`line.divider` |
| Ring (health) | 96 px, stroke 8, round caps, starts at −90° |
| Ring (streak) | 40 px, stroke 3 |
| Qibla compass | 120 px. Outer ring sand @ 0.25, inner dashed ring @ 0.12, gold needle with a Kaaba square marker |
| Ayah marker | 30 px 8-point star (two 16 px squares, one rotated 45°), gold stroke 1.2, number 12 px 700 teal |

### Iconography
Line icons, 24 px grid, **stroke 1.6–2.0, round caps and joins**, `currentColor`. Custom glyphs: the mihrab/arch logo (used as the brand mark and the Today tab), shield-check (pledge, adhan health), compass, book (Quran), house (Family), sun-burst (More). Use a single icon set built from these SVGs (`assets/icons/*.svg` + `flutter_svg`, or an icon font) rather than Material icons, so the style stays consistent. Icons that imply direction (back chevron, progress arrows) **mirror in RTL**; the logo, compass and play icon do not.

### Pattern and texture
Geometric patterns are **quiet texture, never clip-art**:
- `pattern.star8`: two overlapping squares (one rotated 45°), 78–96 px tile, gold stroke 0.7–1, **opacity 0.09–0.12**, faded with a top-to-bottom mask. Used on the onboarding and landing heroes.
- `pattern.girih`: an 8-point star with diagonals, 56 px tile, gold stroke 0.6–1, opacity 0.09. Used on the Today hero.
- `pattern.dawnArcs`: three concentric half-arcs (gold/rose/gold, stroke 1, opacity 0.35), bottom-right of the Today hero.
- Ramadan: a crescent (an offset circle cut-out) and sparse gold star dots at opacity 0.55.

Patterns are decorative: `ExcludeSemantics`, and hidden when `MediaQuery.highContrast` is on.

## 8. Motion

The designs are static. These defaults keep the "calm" brand:

| Token | Value | Use |
|---|---|---|
| `motion.fast` | 120 ms, `Curves.easeOut` | Pressed states, toggles |
| `motion.base` | 200 ms, `Curves.easeInOut` | Segment and tab changes, chip selection |
| `motion.slow` | 400 ms, `Curves.easeInOutCubic` | Ring fills, onboarding step transitions |
| Countdown | Updates once a minute (once a second under 1 h is optional), with no animation | |

When `MediaQuery.disableAnimations` is true, every duration becomes 0.

## 9. Content and copy tokens (reused strings)

The copy is part of the brand. Use it verbatim in the EN ARB file:
- Streak: "Missed one? Your streak rests, it doesn't reset."
- Family: "Children see praise, never a scoreboard." / "Sent. {name} will see it after Maghrib."
- Plus: "Plus pays for conveniences. It never unlocks worship." / "7 days free. We remind you 2 days before any charge, and you can cancel in one tap. No surprise renewals."
- Zakat: "Amounts stay on this phone." / "Giving runs through licensed charities only; Sakina never holds your zakat."
- Onboarding location: "Your location is used on this phone to calculate times. It never leaves the device unless you turn on sync, and it is never sold or shared." **This needs a correction to match ADR-0007:** location never leaves the device *even with sync on*, since sync never includes location. Proposed: "Your location is used only on this phone to calculate times. It never leaves the device and is never sold or shared."
- Plus feature: "Encrypted sync, all devices" must read **"Sync across devices"** with the subline "Encrypted in transit and at rest" until E2EE ships (SPEC D-7).

Placeholders in the designs (`[INDEPENDENT AUDITOR]`, `[RECITER NAME]`, `[SCHOLAR ADVISORY BOARD]`, `[LIVE RATE]`, `[PKR PRICE]`, `[LICENSED CHARITY PARTNER]`, `[VERSE TEXT]`, `[URDU TRANSLATION]`) are open founder inputs (SPEC §10). Keep them behind l10n keys so they can be filled without code changes.

## 10. Dart mapping sketch

```dart
// lib/core/design/tokens.dart: generated from or tested against this file
abstract final class SakinaPalette {
  static const nightTeal = Color(0xFF0F3D3E);
  static const night     = Color(0xFF0B2C2D);
  static const dawnGold  = Color(0xFFE2B04A);
  static const sand      = Color(0xFFF4EDE1);
  static const raised    = Color(0xFFFBF7F0);
  static const sunken    = Color(0xFFEDE3D2);
  static const ink       = Color(0xFF1C1B19);
  static const roseDawn  = Color(0xFFD98C6A);
  static const textStrong    = Color(0xFF3D3A34);
  static const textSecondary = Color(0xFF5A544B);
  static const textTertiary  = Color(0xFF6B655B);
  static const accentBrown   = Color(0xFF8A5A1E);
  static const lineCellA11y  = Color(0xFF968A75);
  static const warningA11y   = Color(0xFFA87514);
}

abstract final class Space { static const s2 = 8.0, s3 = 12.0, s4 = 16.0, s5 = 20.0, s6 = 24.0; /* … */ }
abstract final class Radii { static const card = 20.0, feature = 22.0, tile = 18.0, row = 14.0, pill = 999.0; /* … */ }
```
