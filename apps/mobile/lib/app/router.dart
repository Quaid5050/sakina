import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakina_mobile/app/routes.dart';
import 'package:sakina_mobile/app/shell.dart';
import 'package:sakina_mobile/core/widgets/placeholder_screen.dart';
import 'package:sakina_mobile/features/onboarding/presentation/onboarding_status.dart';
import 'package:sakina_mobile/features/settings/presentation/more_screen.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects when onboarding completes, without rebuilding the router
  // (which would reset navigation state).
  final refresh = ValueNotifier<int>(0);
  ref.listen<bool>(onboardingStatusProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.today,
    refreshListenable: refresh,
    redirect: (context, state) => onboardingRedirect(
      isOnboarded: ref.read(onboardingStatusProvider),
      location: state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const _Titled(_Title.appTitle),
      ),
      GoRoute(
        path: Routes.adhanHealth,
        builder: (context, state) => const _Titled(_Title.appTitle),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const _Titled(_Title.today),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.quran,
                builder: (context, state) => const _Titled(_Title.quran),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.family,
                builder: (context, state) => const _Titled(_Title.family),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'join',
                    builder: (context, state) => _FamilyJoinPlaceholder(
                      code: state.uri.queryParameters['code'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.more,
                builder: (context, state) => const MoreScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'ramadan',
                    builder: (context, state) => const _Titled(_Title.ramadan),
                  ),
                  GoRoute(
                    path: 'zakat',
                    builder: (context, state) => const _Titled(_Title.zakat),
                  ),
                  GoRoute(
                    path: 'travel',
                    builder: (context, state) => const _Titled(_Title.travel),
                  ),
                  GoRoute(
                    path: 'masjids',
                    builder: (context, state) => const _Titled(_Title.masjids),
                  ),
                  GoRoute(
                    path: 'plus',
                    builder: (context, state) => const _Titled(_Title.plus),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const _Titled(_Title.settings),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

enum _Title {
  appTitle,
  today,
  quran,
  family,
  ramadan,
  zakat,
  travel,
  masjids,
  plus,
  settings,
}

class _Titled extends StatelessWidget {
  const _Titled(this.title);

  final _Title title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (title) {
      _Title.appTitle => l10n.appTitle,
      _Title.today => l10n.navToday,
      _Title.quran => l10n.navQuran,
      _Title.family => l10n.navFamily,
      _Title.ramadan => l10n.moreRamadan,
      _Title.zakat => l10n.moreZakat,
      _Title.travel => l10n.moreTravel,
      _Title.masjids => l10n.moreMasjids,
      _Title.plus => l10n.morePlus,
      _Title.settings => l10n.moreSettings,
    };
    return PlaceholderScreen(title: text);
  }
}

class _FamilyJoinPlaceholder extends StatelessWidget {
  const _FamilyJoinPlaceholder({required this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScreen(
      title: l10n.navFamily,
      detail: code == null ? null : l10n.familyJoinCode(code!),
    );
  }
}
