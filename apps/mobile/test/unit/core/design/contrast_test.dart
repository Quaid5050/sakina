import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/core/design/tokens.dart';

typedef _Pair = (String name, Color fg, Color bg, double minimum);
typedef P = SakinaPalette;

/// Every text/background or meaningful-UI pair the app uses (DESIGN_TOKENS
/// §2.2–2.4). Text needs 4.5:1; non-text UI components need 3:1.
const List<_Pair> _pairs = <_Pair>[
  ('text.primary on sand', P.textPrimary, P.sand, 4.5),
  ('text.primary on raised', P.ink, P.raised, 4.5),
  ('text.strong on sand', P.textStrong, P.sand, 4.5),
  ('text.secondary on sand', P.textSecondary, P.sand, 4.5),
  ('text.secondary on raised', P.textSecondary, P.raised, 4.5),
  ('text.secondary on sunken', P.textSecondary, P.sunken, 4.5),
  ('text.secondary on warning', P.textSecondary, P.warning, 4.5),
  ('text.tertiary on sand', P.textTertiary, P.sand, 4.5),
  ('text.tertiary on raised', P.textTertiary, P.raised, 4.5),
  ('text.tertiary on sunken', P.textTertiary, P.sunken, 4.5),
  ('accentBrown on sand', P.accentBrown, P.sand, 4.5),
  ('accentBrown on raised', P.accentBrown, P.raised, 4.5),
  ('onDark on teal', P.onDark, P.nightTeal, 4.5),
  ('onDark on night', P.onDark, P.night, 4.5),
  ('onDarkSecondary on teal', P.onDarkSecondary, P.nightTeal, 4.5),
  ('onDarkTertiary on teal', P.onDarkTertiary, P.nightTeal, 4.5),
  ('onDarkTertiary on night', P.onDarkTertiary, P.night, 4.5),
  ('onDarkMuted on night', P.onDarkMuted, P.night, 4.5),
  ('gold text on teal', P.textGold, P.nightTeal, 4.5),
  ('gold text on night', P.textGold, P.night, 4.5),
  ('ink on gold', P.onGold, P.dawnGold, 4.5),
  ('ink on rose (a11y fix)', P.ink, P.roseDawn, 4.5),
  ('teal link on sand', P.link, P.sand, 4.5),
  ('success text on teal', P.textSuccessOnDark, P.nightTeal, 4.5),
  ('chip danger', P.chipDangerText, P.dangerChip, 4.5),
  ('chip success', P.chipSuccessText, P.successChip, 4.5),
  ('chip warning', P.chipWarningText, P.warning, 4.5),
  ('not-logged cell outline', P.lineCellA11y, P.raised, 3),
  ('radio outline', P.lineRadioA11y, P.raised, 3),
  ('warning ring / bookmark', P.warningA11y, P.raised, 3),
  ('live-rate dot', P.stateLive, P.raised, 3),
];

void main() {
  group('contrast meets WCAG 2.2 AA', () {
    for (final (name, fg, bg, minimum) in _pairs) {
      test(name, () {
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(minimum));
      });
    }
  });

  test('the design values that §2.4 replaces really do fail', () {
    // Guards against someone "simplifying" back to the design originals.
    const designCell = Color(0xFFC9BDA8);
    const designRing = Color(0xFFC98F1E);
    expect(contrastRatio(designCell, SakinaPalette.raised), lessThan(3));
    expect(contrastRatio(designRing, SakinaPalette.raised), lessThan(3));
    expect(
      contrastRatio(SakinaPalette.dawnGold, SakinaPalette.sand),
      lessThan(3),
    );
  });

  test('contrastRatio is symmetric and 21 for black on white', () {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    expect(contrastRatio(black, white), closeTo(21, 0.01));
    expect(contrastRatio(white, black), closeTo(21, 0.01));
  });
}
