# Sakina backend (ASP.NET Core 8)

This is a placeholder. Track B task **B0** in `docs/PLAN.md` creates the solution here:

```
apps/backend/
  Sakina.sln
  global.json                 # pins SDK 8.0.x (rollForward: latestFeature)
  Directory.Build.props       # nullable, TreatWarningsAsErrors, analyzers, LangVersion
  Directory.Packages.props    # central package versions
  .config/dotnet-tools.json   # dotnet-ef, reportgenerator
  src/
    Sakina.Domain/            # entities, value objects, domain errors; no dependencies
    Sakina.Application/       # application services per bounded context, DTOs, validators, ports
    Sakina.Infrastructure/    # EF Core (Npgsql), migrations, OneSignal, RevenueCat, rates provider, auth token issuing
    Sakina.Api/               # controllers, auth, ProblemDetails, rate limiting, Swagger, health checks
  tests/
    Sakina.UnitTests/         # xUnit + FluentAssertions (+ NSubstitute)
    Sakina.IntegrationTests/  # WebApplicationFactory + Testcontainers (postgres:16-alpine)
```

Bounded contexts are feature folders inside each layer: `Accounts`, `Families`, `WorshipSync`, `Masjids`, `Rates`, `Billing`, `Notifications`.

Read these before writing code: `docs/ARCHITECTURE.md` §4, `docs/openapi.yaml`, `docs/adr/0003`–`0006`, `0008`.

Configuration comes only from environment variables (`ConnectionStrings__Default`, `Jwt__SigningKey`, `OneSignal__ApiKey`, …). The full list is in ARCHITECTURE.md §4.7. Never commit secrets.

```sh
make backend-test   # dotnet test (Docker required for integration tests)
make backend-lint   # dotnet format --verify-no-changes
```
