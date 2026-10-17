# ADR-0004: PostgreSQL 16, self-managed schema, no Supabase/BaaS

## Status
Accepted

## Date
2026-10-17

## Context
The data is relational (users ↔ families ↔ members ↔ logs; masjids ↔ roles ↔ follows ↔ groups) and needs transactions: publishing an iqamah week and enqueueing its push must be atomic. It also needs keyset pagination, upserts for sync, and decimal money. The privacy pledge also matters here. We must be able to state exactly where data lives, who processes it, and prove deletion. A backend-as-a-service would add client SDKs, auth and storage features we don't want, and a second processor holding religious data.

## Decision
- **PostgreSQL 16** as the only datastore. In production, a managed instance with encryption at rest, PITR (7 days) and TLS (`SSL Mode=VerifyFull`).
- **No Supabase, Firebase or other BaaS**: no client-side database access, no BaaS auth, no BaaS storage. All access goes through the Sakina API.
- Extensions: `citext` (emails). `pgcrypto` is not needed, because hashing happens in the app.
- The schema is owned by EF Core migrations (ADR-0009).
- Development and integration tests use the same major version (`postgres:16-alpine` via Testcontainers and in CI), never SQLite or the EF in-memory provider.

## Alternatives considered
- **Supabase.** Explicitly excluded by the founder. It would also bring row-level security policies as the main auth layer, and a hosted processor for Art. 9 data.
- **Firebase / Firestore.** Document-shaped data, vendor lock-in, Google as a processor of religious data, and a client SDK that phones home. Rejected on pledge grounds.
- **MySQL.** Viable, but Postgres has better JSONB, `SKIP LOCKED`, partial indexes and `citext`, and works with the Testcontainers module we use.
- **A separate Redis for rate limits and caches.** Deferred. In-process caches and limiters are enough for 1–2 instances. Add Redis (or a Postgres-backed limiter) when scaling out, through an ADR.

## Consequences
- We run migrations and backups and own the schema. Managed Postgres keeps the ops burden small.
- Tenancy isolation is done in the application layer (ARCHITECTURE §6.2), not with Postgres RLS. This is a conscious trade-off for EF Core connection pooling, and it is mitigated by selectors and cross-tenant tests.
- The hosting region is an open question (SPEC §10 Q4); the default is the EU.
