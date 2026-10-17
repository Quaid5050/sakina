# Contributing to Sakina

These rules apply to humans and AI agents alike.

## 1. Ground rules

- **The contract comes first.** `docs/openapi.yaml` is the only interface between mobile and backend. Change it in its own PR, with an `api:` commit, *before* any code that depends on the change. Backward-compatible additions only within `/api/v1`. See `docs/adr/0011-contract-first-openapi.md`.
- **The Amanah pledge is a merge blocker.** A PR fails review if it adds an analytics, ads or attribution SDK, sends location (or anything derived from it finer than the coarse cell in ADR-0007) to any server, logs request bodies or query strings that could contain personal data, or puts a worship feature behind a paywall.
- **Specs before code.** Every PR links the `docs/SPEC.md` story ID (e.g. `TODAY-3`) or `docs/PLAN.md` task ID (e.g. `B4.2`) it implements.
- **No secrets in git.** Configuration comes from environment variables. `.env.example` files list names only.

## 2. TDD workflow (required)

Every behaviour change follows **red, green, refactor**:

1. **Red.** Write a failing test that expresses one acceptance criterion from the spec or plan. Run it and watch it fail for the right reason.
2. **Green.** Write the least production code that makes it pass.
3. **Refactor.** Clean up with the tests green. No behaviour changes in this step.
4. Repeat for the next criterion. Commit at each green step, or at least once per task.

Bug fixes use the **prove-it pattern**: first a test that reproduces the bug (red), then the fix (green). The test stays in the suite forever.

### Test levels

| Level | Backend (.NET) | Mobile (Flutter) |
|---|---|---|
| Unit | `Sakina.UnitTests`: domain rules, application services with fakes, validators. xUnit + FluentAssertions + NSubstitute | `test/unit/**`: domain use cases, repositories with fakes, prayer-time and zakat maths |
| Integration | `Sakina.IntegrationTests`: real HTTP through `WebApplicationFactory`, real Postgres via Testcontainers, external HTTP (OneSignal, RevenueCat, rates) stubbed with WireMock.Net | `test/integration/**`: Drift with in-memory SQLite, Dio against a mock adapter, the sync outbox |
| Widget | n/a | `test/widget/**`: each screen's acceptance criteria, including RTL and a text scale of 2.0 |
| Contract | `OpenApiContractTests`: the generated Swagger document matches `docs/openapi.yaml` (paths, methods, status codes, schema names) | JSON fixtures in `test/fixtures/api/` validated against `docs/openapi.yaml` schemas |
| Golden | n/a | Key screens in EN and AR (RTL) at 390×844 |

Every endpoint needs, at minimum, an integration test for the happy path, a 401 test, a validation (422) test, and a **cross-tenant test** proving that user A gets a 404 for user B's resources. ARCHITECTURE.md §5.2 has the full matrix.

Coverage gates in CI: backend at least 80% line coverage on `Sakina.Domain` + `Sakina.Application`; mobile at least 80% on `lib/features/*/domain` and `lib/core`. Coverage is a floor, not a goal. Don't write tests only to raise it.

## 3. Branches

- `main` is always releasable and protected: PRs only, CI green, one approving review, linear history (squash merge).
- Branch names: `<type>/<task-id>-<short-slug>`, e.g. `feat/B3.1-family-create`, `fix/M2.4-adhan-dst`, `api/families-invite-expiry`, `docs/adr-0013-hijri`.
- Keep branches short-lived (≤ 2 days). Rebase on `main` before opening a PR.
- **Two tracks.** Backend PRs touch only `apps/backend/**`, mobile PRs only `apps/mobile/**`. Contract PRs touch only `docs/openapi.yaml` and `docs/API.md`, and need one reviewer from each track.

## 4. Commits

[Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <imperative summary, ≤ 72 chars>

<body: why, not what. Reference SPEC/PLAN IDs.>

<trailers>
```

- **Types:** `feat`, `fix`, `test`, `refactor`, `perf`, `docs`, `api` (contract change), `build`, `ci`, `chore`.
- **Scopes:** `backend`, `mobile`, `console`, `contract`, `docs`, `ci`, or a bounded context (`families`, `masjids`, …).
- One logical change per commit. Tests and the code they cover go in the same commit.
- Breaking contract changes are not allowed in v1. If one is truly unavoidable, it needs `BREAKING CHANGE:` in the footer and a new ADR.

Examples:

```
feat(families): join a family with an invite code (B3.3)
test(mobile): Today shows next prayer countdown offline (M2.2)
api(contract): add nextCursor to GET /masjids/{id}/announcements
```

## 5. Pull requests

A PR must:

- link its SPEC story and PLAN task
- include the tests, showing they would fail without the change
- pass CI (`backend.yml` / `mobile.yml` / `contract.yml`, depending on the paths touched)
- update docs in the same PR when behaviour, configuration or the contract changes
- add an ADR in `docs/adr/` for any decision that is expensive to reverse (new dependency, schema shape, auth or crypto change)

Before pushing, run locally:

```sh
make backend-lint backend-test     # backend PRs
make mobile-analyze mobile-test    # mobile PRs
make api-lint                      # contract PRs
```

## 6. Adding dependencies

Ask first, and record the reason in the PR. Mobile packages must not phone home. Before adding any package, check its README and source for analytics, ad IDs and remote config. Banned outright: Firebase Analytics, Crashlytics, Facebook SDK, AppsFlyer, Adjust, Branch, Google Mobile Ads, and any SDK that collects the advertising ID. Backend packages go into `Directory.Packages.props` with pinned versions.

## 7. Code style

- **C#:** `.editorconfig` and `dotnet format` decide. File-scoped namespaces, nullable enabled, warnings are errors, `CancellationToken` on every async path, no `async void`. Controllers stay thin: validate, call an application service, map the result. They contain no business logic.
- **Dart:** `dart format` plus `flutter_lints` with the stricter rules in `analysis_options.yaml`. Widgets use `EdgeInsetsDirectional` / `AlignmentDirectional` (RTL). No hard-coded strings in widgets; everything goes through `AppLocalizations`.
- Comments explain *why*. Don't commit commented-out code.
