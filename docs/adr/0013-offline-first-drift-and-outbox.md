# ADR-0013: Offline-first mobile storage with Drift and a sync outbox

## Status
Accepted

## Date
2026-10-17

## Context
Worship must work with no network, indefinitely. Synced features (family logs, Quran state, zakat backup) must feel instant and tolerate flaky connectivity, especially on mobile networks in Pakistan and while travelling. The local data is relational (prayer logs by member, date and prayer; bookmarks; settings), and the UI should react to changes.

## Decision
- **Drift (SQLite)** is the local source of truth, with reactive queries (`watch()`), typed DAOs, and tested schema migrations (`drift_dev schema dump` / `schema steps`).
- The database is **encrypted with SQLCipher** (`sqlcipher_flutter_libs`), with the key generated on first launch and kept in Keychain/Keystore, because it holds religious-practice data.
- **Repositories read from Drift only.** Remote data sources are called by the `SyncEngine` and by explicit refresh actions, and they write into Drift.
- **Outbox pattern on device:** every write that must reach the server is enqueued as an outbox row in the same Drift transaction as the local change. Rows are coalesced by key, carry an `Idempotency-Key`, and back off exponentially (ARCHITECTURE §3.4).
- **Conflict policy:** LWW by `clientUpdatedAt` for prayer logs. ETag plus a field-level merge for Quran state. Zakat records are single-writer (owner), so the last write wins.
- **Static content** (Uthmani text, the default English translation, cities, adhan voices, fonts) is bundled. Optional packs (Urdu translation, reciter audio) download from our CDN into app storage.
- **Data that never syncs** (fasting log, the self prayer log when the user isn't in a family with sharing on, adhan settings, location) lives in tables with no outbox hook. A unit test asserts those tables have none.

## Alternatives considered
- **Hive / Isar (NoSQL).** Fast and simple, but relational queries over the family grid are clumsier, and migrations are less disciplined. Isar's maintenance status was uncertain at the time of writing. Rejected.
- **sqflite with raw SQL.** No type safety and no reactive layer. Rejected.
- **Network-first with caching.** Breaks the offline requirement. Rejected.

## Consequences
- Every synced feature needs both local and remote models plus mappers. That cost is accepted.
- Sync bugs are subtle, so the SyncEngine has its own integration test suite (fake clock, fake connectivity, mock HTTP adapter).
- SQLCipher adds about 2–3 MB to the app and needs careful key handling on backup/restore. iOS Keychain items are marked `afterFirstUnlockThisDeviceOnly`, so a restored device starts with a fresh local DB and re-syncs what was synced.
