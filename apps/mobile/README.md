# Sakina mobile (Flutter)

This is a placeholder. Track M task **M0** in `docs/PLAN.md` creates the Flutter project here with `flutter create --org app.sakina --platforms ios,android,web sakina_mobile .`. Web is enabled for the masjid console later.

Read these before writing code:

- `docs/ARCHITECTURE.md` §3, Mobile architecture: feature-first clean architecture, Riverpod, go_router, Drift, the sync outbox
- `docs/DESIGN_TOKENS.md`: colours, type, spacing and radii, to be mapped to `ThemeData` and `ThemeExtension`s
- `docs/openapi.yaml`: the only backend contract. Don't depend on behaviour the contract doesn't describe.
- `docs/adr/0007-on-device-prayer-computation-and-location-privacy.md`: location must never be sent anywhere

Commands (from the repo root):

```sh
make mobile-get
make mobile-analyze   # dart format --set-exit-if-changed + flutter analyze
make mobile-test      # flutter test --coverage
```

Until the backend is deployed, run against a mock server generated from `docs/openapi.yaml` (see PLAN.md M0.4).
