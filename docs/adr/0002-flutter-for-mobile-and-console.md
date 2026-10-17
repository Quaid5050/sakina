# ADR-0002: Flutter for the mobile app and masjid console

## Status
Accepted (stack fixed by the founder; this ADR records the reasoning and the constraints)

## Date
2026-10-17

## Context
Sakina needs iOS and Android apps with identical behaviour, careful typography (Arabic Uthmani script, Urdu Nastaliq, Latin serif and sans), full RTL support, deep platform integration for adhan reliability (exact alarms, battery-optimisation probes, notification channels), offline storage, and later a web console for masjids that uses the same brand.

## Decision
- The mobile app is **Flutter (stable channel, 3.x) and Dart 3**, for iOS and Android.
- The **masjid console is a Flutter web build from the same project** (`lib/main_console.dart`), deployed to its own origin. It reuses `core/design`, `core/network` and `features/masjids/data`.
- Platform-specific reliability code (Android `AlarmManager`, `PowerManager`, OEM settings intents, notification channels; iOS notification settings) lives behind a `MethodChannel` in `core/platform`, with a Dart interface that can be faked in tests.
- State management: Riverpod. Navigation: go_router. Local DB: Drift. These choices and their rationale are in ARCHITECTURE §3.

## Alternatives considered
- **Native Swift + Kotlin.** The best platform fidelity, but twice the UI work and two implementations of the prayer, zakat and scheduling logic. Rejected because of team size and the launch date.
- **React Native.** It is viable, but complex-script rendering in Flutter is more consistent across Android OEMs. It would also split the stack further.
- **A separate web framework for the console (React/Next).** The console would get a better web experience (SEO doesn't matter for an authenticated console). Rejected for MVP: reusing the design system and API client in Flutter web is cheaper. We'll revisit if Flutter web performance or accessibility proves inadequate. The console is a data-entry app, which Flutter web handles acceptably.

## Consequences
- One codebase and one design-system implementation (DESIGN_TOKENS → `ThemeExtension`s).
- Android adhan reliability still needs native Kotlin, kept small and wrapped behind a Dart interface.
- Flutter web uses CanvasKit/Skwasm. The console must be checked with screen readers (semantics tree enabled) and keyboard navigation. If accessibility is not good enough, write a new ADR to move the console to a web framework. The API contract makes that swap cheap.
- Bundled fonts (OFL) add about 6–8 MB to the app. That is acceptable, and required by the privacy pledge, since there are no runtime Google Fonts fetches.
- pub.dev packages must pass the no-phone-home review (CONTRIBUTING §6).
