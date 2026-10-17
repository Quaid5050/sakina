# ADR-0009: EF Core 8 + Npgsql with code-first migrations

## Status
Accepted

## Date
2026-10-17

## Context
The backend needs a data-access layer for PostgreSQL that supports transactions, migrations, upserts (prayer-log LWW), `SKIP LOCKED` (outbox), keyset pagination, decimal precision, and strongly typed IDs. It should also be friendly to Testcontainers-based integration tests.

## Decision
- **EF Core 8** with **Npgsql.EntityFrameworkCore.PostgreSQL** (version aligned with EF Core 8), and `EFCore.NamingConventions` for **snake_case** table and column names (`UseSnakeCaseNamingConvention()`).
- **Code-first migrations** in `Sakina.Infrastructure/Persistence/Migrations`. Each entity has an `IEntityTypeConfiguration<T>` (no data annotations on domain entities), so the domain stays persistence-ignorant.
- **Strongly typed IDs** (`UserId`, `FamilyId`, …) are `readonly record struct`s wrapping a `Guid`, mapped with value converters. Values are UUID v7, generated in the app (`Guid.CreateVersion7()` on .NET 9+, a small helper on .NET 8).
- **Money:** `decimal` mapped to `numeric(19,4)`, and rates to `numeric(19,6)`.
- **Upserts and set-based operations** that EF can't express cleanly (prayer-log LWW upsert, outbox claiming with `FOR UPDATE SKIP LOCKED`) use **raw SQL with parameters**, via `Database.SqlQuery<T>` / `ExecuteSqlInterpolatedAsync`, inside the repository or selector for that context. Each one has an integration test.
- **Production migrations** run as a separate step: `dotnet ef migrations bundle` produces an `efbundle` executable, run by the deploy pipeline before the rollout. **Never `Database.Migrate()` at app startup in production.** Integration tests apply migrations to the Testcontainers database at fixture start-up, which also checks that migrations apply cleanly.
- **Migration hygiene:** one migration per PR that changes the model. CI checks for pending model changes (`dotnet ef migrations has-pending-model-changes`, available from EF Core 8). Migrations already merged to `main` are never edited.
- No lazy loading. Reads use `AsNoTracking()` and explicit projections to DTOs in selectors. Global query filters are not used for tenancy (ARCHITECTURE §5.2).

## Alternatives considered
- **Dapper only.** Fast and explicit, but we'd hand-write migrations and mapping for about 30 tables. Rejected. Raw SQL is still used inside EF for the few hot paths.
- **Database-first (scaffolding).** Puts the schema outside code review. Rejected.
- **Marten / document storage on Postgres.** Doesn't fit the relational model. Rejected.

## Consequences
- Builders need the `dotnet-ef` tool, pinned in `.config/dotnet-tools.json`.
- Snake-case naming keeps SQL readable for ops, and matches the ERD in ARCHITECTURE §5.
- Raw-SQL paths bypass EF's change tracking, so they're kept inside Infrastructure and covered by integration tests against real Postgres.
