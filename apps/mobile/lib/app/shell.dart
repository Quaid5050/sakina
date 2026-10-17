import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

/// Bottom navigation shell: Today, Quran, Family, More (TODAY-5).
///
/// [NavigationBar] gives each destination a 48 dp+ hit area, an accessible
/// label, and announces the current one as selected (TODAY-5 AC2).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again returns to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navQuran,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navFamily,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
