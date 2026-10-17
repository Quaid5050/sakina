import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/core/l10n/locale_controller.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';

ProviderContainer _container(InMemoryKeyValueStore store) =>
    ProviderContainer.test(
      overrides: [keyValueStoreProvider.overrideWithValue(store)],
    );

void main() {
  test('defaults to English when nothing is stored', () {
    final container = _container(InMemoryKeyValueStore());
    expect(container.read(localeControllerProvider), const Locale('en'));
  });

  test('ignores an unsupported stored language', () {
    final store = InMemoryKeyValueStore({LocaleController.storageKey: 'id'});
    final container = _container(store);
    expect(container.read(localeControllerProvider), const Locale('en'));
  });

  test('persists the chosen language', () async {
    final store = InMemoryKeyValueStore();
    final container = _container(store);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('ar'));

    expect(container.read(localeControllerProvider), const Locale('ar'));
    expect(store.getString(LocaleController.storageKey), 'ar');
  });

  test('rejects languages that are not offered yet', () async {
    final container = _container(InMemoryKeyValueStore());
    await expectLater(
      container
          .read(localeControllerProvider.notifier)
          .setLocale(const Locale('id')),
      throwsArgumentError,
    );
  });

  test('Urdu and Arabic are right-to-left, English is not', () {
    expect(isRtlLanguage('ur'), isTrue);
    expect(isRtlLanguage('ar'), isTrue);
    expect(isRtlLanguage('en'), isFalse);
  });
}
