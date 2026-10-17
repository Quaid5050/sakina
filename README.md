# Sakina

A privacy-first Muslim companion app for prayer times, adhan, Quran and family worship, with Ramadan, zakat and travel tools, and a console for masjids.

**The Amanah pledge** is the product's main constraint, and every technical decision is checked against it:

1. No ads, ever.
2. Location never leaves the device. Prayer times and Qibla are computed on the phone.
3. Worship features are free forever. Sakina Plus pays for convenience and family features only.
4. Only data the user explicitly chooses to sync (Family, Plus sync) reaches our servers. No tracking SDKs.

## Repository layout

```
apps/
  mobile/     Flutter app (iOS + Android); masjid console later as a Flutter web target
  backend/    ASP.NET Core 8 Web API (Clean Architecture), PostgreSQL via EF Core
docs/
  SPEC.md            Product spec: MVP scope, user stories, acceptance criteria, NFRs
  ARCHITECTURE.md    System, mobile and backend architecture, ERD, security, observability
  API.md             REST conventions and endpoint guide
  openapi.yaml       OpenAPI 3.1 contract — the single source of truth between tracks
  PLAN.md            Ordered TDD task breakdown, two parallel tracks
  DESIGN_TOKENS.md   Colours, type, spacing and radii extracted from the designs
  adr/               Architecture Decision Records
.github/workflows/   CI: backend.yml, mobile.yml, contract.yml
```

## Quick start

Prerequisites: .NET SDK 8.0.x, Flutter stable (3.x), Docker (for Testcontainers / local Postgres), GNU Make.

```sh
make help              # list targets
make backend-test      # dotnet test (unit + integration; integration needs Docker)
make backend-lint      # dotnet format --verify-no-changes
make mobile-test       # flutter test
make mobile-analyze    # dart format check + flutter analyze
make api-lint          # lint docs/openapi.yaml (needs Node)
```

Local backend run (after Track B task B0 lands):

```sh
docker run -d --name sakina-pg -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:16-alpine
export ConnectionStrings__Default="Host=localhost;Database=sakina;Username=postgres;Password=dev"
make backend-run
```

## Commands

| Command | What it does |
|---|---|
| `make backend-restore` | `dotnet restore` the solution |
| `make backend-build` | `dotnet build` with warnings as errors |
| `make backend-test` | `dotnet test` with coverage collection |
| `make backend-lint` | `dotnet format --verify-no-changes` |
| `make backend-run` | Run `Sakina.Api` locally |
| `make mobile-get` | `flutter pub get` |
| `make mobile-test` | `flutter test --coverage` |
| `make mobile-analyze` | `dart format --set-exit-if-changed` + `flutter analyze` |
| `make api-lint` | Redocly lint of `docs/openapi.yaml` |

## Where to start reading

1. `docs/SPEC.md` — what we are building and how we know it is done.
2. `docs/adr/` — why the stack looks the way it does.
3. `docs/ARCHITECTURE.md` — how the pieces fit.
4. `docs/openapi.yaml` + `docs/API.md` — the contract between mobile and backend.
5. `docs/PLAN.md` — which task to pick up next.
6. `CONTRIBUTING.md` — TDD workflow, branches and commits.

## Status

Architecture and contract phase. No application code yet. Launch target: Ramadan 1448 (expected around 8 February 2027, subject to moonsighting).
