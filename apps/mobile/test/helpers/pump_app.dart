import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakina_mobile/core/design/theme.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

/// Pumps [child] inside a localised, themed MaterialApp with a fresh
/// in-memory store, so widget tests never touch real platform storage.
Future<ProviderContainer> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  List<Override> overrides = const <Override>[],
  KeyValueStore? store,
  double textScale = 1,
}) async {
  final container = ProviderContainer.test(
    overrides: <Override>[
      keyValueStoreProvider.overrideWithValue(store ?? InMemoryKeyValueStore()),
      ...overrides,
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildSakinaTheme(locale),
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: inner!,
        ),
        home: child,
      ),
    ),
  );
  return container;
}
