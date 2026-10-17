import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';

/// UI languages at launch (SPEC §5.4). Urdu and Arabic are right-to-left.
const List<Locale> sakinaLocales = <Locale>[
  Locale('en'),
  Locale('ur'),
  Locale('ar'),
];

bool isRtlLanguage(String languageCode) =>
    languageCode == 'ar' || languageCode == 'ur';

/// The UI language, persisted on the device. Changing it rebuilds the app
/// immediately, which flips text direction for Urdu and Arabic (ONB-3 AC2).
class LocaleController extends Notifier<Locale> {
  static const String storageKey = 'ui.locale';

  @override
  Locale build() {
    final code = ref.watch(keyValueStoreProvider).getString(storageKey);
    return sakinaLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => sakinaLocales.first,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!sakinaLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'not a supported UI locale');
    }
    state = locale;
    await ref.read(keyValueStoreProvider).setString(
      storageKey,
      locale.languageCode,
    );
  }
}

final NotifierProvider<LocaleController, Locale> localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
