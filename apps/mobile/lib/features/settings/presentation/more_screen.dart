import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakina_mobile/app/routes.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

/// The "More" tab (TODAY-5 AC1).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <(String, IconData, String)>[
      (l10n.moreRamadan, Icons.nightlight_outlined, Routes.ramadan),
      (l10n.moreZakat, Icons.calculate_outlined, Routes.zakat),
      (l10n.moreTravel, Icons.explore_outlined, Routes.travel),
      (l10n.moreMasjids, Icons.mosque, Routes.masjids),
      (l10n.morePlus, Icons.family_restroom, Routes.plus),
      (l10n.moreSettings, Icons.settings_outlined, Routes.settings),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: <Widget>[
          for (final (label, icon, route) in entries)
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              minTileHeight: 56,
              onTap: () => context.push(route),
            ),
        ],
      ),
    );
  }
}
