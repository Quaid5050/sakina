import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sakina_mobile/app/app.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';

/// Starts the app. Flavours and tests pass [overrides] to swap repositories
/// and platform services (Riverpod providers are the DI container).
Future<void> bootstrap({List<Override> overrides = const <Override>[]}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SharedPreferencesStore.create();
  runApp(
    ProviderScope(
      overrides: <Override>[
        keyValueStoreProvider.overrideWithValue(store),
        ...overrides,
      ],
      child: const SakinaApp(),
    ),
  );
}
