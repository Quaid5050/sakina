# ADR-0010: ProblemDetails errors and REST conventions

## Status
Accepted

## Date
2026-10-17

## Context
Two independently built clients (mobile and console) depend on predictable error handling and response shapes. Hyrum's Law applies: whatever the API exposes, clients will depend on. Errors must be localisable on the client (EN/UR/AR) and must not leak internals or whether other tenants' resources exist.

## Decision
- **Errors:** RFC 9457 `application/problem+json` everywhere, through ASP.NET Core's `AddProblemDetails()` with a customisation that adds **`code`** (stable `UPPER_SNAKE`), `traceId`, and for validation failures `errors` (a camelCase path → messages map). `type` = `https://sakina.app/problems/<code-kebab>`. The code catalogue lives in `docs/API.md` §4.2, and the server mirror is `ErrorCodes.cs`.
- Application services return `Result<T>`, never throwing for expected failures. A single `ResultMapper` maps `Error.Kind` → HTTP status. Unhandled exceptions → 500 `INTERNAL_ERROR` without details.
- **Other tenants' resources return 404, not 403.**
- **Validation:** FluentValidation at the API boundary → 422 `VALIDATION_FAILED`. Malformed JSON → 422 `MALFORMED_JSON`. Unknown request properties → 422 (`UnmappedMemberHandling.Disallow`).
- **Shapes:** camelCase JSON. `UPPER_SNAKE` enums serialised as strings. RFC 3339 UTC timestamps. Decimals as strings. Collections wrapped in `{ data }`. Cursor pagination `{ data, page: { limit, nextCursor } }`.
- **Versioning:** `/api/v1` path prefix, additive-only changes, and clients ignore unknown fields.
- **Concurrency and retries:** `ETag`/`If-Match` for documents edited from several places. An `Idempotency-Key` header for side-effecting POST/PUT, stored per caller for 24 h.

## Alternatives considered
- **A custom `{ error: { code, message } }` envelope.** Equivalent information, but not a standard, and ASP.NET Core's ProblemDetails support would need replacing. Rejected.
- **Offset pagination.** Simpler, but unstable under inserts. Rejected.
- **Numbers for money.** IEEE floats lose precision on zakat sums. Rejected (SPEC D-18).

## Consequences
- Every endpoint's integration tests assert the problem `code`, not just the status.
- Clients need decimal parsing for money fields.
- Adding an error code is an additive contract change (update API.md, `ErrorCodes.cs` and the client mapping in the same release).
