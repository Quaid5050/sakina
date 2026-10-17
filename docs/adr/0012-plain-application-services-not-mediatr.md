# ADR-0012: Plain application services instead of MediatR

## Status
Accepted

## Date
2026-10-17

## Context
Clean Architecture in .NET often uses MediatR, with one request plus handler per use case, and pipeline behaviours for validation, logging and transactions. The founder's brief says to pick MediatR or plain application services and record the choice. Facts that bear on it:
- **MediatR moved to a commercial licence from v13 (2025).** Using it means paying, or pinning an old Apache-2.0 version (12.x) that gets no updates.
- The API has about 89 operations across 7 contexts, and most are simple CRUD with authorisation.
- Builders (including AI agents) navigate code more reliably when "Go to definition" from a controller lands on the logic itself, not on an `ISender.Send` indirection.

## Decision
Use **plain application services**, one or a few per bounded context (`FamilyService`, `FamilyInviteService`, `PrayerLogSyncService`, `MasjidAdminService`, `IqamahService`, `EntitlementService`, …), registered in DI and injected into controllers.

- Method shape: `Task<Result<TResponse>> DoThingAsync(Caller caller, TRequest request, CancellationToken ct)`. `Caller` is a value object built once per request from the claims (user ID or child ID, scope, roles).
- **Cross-cutting concerns without a pipeline:**
  - Validation: FluentValidation, through an ASP.NET Core endpoint filter or action filter at the API boundary (422).
  - Transactions: one `SaveChangesAsync` per service method. Where a method must span outbox writes, it uses `IUnitOfWork.ExecuteInTransactionAsync`.
  - Logging and tracing: Serilog request logging plus OpenTelemetry spans from ASP.NET Core and EF. Services add spans only for significant work.
  - Authorisation: policies at the controller plus selectors and domain checks in the service (ARCHITECTURE §6.2).
- Services are unit-tested with fakes for ports and an in-memory `SakinaDbContext` substitute *only for pure orchestration tests*. Anything query-shaped is tested in integration tests against real Postgres.

## Alternatives considered
- **MediatR 13+ (commercial).** Adds a licence cost and indirection for little benefit at this size. Rejected.
- **MediatR 12.x (last Apache-2.0).** Free, but frozen. Rejected to avoid depending on an unmaintained version.
- **Open-source mediator alternatives (e.g. source-generated `Mediator`).** Viable and free, but they keep the indirection. Rejected for the same simplicity reason. If the pipeline-behaviour need grows (e.g. audit logging on every command), revisit with an ADR.
- **Wolverine.** A powerful messaging framework, more than we need for MVP.

## Consequences
- Less ceremony: no request/handler pair per use case.
- Services must stay cohesive. When a service grows past ~400 lines or ~10 public methods, split it by sub-capability (e.g. `IqamahDraftService`, `IqamahPublishService`).
- Cross-cutting behaviour is explicit at the call site or in ASP.NET Core filters, so there's no hidden pipeline.
