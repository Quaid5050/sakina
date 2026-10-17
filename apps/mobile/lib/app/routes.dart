/// Route paths. Deep links use the same paths, e.g.
/// `sakina://family/join?code=K7MQ2XRA` opens [familyJoin].
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String today = '/today';
  static const String quran = '/quran';
  static const String family = '/family';
  static const String familyJoin = '/family/join';
  static const String more = '/more';
  static const String ramadan = '/more/ramadan';
  static const String zakat = '/more/zakat';
  static const String travel = '/more/travel';
  static const String masjids = '/more/masjids';
  static const String plus = '/more/plus';
  static const String settings = '/more/settings';
  static const String adhanHealth = '/adhan-health';
}

/// The onboarding gate (ONB-2 AC6): until onboarding is complete, every
/// location leads to onboarding; afterwards onboarding is never shown again.
String? onboardingRedirect({
  required bool isOnboarded,
  required String location,
}) {
  final atOnboarding = location == Routes.onboarding;
  if (!isOnboarded) return atOnboarding ? null : Routes.onboarding;
  return atOnboarding ? Routes.today : null;
}
