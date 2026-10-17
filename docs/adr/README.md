# Architecture Decision Records

ADRs record decisions that would be expensive to reverse. Use the lightweight MADR format: Status, Date, Context, Decision, Alternatives considered, Consequences.

- File name: `NNNN-kebab-title.md`, numbered sequentially.
- Never delete or rewrite an accepted ADR. To change a decision, write a new ADR that **supersedes** it, and update the old one's status line to `Superseded by ADR-NNNN`.
- Statuses: `Proposed` → `Accepted` → (`Superseded` | `Deprecated`).

| # | Title | Status |
|---|---|---|
| [0001](0001-monorepo.md) | Single monorepo with two independent tracks | Accepted |
| [0002](0002-flutter-for-mobile-and-console.md) | Flutter for the mobile app and masjid console | Accepted |
| [0003](0003-aspnet-core-backend.md) | ASP.NET Core 8 Web API with Clean Architecture | Accepted |
| [0004](0004-postgresql-no-baas.md) | PostgreSQL 16, self-managed schema, no Supabase/BaaS | Accepted |
| [0005](0005-onesignal-push.md) | OneSignal for push, server-driven via REST | Accepted |
| [0006](0006-revenuecat-subscriptions.md) | RevenueCat for subscriptions and entitlements | Accepted |
| [0007](0007-on-device-prayer-computation-and-location-privacy.md) | On-device prayer computation; location never leaves the device | Accepted |
| [0008](0008-jwt-auth-with-rotating-refresh-tokens.md) | JWT access tokens, rotating refresh tokens, Google/Apple sign-in | Accepted |
| [0009](0009-ef-core-npgsql-code-first.md) | EF Core 8 + Npgsql with code-first migrations | Accepted |
| [0010](0010-problem-details-and-api-conventions.md) | ProblemDetails errors and REST conventions | Accepted |
| [0011](0011-contract-first-openapi.md) | Contract-first OpenAPI; two tracks meet only at the contract | Accepted |
| [0012](0012-plain-application-services-not-mediatr.md) | Plain application services instead of MediatR | Accepted |
| [0013](0013-offline-first-drift-and-outbox.md) | Offline-first mobile storage with Drift and a sync outbox | Accepted |
| [0014](0014-transactional-outbox-for-side-effects.md) | Transactional outbox for backend side effects | Accepted |
