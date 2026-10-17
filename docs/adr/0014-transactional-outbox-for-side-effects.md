# ADR-0014: Transactional outbox for backend side effects

## Status
Accepted

## Date
2026-10-17

## Context
Several state changes must trigger external side effects: publishing iqamah or posting an announcement → push fan-out; encouragement → push; webhook → RevenueCat refetch; account deletion → OneSignal and RevenueCat cleanup; password reset → email. Calling these services inside the request leads to lost side effects (crash after commit), duplicates (retry after a partial failure), and slow requests (fan-out to thousands of followers).

## Decision
- An `outbox_messages` table (`id, type, payload jsonb, attempts, next_attempt_at, processed_at, last_error, created_at`). Services write outbox rows **in the same EF Core transaction** as the state change.
- `OutboxDispatcher` (a `BackgroundService` in the API process) claims batches with `SELECT … FOR UPDATE SKIP LOCKED LIMIT n`, dispatches each message to its typed handler (`IOutboxHandler<TPayload>`), and marks it processed. Failures back off exponentially (30 s × 2^n, with jitter), up to 5 attempts, then dead-letter (`processed_at` stays null, `attempts = 5`) with metrics and alerts.
- Delivery is at-least-once, so **handlers are idempotent**: OneSignal requests use `idempotency_key = outbox id`, the RevenueCat recompute is naturally idempotent, and emails carry a per-message dedupe key.
- Large fan-outs are split into one message per batch of ≤ 2,000 recipients.
- Scheduled jobs (trial reminders, deletions, retention, rate refresh) run as `BackgroundService`s guarded by **Postgres advisory locks**, so only one instance runs each job.
- Processed rows are deleted after 7 days by the retention job.

## Alternatives considered
- **Hangfire / Quartz.NET.** Mature, but they add their own schemas and dashboards. Hangfire Pro features need a licence. More than MVP needs. Rejected for now.
- **A message broker (RabbitMQ, SQS).** Extra infrastructure, and it still needs an outbox for atomicity. Rejected for MVP.
- **Fire-and-forget `Task.Run` after commit.** Loses work on restart. Rejected.

## Consequences
- Side effects are delayed by up to the polling interval (default 2 s). That's fine for push.
- The outbox lag is a readiness signal (`/health/ready` fails if the oldest pending message is older than 5 minutes).
- Integration tests run the dispatcher synchronously through a test hook (`IOutboxDrainer.DrainAsync()`), so tests are deterministic.
