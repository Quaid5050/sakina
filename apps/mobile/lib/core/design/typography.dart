import 'package:flutter/material.dart';

/// Font family names as declared in pubspec.yaml (DESIGN_TOKENS §3.1).
abstract final class SakinaFonts {
  static const String display = 'Fraunces';
  static const String ui = 'Manrope';
  static const String quran = 'Amiri';
  static const String arabicUi = 'NotoNaskhArabic';
  static const String urdu = 'NotoNastaliqUrdu';

  /// Mixed-script strings (an Arabic prayer name inside English UI) fall
  /// back to the script fonts instead of a system font.
  static const List<String> fallback = <String>[arabicUi, urdu, quran];
}

/// The writing system of the UI locale. It decides fonts and line heights.
enum UiScript { latin, arabic, urdu }

UiScript scriptForLocale(Locale locale) => switch (locale.languageCode) {
  'ar' => UiScript.arabic,
  'ur' => UiScript.urdu,
  _ => UiScript.latin,
};

const FontWeight _w4 = FontWeight.w400;
const FontWeight _w5 = FontWeight.w500;
const FontWeight _w6 = FontWeight.w600;
const FontWeight _w7 = FontWeight.w700;

/// Script-aware type scale (DESIGN_TOKENS §3.2–3.3).
///
/// Nastaliq needs at least 2.0× line height and Naskh/Amiri at least 1.6×,
/// or descenders clip. These minimums are applied here so widgets never
/// hand-tune line height. Fraunces is never used for Arabic-script text.
@immutable
class SakinaType extends ThemeExtension<SakinaType> {
  const SakinaType._({
    required this.script,
    required this.displayHero,
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineMedium,
    required this.titleMedium,
    required this.countdown,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.overline,
    required this.arabicAccent,
    required this.arabicList,
    required this.quranAyah,
    required this.quranBismillah,
    required this.quranBismillahHero,
    required this.dua,
    required this.urduTranslation,
  });

  factory SakinaType.forLocale(Locale locale) {
    final script = scriptForLocale(locale);
    final (String d, String u, double minHeight) = switch (script) {
      UiScript.latin => (SakinaFonts.display, SakinaFonts.ui, 0.0),
      UiScript.arabic => (SakinaFonts.arabicUi, SakinaFonts.arabicUi, 1.6),
      UiScript.urdu => (SakinaFonts.urdu, SakinaFonts.urdu, 2.0),
    };
    const q = SakinaFonts.quran;
    const a = SakinaFonts.arabicUi;

    TextStyle s(
      String family,
      double size,
      FontWeight weight,
      double height, {
      double ls = 0,
      bool tabular = false,
      bool scriptMinimum = true,
    }) {
      // Tracking is a Latin device; it breaks Arabic letter joining.
      final latin = script == UiScript.latin;
      final floor = scriptMinimum ? minHeight : 0.0;
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: SakinaFonts.fallback,
        fontSize: size,
        fontWeight: weight,
        height: height < floor ? floor : height,
        letterSpacing: latin ? ls * size : 0,
        fontFeatures: tabular
            ? const <FontFeature>[FontFeature.tabularFigures()]
            : null,
      );
    }

    return SakinaType._(
      script: script,
      displayHero: s(d, 52, _w5, 1.0, ls: -0.02),
      displayLarge: s(d, 38, _w4, 1.1, ls: -0.015),
      displayMedium: s(d, 34, _w4, 1.15),
      headlineMedium: s(d, 28, _w5, 1.1),
      titleMedium: s(d, 20, _w5, 1.25),
      countdown: s(u, 30, _w6, 1.1, ls: -0.01, tabular: true),
      bodyLarge: s(u, 16, _w4, 1.55),
      bodyMedium: s(u, 15, _w4, 1.5),
      bodySmall: s(u, 14, _w4, 1.5),
      labelLarge: s(u, 13, _w6, 1.45),
      labelMedium: s(u, 12, _w6, 1.4),
      labelSmall: s(u, 11, _w6, 1.35),
      overline: s(u, 11, _w7, 1.3, ls: 0.14),
      // Fixed Arabic-script styles keep their own (already safe) heights.
      arabicAccent: s(a, 26, _w4, 1.3, scriptMinimum: false),
      arabicList: s(a, 15, _w4, 1.4, scriptMinimum: false),
      quranAyah: s(q, 26, _w4, 1.95, scriptMinimum: false),
      quranBismillah: s(q, 28, _w4, 1.9, scriptMinimum: false),
      quranBismillahHero: s(q, 34, _w4, 1.6, scriptMinimum: false),
      dua: s(q, 24, _w4, 1.8, scriptMinimum: false),
      urduTranslation: s(SakinaFonts.urdu, 15, _w4, 2.2, scriptMinimum: false),
    );
  }

  final UiScript script;
  final TextStyle displayHero;
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headlineMedium;
  final TextStyle titleMedium;
  final TextStyle countdown;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle overline;
  final TextStyle arabicAccent;
  final TextStyle arabicList;
  final TextStyle quranAyah;
  final TextStyle quranBismillah;
  final TextStyle quranBismillahHero;
  final TextStyle dua;
  final TextStyle urduTranslation;

  static SakinaType of(BuildContext context) =>
      Theme.of(context).extension<SakinaType>()!;

  /// A Material [TextTheme] built from this scale.
  TextTheme toTextTheme() => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineMedium: headlineMedium,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  @override
  SakinaType copyWith() => this;

  @override
  SakinaType lerp(SakinaType? other, double t) {
    // Locale switches are discrete; there is nothing meaningful between
    // two scripts' type scales.
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}
