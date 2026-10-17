# ADR-0001: Single monorepo with two independent tracks

## Status
Accepted

## Date
2026-10-17

## Context
Sakina has a Flutter mobile app, a masjid console (Flutter web), an ASP.NET Core backend, and shared documents: the spec, the API contract and the design tokens. The team is small, and work will be split between a backend builder and a mobile builder working in parallel (often AI agents). Both need the same spec and contract, and a contract change has to be visible to both sides in one review.

## Decision
Use one git repository:

```
apps/mobile    Flutter (mobile + console entrypoints)
apps/backend   ASP.NET Core solution
docs/          SPEC, ARCHITECTURE, API + openapi.yaml, PLAN, DESIGN_TOKENS, adr/
.github/       per-app CI workflows with path filters
```

- Each app builds with its own native toolchain (`dotnet`, `flutter`). There is no meta build system (Nx, Bazel, Melos at the root). A root `Makefile` gives uniform entry points.
- CI workflows are path-filtered, so a mobile change never runs backend CI and vice versa. `docs/openapi.yaml` changes trigger both apps' contract checks.
- The two apps share **no code**. The only shared artefact is `docs/openapi.yaml`, plus `docs/DESIGN_TOKENS.md` for mobile and console.

## Alternatives considered
- **Polyrepo (mobile, backend, docs).** This gives each repo cleaner permissions, but contract changes need coordinated PRs across repos, versions drift, and agents need several checkouts. Rejected: the coordination cost outweighs the benefit for a team of this size.
- **Monorepo with a build orchestrator (Nx / Bazel).** Rejected: two heterogeneous toolchains gain little from it, and it adds tooling that has to be maintained.
- **Generated shared SDK package (`packages/api_client`).** Deferred. We may later generate a Dart client from `openapi.yaml` into `packages/`. For now, hand-written DTOs plus fixture contract tests keep the mobile code idiomatic.

## Consequences
- One PR can update the contract and docs atomically. Code PRs stay per-app (CONTRIBUTING §3).
- The repo-wide history is shared, so release tags are prefixed per app (`mobile-v1.0.0`, `backend-v1.0.0`).
- Repository access can't be split by app. That's acceptable at the current team size.
