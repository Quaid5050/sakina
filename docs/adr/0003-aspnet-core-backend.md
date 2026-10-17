# ADR-0003: ASP.NET Core 8 Web API with Clean Architecture

## Status
Accepted. The founder changed the backend stack from Django to ASP.NET Core on 2026-10-17, before any backend code existed, so no Django ADR was ever accepted and nothing needs migrating.

## Date
2026-10-17

## Context
The backend is small but security-sensitive. It handles accounts, family data that reveals religious practice (GDPR Art. 9 special category), child profiles, masjid administration, push fan-out, and a billing webhook. It must be strictly typed, testable with a real database, well supported long-term, and easy for builders, human and AI, to work in from a clear structure.

## Decision
- **ASP.NET Core 8 (LTS) Web API, C# 12** (see Consequences for the .NET 10 upgrade), controller-based rather than minimal APIs, so that `[ProducesResponseType]` metadata and filters keep the Swagger document complete for contract tests.
- **Clean Architecture** with four projects:
  - `Sakina.Domain`: entities, value objects, invariants, `Result`/`Error`. No dependencies.
  - `Sakina.Application`: one folder per bounded context with application services, DTOs, FluentValidation validators, and ports (interfaces).
  - `Sakina.Infrastructure`: EF Core, external clients (OneSignal, RevenueCat, rates, JWKS, email), background workers.
  - `Sakina.Api`: controllers, authentication and authorisation, ProblemDetails, rate limiting, Swashbuckle, health checks. Composition root.
- **Bounded contexts** as feature folders in each layer: Accounts, Families, WorshipSync, Masjids, Rates, Billing, Notifications. A context calls another only through that context's application interface. NetArchTest-based architecture tests enforce this.
- Cross-cutting libraries: **FluentValidation**, **Serilog** (JSON to stdout), **OpenTelemetry**, **Swashbuckle** (kept in sync with `docs/openapi.yaml`, ADR-0011), built-in **rate limiting** middleware, **health checks** (`AspNetCore.HealthChecks.NpgSql`).
- Tests: **xUnit** with **FluentAssertions 7.x** (Apache-2.0; v8+ needs a commercial licence, see SPEC D-19), **NSubstitute**, and **Testcontainers for PostgreSQL** with `WebApplicationFactory` for integration tests. **WireMock.Net** stubs external HTTP.
- The build has `Nullable` enabled, `TreatWarningsAsErrors`, and the analyzers `Microsoft.CodeAnalysis.NetAnalyzers` (latest-recommended), all set in `Directory.Build.props`. Central package management via `Directory.Packages.props`.

## Alternatives considered
- **Django + DRF.** This was the original plan, and the founder replaced it. Python's dynamic typing gives weaker compile-time guarantees across a contract-heavy API.
- **Minimal APIs.** They're lighter, but endpoint metadata for Swagger and per-endpoint filters drift more easily, and grouping 89 operations reads better as controllers.
- **Vertical-slice architecture (one folder per feature with no layers).** It's attractive, but Clean Architecture was requested, and it keeps external integrations behind ports, which suits the privacy review. Inside each layer we still organise by feature.
- **ASP.NET Core Identity.** Considered and rejected for user management: see ADR-0008. We use `PasswordHasher<T>` from Identity's core only.

## Consequences
- Builders need the .NET 8 SDK. The planning environment had no SDK, so CI (`.github/workflows/backend.yml`) is the first verification path. Task B0 must get the solution building and the CI green before any feature work starts.
- Clean Architecture adds some ceremony (DTO ↔ entity mapping, ports). We accept it, and keep mapping hand-written (no AutoMapper) so it stays explicit.
- **.NET 8 support ends 10 November 2026**, about three weeks after this ADR and before the February 2027 launch. **.NET 10 (LTS, GA since November 2025) is the supported successor.** The founder specified ".NET 8 LTS", so 8 stays the baseline for B0. PLAN task **B13 (upgrade to net10.0) is mandatory before launch**, and the recommendation to the founder is to start on net10.0 directly. The code avoids preview and deprecated APIs so the upgrade stays mechanical: change the TFM, bump the packages, re-run CI. Record the move in a superseding ADR.
