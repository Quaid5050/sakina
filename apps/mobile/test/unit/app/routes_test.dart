import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/app/routes.dart';

void main() {
  group('onboardingRedirect', () {
    test('sends an un-onboarded user to onboarding from anywhere', () {
      for (final location in <String>[
        Routes.today,
        Routes.quran,
        Routes.familyJoin,
        Routes.zakat,
      ]) {
        expect(
          onboardingRedirect(isOnboarded: false, location: location),
          Routes.onboarding,
          reason: location,
        );
      }
    });

    test('lets an un-onboarded user stay on onboarding', () {
      expect(
        onboardingRedirect(isOnboarded: false, location: Routes.onboarding),
        isNull,
      );
    });

    test('never shows onboarding again once complete', () {
      expect(
        onboardingRedirect(isOnboarded: true, location: Routes.onboarding),
        Routes.today,
      );
      expect(
        onboardingRedirect(isOnboarded: true, location: Routes.familyJoin),
        isNull,
      );
    });
  });
}
