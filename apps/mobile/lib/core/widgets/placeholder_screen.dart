import 'package:flutter/material.dart';
import 'package:sakina_mobile/core/design/tokens.dart';
import 'package:sakina_mobile/l10n/app_localizations.dart';

/// A screen whose feature has not been built yet. It is honest with the
/// user ("Coming soon") instead of showing an empty page.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, this.detail, super.key});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(Space.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(l10n.comingSoon, style: textTheme.titleMedium),
              if (detail != null) ...<Widget>[
                const SizedBox(height: Space.s2),
                Text(detail!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
