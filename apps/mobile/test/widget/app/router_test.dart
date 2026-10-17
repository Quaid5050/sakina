import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/app/app.dart';
import 'package:sakina_mobile/app/router.dart';
import 'package:sakina_mobile/app/routes.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';
import 'package:sakina_mobile/features/onboarding/presentation/onboarding_status.dart';

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required bool onboarded,
}) async {
  final store = InMemoryKeyValueStore({
    if (onboarded) OnboardingStatus.storageKey: true,
  });
  final container = ProviderContainer.test(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SakinaApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

String _location(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

void main() {
  testWidgets('an un-onboarded user lands on onboarding', (tester) async {
    final container = await _pumpApp(tester, onboarded: false);

    expect(_location(container), Routes.onboarding);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('an onboarded user lands on Today with four tabs', (
    tester,
  ) async {
    final container = await _pumpApp(tester, onboarded: true);

    expect(_location(container), Routes.today);
    final bar = find.byType(NavigationBar);
    for (final label in <String>['Today', 'Quran', 'Family', 'More']) {
      expect(
        find.descendant(of: bar, matching: find.text(label)),
        findsOneWidget,
      );
    }
  });

  testWidgets('completing onboarding re-runs the redirect', (tester) async {
    final container = await _pumpApp(tester, onboarded: false);

    await container.read(onboardingStatusProvider.notifier).markComplete();
    container.read(routerProvider).go(Routes.onboarding);
    await tester.pumpAndSettle();

    expect(_location(container), Routes.today);
  });

  testWidgets('the family invite deep link opens the join screen', (
    tester,
  ) async {
    final container = await _pumpApp(tester, onboarded: true);

    container.read(routerProvider).go('/family/join?code=K7MQ2XRA');
    await tester.pumpAndSettle();

    expect(find.text('Invite code: K7MQ2XRA'), findsOneWidget);
  });

  testWidgets('tabs switch branches and the current tab is selected', (
    tester,
  ) async {
    final container = await _pumpApp(tester, onboarded: true);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('More'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_location(container), Routes.more);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });

  testWidgets('bottom nav meets tap-target and labelling guidelines', (
    tester,
  ) async {
    await _pumpApp(tester, onboarded: true);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
