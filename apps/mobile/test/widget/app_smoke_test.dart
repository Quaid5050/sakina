import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/app/app.dart';
import 'package:sakina_mobile/core/l10n/locale_controller.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  KeyValueStore? store,
}) async {
  final container = ProviderContainer.test(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store ?? InMemoryKeyValueStore()),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SakinaApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

TextDirection _direction(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));

void main() {
  testWidgets('the app boots and shows the Sakina wordmark', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Sakina'), findsOneWidget);
    expect(_direction(tester), TextDirection.ltr);
  });

  testWidgets('choosing Arabic switches the app to RTL immediately', (
    tester,
  ) async {
    final container = await _pumpApp(tester);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('ar'));
    await tester.pumpAndSettle();

    expect(_direction(tester), TextDirection.rtl);
    expect(find.text('سكينة'), findsOneWidget);
  });

  testWidgets('choosing Urdu switches the app to RTL immediately', (
    tester,
  ) async {
    final container = await _pumpApp(tester);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('ur'));
    await tester.pumpAndSettle();

    expect(_direction(tester), TextDirection.rtl);
  });

  testWidgets('the chosen language is restored on the next launch', (
    tester,
  ) async {
    final store = InMemoryKeyValueStore({LocaleController.storageKey: 'ur'});

    await _pumpApp(tester, store: store);

    expect(_direction(tester), TextDirection.rtl);
    expect(find.text('سکینہ'), findsOneWidget);
  });
}
