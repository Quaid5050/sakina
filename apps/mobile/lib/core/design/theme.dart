import 'package:flutter/material.dart';
import 'package:sakina_mobile/core/design/tokens.dart';
import 'package:sakina_mobile/core/design/typography.dart';

/// Builds the app theme for a UI locale (ARCHITECTURE §3.6).
///
/// The designs have no system-wide dark theme (DESIGN_TOKENS §2.6), so the
/// app follows the designs in both system modes.
ThemeData buildSakinaTheme(Locale locale) {
  final type = SakinaType.forLocale(locale);
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: SakinaPalette.nightTeal,
    onPrimary: SakinaPalette.sand,
    secondary: SakinaPalette.dawnGold,
    onSecondary: SakinaPalette.ink,
    tertiary: SakinaPalette.roseDawn,
    onTertiary: SakinaPalette.ink,
    error: SakinaPalette.chipDangerText,
    onError: SakinaPalette.sand,
    surface: SakinaPalette.raised,
    onSurface: SakinaPalette.ink,
    onSurfaceVariant: SakinaPalette.textSecondary,
    outline: SakinaPalette.lineCellA11y,
    outlineVariant: SakinaPalette.lineSubtle,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: SakinaPalette.background,
    fontFamily: type.bodyMedium.fontFamily,
    fontFamilyFallback: SakinaFonts.fallback,
    textTheme: type.toTextTheme(),
    extensions: <ThemeExtension<dynamic>>[type],
    materialTapTargetSize: MaterialTapTargetSize.padded,
    splashFactory: InkRipple.splashFactory,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SakinaPalette.raised,
      indicatorColor: SakinaPalette.sunken,
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(type.labelSmall),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Hit.primaryButton),
        shape: const StadiumBorder(),
        textStyle: type.bodyLarge.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Hit.secondaryButton),
        shape: const StadiumBorder(),
        foregroundColor: SakinaPalette.nightTeal,
        side: const BorderSide(color: SakinaPalette.nightTeal, width: 1.5),
        textStyle: type.bodyMedium.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(Hit.min, Hit.min),
        foregroundColor: SakinaPalette.nightTeal,
        textStyle: type.bodySmall.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
