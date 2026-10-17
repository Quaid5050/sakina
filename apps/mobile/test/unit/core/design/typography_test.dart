import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/core/design/theme.dart';
import 'package:sakina_mobile/core/design/typography.dart';

void main() {
  test('English uses Fraunces for display and Manrope for UI', () {
    final type = SakinaType.forLocale(const Locale('en'));
    expect(type.displayHero.fontFamily, SakinaFonts.display);
    expect(type.bodyMedium.fontFamily, SakinaFonts.ui);
    expect(type.displayHero.fontSize, 52);
  });

  test('Arabic never uses Fraunces and keeps Naskh line height >= 1.6', () {
    final type = SakinaType.forLocale(const Locale('ar'));
    expect(type.displayHero.fontFamily, SakinaFonts.arabicUi);
    expect(type.bodyMedium.fontFamily, SakinaFonts.arabicUi);
    expect(type.displayHero.height, greaterThanOrEqualTo(1.6));
    expect(type.labelSmall.height, greaterThanOrEqualTo(1.6));
    expect(type.overline.letterSpacing, 0);
  });

  test('Urdu uses Nastaliq with line height >= 2.0', () {
    final type = SakinaType.forLocale(const Locale('ur'));
    expect(type.bodyMedium.fontFamily, SakinaFonts.urdu);
    expect(type.bodyMedium.height, greaterThanOrEqualTo(2.0));
    expect(type.titleMedium.height, greaterThanOrEqualTo(2.0));
  });

  test('Quran and Urdu translation styles follow DESIGN_TOKENS §3.3', () {
    final type = SakinaType.forLocale(const Locale('en'));
    expect(type.quranAyah.fontFamily, SakinaFonts.quran);
    expect(type.quranAyah.fontSize, 26);
    expect(type.quranAyah.height, 1.95);
    expect(type.urduTranslation.fontFamily, SakinaFonts.urdu);
    expect(type.urduTranslation.height, greaterThanOrEqualTo(2.2));
  });

  test('countdown uses tabular figures', () {
    final type = SakinaType.forLocale(const Locale('en'));
    expect(
      type.countdown.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  test('the theme carries the type extension for its locale', () {
    final theme = buildSakinaTheme(const Locale('ur'));
    expect(theme.extension<SakinaType>()!.script, UiScript.urdu);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF4EDE1));
  });
}
