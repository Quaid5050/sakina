import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/core/design/tokens.dart';

/// Hex values copied verbatim from docs/DESIGN_TOKENS.md. If a token changes
/// in the doc, this table and tokens.dart change in the same PR.
const Map<String, (Color, int)> _documented = <String, (Color, int)>{
  'brand.nightTeal': (SakinaPalette.nightTeal, 0xFF0F3D3E),
  'brand.dawnGold': (SakinaPalette.dawnGold, 0xFFE2B04A),
  'brand.sand': (SakinaPalette.sand, 0xFFF4EDE1),
  'brand.ink': (SakinaPalette.ink, 0xFF1C1B19),
  'brand.roseDawn': (SakinaPalette.roseDawn, 0xFFD98C6A),
  'surface.background': (SakinaPalette.background, 0xFFF4EDE1),
  'surface.raised': (SakinaPalette.raised, 0xFFFBF7F0),
  'surface.sunken': (SakinaPalette.sunken, 0xFFEDE3D2),
  'surface.segmented': (SakinaPalette.segmented, 0xFFEFE6D6),
  'surface.hero': (SakinaPalette.hero, 0xFF0F3D3E),
  'surface.night': (SakinaPalette.night, 0xFF0B2C2D),
  'surface.warning': (SakinaPalette.warning, 0xFFF7E7C6),
  'surface.warningSubtle': (SakinaPalette.warningSubtle, 0xFFFBF1DC),
  'surface.successChip': (SakinaPalette.successChip, 0xFFDCE9E4),
  'surface.dangerChip': (SakinaPalette.dangerChip, 0xFFF3D9CC),
  'text.primary': (SakinaPalette.textPrimary, 0xFF1C1B19),
  'text.strong': (SakinaPalette.textStrong, 0xFF3D3A34),
  'text.secondary': (SakinaPalette.textSecondary, 0xFF5A544B),
  'text.tertiary': (SakinaPalette.textTertiary, 0xFF6B655B),
  'text.accentBrown': (SakinaPalette.accentBrown, 0xFF8A5A1E),
  'text.onDark': (SakinaPalette.onDark, 0xFFF4EDE1),
  'text.onDarkSecondary': (SakinaPalette.onDarkSecondary, 0xFFD9D2C4),
  'text.onDarkTertiary': (SakinaPalette.onDarkTertiary, 0xFFC9C1B1),
  'text.onDarkMuted': (SakinaPalette.onDarkMuted, 0xFF8FA3A1),
  'text.gold': (SakinaPalette.textGold, 0xFFE2B04A),
  'text.onGold': (SakinaPalette.onGold, 0xFF1C1B19),
  'text.link': (SakinaPalette.link, 0xFF0F3D3E),
  'text.success': (SakinaPalette.textSuccessOnDark, 0xFF8FD1B5),
  'text.chipDanger': (SakinaPalette.chipDangerText, 0xFF7A3418),
  'text.chipSuccess': (SakinaPalette.chipSuccessText, 0xFF0F3D3E),
  'text.chipWarning': (SakinaPalette.chipWarningText, 0xFF6B4510),
  'text.disabled': (SakinaPalette.textDisabled, 0xFF8A8273),
  'line.divider': (SakinaPalette.lineDivider, 0xFFECE3D3),
  'line.subtle': (SakinaPalette.lineSubtle, 0xFFE6DCCB),
  'line.input': (SakinaPalette.lineInput, 0xFFDCCFB9),
  'line.control': (SakinaPalette.lineControl, 0xFFD9CBB3),
  'state.live': (SakinaPalette.stateLive, 0xFF2F8F6A),
  'line.cellA11y': (SakinaPalette.lineCellA11y, 0xFF968A75),
  'line.radioA11y': (SakinaPalette.lineRadioA11y, 0xFF968A75),
  'state.warningA11y': (SakinaPalette.warningA11y, 0xFFA87514),
};

void main() {
  group('colour tokens equal DESIGN_TOKENS.md', () {
    for (final MapEntry(:key, :value) in _documented.entries) {
      test(key, () {
        expect(value.$1.toARGB32(), value.$2);
      });
    }
  });

  test('spacing, radii and hit targets match the documented scale', () {
    expect(<double>[
      Space.s05,
      Space.s1,
      Space.s15,
      Space.s2,
      Space.s25,
      Space.s3,
      Space.s35,
      Space.s4,
      Space.s45,
      Space.s5,
      Space.s6,
      Space.s7,
      Space.s8,
      Space.s12,
    ], <double>[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 48]);
    expect(Space.gutter, 20);
    expect(Space.gutterOnboarding, 28);
    expect(Radii.row, 14);
    expect(Radii.content, 20);
    expect(Radii.feature, 22);
    expect(Radii.hero, 32);
    expect(Hit.min, greaterThanOrEqualTo(48));
  });

  test('motion durations collapse to zero when animations are disabled', () {
    expect(Motion.resolve(Motion.slow, disabled: false), Motion.slow);
    expect(Motion.resolve(Motion.slow, disabled: true), Duration.zero);
  });
}
