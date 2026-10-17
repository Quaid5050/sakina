import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Colour tokens from docs/DESIGN_TOKENS.md §1–2. Values are tested against
/// that file in test/unit/core/design/tokens_test.dart.
///
/// Where a design value fails WCAG AA for meaningful UI, the accessible
/// replacement from §2.4 is the one to use (`*A11y`).
abstract final class SakinaPalette {
  // Brand (§1)
  static const Color nightTeal = Color(0xFF0F3D3E);
  static const Color dawnGold = Color(0xFFE2B04A);
  static const Color sand = Color(0xFFF4EDE1);
  static const Color ink = Color(0xFF1C1B19);
  static const Color roseDawn = Color(0xFFD98C6A);

  // Surfaces (§2.1)
  static const Color background = sand;
  static const Color raised = Color(0xFFFBF7F0);
  static const Color sunken = Color(0xFFEDE3D2);
  static const Color segmented = Color(0xFFEFE6D6);
  static const Color hero = nightTeal;
  static const Color night = Color(0xFF0B2C2D);
  static const Color warning = Color(0xFFF7E7C6);
  static const Color warningSubtle = Color(0xFFFBF1DC);
  static const Color successChip = Color(0xFFDCE9E4);
  static const Color dangerChip = Color(0xFFF3D9CC);
  static const Color inputEdited = Color(0xFFFFFFFF);

  // Text (§2.2)
  static const Color textPrimary = ink;
  static const Color textStrong = Color(0xFF3D3A34);
  static const Color textSecondary = Color(0xFF5A544B);
  static const Color textTertiary = Color(0xFF6B655B);
  static const Color accentBrown = Color(0xFF8A5A1E);
  static const Color onDark = sand;
  static const Color onDarkSecondary = Color(0xFFD9D2C4);
  static const Color onDarkTertiary = Color(0xFFC9C1B1);
  static const Color onDarkMuted = Color(0xFF8FA3A1);
  static const Color textGold = dawnGold;
  static const Color onGold = ink;
  static const Color link = nightTeal;
  static const Color linkOnDark = dawnGold;
  static const Color textSuccessOnDark = Color(0xFF8FD1B5);
  static const Color chipDangerText = Color(0xFF7A3418);
  static const Color chipSuccessText = nightTeal;
  static const Color chipWarningText = Color(0xFF6B4510);

  /// Only for hidden memorisation words and disabled states (exempt).
  static const Color textDisabled = Color(0xFF8A8273);

  // Lines, states and data (§2.3)
  static const Color lineDivider = Color(0xFFECE3D3);
  static const Color lineSubtle = Color(0xFFE6DCCB);
  static const Color lineInput = Color(0xFFDCCFB9);
  static const Color lineControl = Color(0xFFD9CBB3);
  static const Color ringTrack = Color(0xFFE2D6C2);
  static const Color stateLive = Color(0xFF2F8F6A);
  static const Color dataPrayed = nightTeal;
  static const Color dataPrayedLate = dawnGold;
  static const Color dataZakatFund = roseDawn;

  // Accessibility corrections (§2.4). Use these, not the design originals
  // (#C9BDA8, #B8AD9A, #C98F1E), whenever the element carries meaning.
  static const Color lineCellA11y = Color(0xFF968A75);
  static const Color lineRadioA11y = Color(0xFF968A75);
  static const Color warningA11y = Color(0xFFA87514);
}

/// Spacing scale (§4): a 2 px base with a 4 px rhythm. `s05` is token
/// `space.0_5`, `s15` is `space.1_5`, and so on.
abstract final class Space {
  static const double s05 = 2;
  static const double s1 = 4;
  static const double s15 = 6;
  static const double s2 = 8;
  static const double s25 = 10;
  static const double s3 = 12;
  static const double s35 = 14;
  static const double s4 = 16;
  static const double s45 = 18;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s12 = 48;

  /// Horizontal screen gutter on most screens.
  static const double gutter = s5;

  /// Onboarding gutter.
  static const double gutterOnboarding = s7;
}

/// Corner radii (§5).
abstract final class Radii {
  static const double xs = 4;
  static const double s = 8;
  static const double cell = 6;
  static const double m = 12;
  static const double row = 14;
  static const double tile = 16;
  static const double card = 18;
  static const double content = 20;
  static const double feature = 22;
  static const double panel = 24;
  static const double hero = 32;
  static const double pill = 999;
}

/// Minimum interactive sizes (SPEC §5.5, DESIGN_TOKENS §7).
abstract final class Hit {
  /// Android minimum (48 dp). Also satisfies iOS 44 pt.
  static const double min = 48;
  static const double primaryButton = 56;
  static const double secondaryButton = 52;
}

/// Motion (§8). Every duration becomes zero when the platform asks to
/// disable animations; use [resolve].
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 400);
  static const Curve fastCurve = Curves.easeOut;
  static const Curve baseCurve = Curves.easeInOut;
  static const Curve slowCurve = Curves.easeInOutCubic;

  static Duration resolve(Duration duration, {required bool disabled}) =>
      disabled ? Duration.zero : duration;
}

/// WCAG 2.x contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
