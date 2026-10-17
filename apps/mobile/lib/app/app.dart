import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakina_mobile/app/router.dart';
import 'package:sakina_mobile/core/design/theme.dart';
import 'package:sakina_mobile/core/l10n/locale_controller.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

/// The root widget of the mobile app.
class SakinaApp extends ConsumerWidget {
  const SakinaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildSakinaTheme(locale),
    );
  }
}
