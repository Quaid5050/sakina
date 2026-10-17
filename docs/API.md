# Sakina API v1: conventions and endpoint guide

The machine-readable contract is **`docs/openapi.yaml`** (OpenAPI 3.1). It is authoritative; if this document and the YAML disagree, the YAML wins and this file gets fixed. See ADR-0010 (conventions) and ADR-0011 (contract-first).

- Base URL: `https://api.sakina.app/api/v1` (staging: `https://api.staging.sakina.app/api/v1`, local: `http://localhost:5080/api/v1`)
- Health probes sit outside the version prefix: `/health/live`, `/health/ready`
- Lint: `make api-lint`

## 1. Versioning

- The major version is in the path (`/api/v1`). Within v1, changes are **additive only**: new endpoints, new optional request fields, new response fields, new enum values.
- **Clients must ignore unknown response fields and treat unknown enum values as "other".** This is what keeps additive changes safe.
- **The server rejects unknown request fields** with `422 VALIDATION_FAILED`, so data we never agreed to collect can't leak in. The RevenueCat webhook is the one exception.
- Deprecations: the `Deprecation` and `Sunset` response headers (RFC 8594), announced at least 90 days ahead. A v2 is only for breaking changes and needs an ADR.
- `info.version` in the YAML follows semver for the contract document itself (minor = additive).

## 2. Requests and responses

| Topic | Rule |
|---|---|
| Format | `Content-Type: application/json; charset=utf-8`. `PATCH /me` also accepts `application/merge-patch+json` |
| Field names | camelCase. Enums are `UPPER_SNAKE` (except `locale`: `en`/`ur`/`ar`) |
| IDs | UUID strings (v7). Treat as opaque |
| Timestamps | RFC 3339 UTC, e.g. `2026-10-17T09:40:00Z` |
| Local dates / times | `YYYY-MM-DD`, `HH:mm` (24 h). These are the user's or masjid's local calendar, with no timezone attached |
| Money and rates | **Decimal strings**, e.g. `"23714.55"`. Never JSON numbers. Parse with `Decimal` (Dart `decimal` package, C# `decimal`) |
| Nulls | Optional response fields are present as `null` when declared `[T, 'null']`, and absent otherwise. Clients handle both |
| Partial updates | `PATCH` changes only the fields provided. Sending `null` clears a nullable field |
| Collections | Always wrapped: `{ "data": [ … ] }` (never a top-level array) |
| Body size | 256 KB max (413 `PAYLOAD_TOO_LARGE`) |
| Language | `Accept-Language: en|ur|ar` is honoured only for server-authored push copy. API error text is always English; clients localise by `code` |

### 2.1 Required and recommended headers

| Header | Direction | Notes |
|---|---|---|
| `Authorization: Bearer <accessToken>` | request | All endpoints except those with `security: []` |
| `Idempotency-Key: <uuid>` | request | Recommended on every POST/PUT with side effects (marked in the YAML). Results are kept for 24 h per caller. Same key + different body → `409 IDEMPOTENCY_KEY_REUSED` |
| `If-Match: "<etag>"` | request | `PUT /me/quran-state`, `PUT /admin/masjids/{id}/iqamah/draft` |
| `If-None-Match` | request | `GET /masjids/{id}/iqamah` (→ 304) |
| `X-Client: sakina-mobile/1.4.0 (android 15)` | request | Optional. Used only for support and compatibility, never tied to a user in logs |
| `ETag` | response | Versioned resources |
| `Retry-After` | response | 429 and 503 |
| `traceparent` | both | W3C Trace Context, optional |

## 3. Authentication

| Token | Lifetime | Storage on device | Notes |
|---|---|---|---|
| Access (JWT, HS256) | 15 min | memory | Claims: `sub`, `scope` (`user` \| `child`), `fid` (child only), `roles`, `jti`, `iat`, `exp`, `iss`, `aud` |
| Refresh (opaque) | 30 days sliding, 180 days absolute | Keychain / Keystore | **Rotated on every use.** Presenting a consumed token revokes the whole session chain (`REFRESH_TOKEN_REUSED`) |

**Flows**
1. `POST /auth/register` or `POST /auth/login` or `POST /auth/social` → `AuthSession { tokens, user }`.
2. Send the access token as a Bearer token. On `401` with code `TOKEN_EXPIRED`, call `POST /auth/refresh` **once** (a single-flight mutex in the Dio interceptor), then retry the original request. If the refresh fails, sign out locally.
3. `POST /auth/logout { refreshToken, allDevices? }` → 204.

**Social sign-in**
- Google: send the `idToken` from Google Sign-In. The server verifies it with Google's JWKS, and `aud` must be one of our iOS/Android/web client IDs.
- Apple: generate a random nonce, pass `SHA256(nonce)` to Sign in with Apple, then send `idToken` plus the **raw** `nonce`. Apple returns the user's name only on first sign-in, so forward it as `displayName`.
- If the provider email matches an existing password account, the server returns `409 ACCOUNT_EXISTS`. Ask the user to sign in with their password. There is no automatic linking in v1.

**Child sessions** (`scope=child`)
- A guardian calls `POST /families/{id}/children/{childId}/link-codes` and gets a 6-digit code, valid for 10 minutes.
- The child's device calls `POST /auth/child-link { code }` and gets a `ChildSession`.
- Child tokens work only on operations marked `x-sakina-child-allowed: true`, and only for their own child profile. Everything else returns `403 CHILD_SCOPE_NOT_ALLOWED`.

**Plus-gated operations** are marked `x-sakina-plus-required: true`. Without an active entitlement (own purchase or via family) they return `403 PLUS_REQUIRED`. For family writes, the gate checks the **family owner's** entitlement.

## 4. Errors

All errors are `application/problem+json` (RFC 9457) with Sakina extensions:

```json
{
  "type": "https://sakina.app/problems/validation-failed",
  "title": "One or more fields are invalid",
  "status": 422,
  "code": "VALIDATION_FAILED",
  "detail": "entries[3].date is more than 1 day in the future.",
  "instance": "/api/v1/families/0192…/prayer-logs",
  "traceId": "4bf92f3577b34da6a3ce929d0e0e4736",
  "errors": {
    "entries[3].date": ["Date is more than 1 day in the future."]
  }
}
```

- `code` is the **stable contract**. Clients switch on `code`, never on `title`/`detail`.
- `type` is `https://sakina.app/problems/<code in kebab-case>`.
- `errors` (validation only) maps camelCase JSON paths to messages.
- 5xx responses never contain stack traces or internals. Quote `traceId` to support.

### 4.1 Status codes

| Status | When |
|---|---|
| 200 / 201 / 202 / 204 | Success. 201 includes `Location` when a resource has its own URL |
| 304 | Conditional GET matched |
| 401 | No, invalid or expired token; wrong credentials; bad webhook secret |
| 403 | Authenticated but not allowed (role, Plus, child scope, read-only family) |
| 404 | Not found **or not visible to you**. We never return 403 for another tenant's resource, so existence doesn't leak |
| 409 | State conflict (duplicate, limit reached, ownership rules) |
| 412 / 428 | `If-Match` mismatch / missing |
| 413 | Body too large |
| 422 | Validation failed (including malformed JSON) |
| 429 | Rate limited, with `Retry-After` |
| 500 | Bug. Logged with `traceId` |
| 503 | Dependency unavailable (rates, RevenueCat), with `Retry-After` |

### 4.2 Error code catalogue

| Code | Status | Meaning / client action |
|---|---|---|
| `UNAUTHENTICATED` | 401 | Missing or invalid token. Sign in |
| `TOKEN_EXPIRED` | 401 | Refresh once, then retry |
| `INVALID_CREDENTIALS` | 401 | Wrong email or password (deliberately ambiguous) |
| `REFRESH_TOKEN_REUSED` | 401 | Session chain revoked. Sign out locally |
| `SOCIAL_TOKEN_INVALID` | 401 | Provider token failed verification |
| `RESET_TOKEN_INVALID` | 401 | Expired or used reset link |
| `PLUS_REQUIRED` | 403 | Show the Plus explainer |
| `FAMILY_READ_ONLY` | 403 | The owner's Plus lapsed. Show "Ask {owner} to renew" |
| `ROLE_REQUIRED` | 403 | Needs a higher family or masjid role |
| `CHILD_SCOPE_NOT_ALLOWED` | 403 | Child sessions can't do this |
| `NOT_SHARING` | 403 | Target member has sharing off |
| `NOT_FOUND` | 404 | Not found or not visible |
| `INVITE_NOT_FOUND` | 404 | Unknown, expired or revoked invite (indistinguishable on purpose) |
| `LINK_CODE_NOT_FOUND` | 404 | Unknown, expired or used child link code |
| `EMAIL_TAKEN` | 409 | Offer sign-in |
| `ACCOUNT_EXISTS` | 409 | Social email matches a password account. Sign in with the password |
| `ALREADY_MEMBER` | 409 | Already in this family |
| `FAMILY_FULL` | 409 | 6 people already ("Family plan covers up to 6 people.") |
| `FAMILY_LIMIT_REACHED` | 409 | Already owns one family or belongs to two |
| `OWNER_MUST_TRANSFER` | 409 | The owner tried to leave. Transfer first |
| `LAST_OWNER` | 409 | A masjid must keep one OWNER |
| `ENCOURAGEMENT_DAILY_LIMIT` | 409 | 10 per recipient per day |
| `DRAFT_VERSION_STALE` | 409 | Publishing an outdated draft version. Reload |
| `FUND_HAS_ENTRIES` | 409 | Can't delete a fund, or change its currency, once it has entries |
| `GROUP_NAME_TAKEN` | 409 | Duplicate audience group name |
| `IDEMPOTENCY_KEY_REUSED` | 409 | Same key, different request |
| `VERSION_CONFLICT` | 412 | Merge with the returned document and retry |
| `PRECONDITION_REQUIRED` | 428 | Send `If-Match` |
| `PAYLOAD_TOO_LARGE` | 413 | |
| `VALIDATION_FAILED` | 422 | See `errors` |
| `MALFORMED_JSON` | 422 | Body isn't valid JSON |
| `PASSWORD_TOO_WEAK` | 422 | Too short or a known breached password |
| `LOCATION_TOO_PRECISE` | 422 | Geohash cell isn't 4 characters |
| `LOCATION_NOT_ALLOWED` | 422 | Diagnostic report contained coordinates |
| `UNSUPPORTED_CURRENCY` | 422 | Not in `/rates/currencies` |
| `RATE_LIMITED` | 429 | Wait `Retry-After` seconds |
| `RATES_UNAVAILABLE` | 503 | No rate younger than 72 h. Let the user enter a price manually |
| `UPSTREAM_UNAVAILABLE` | 503 | RevenueCat or another dependency is down. Retry later |
| `INTERNAL_ERROR` | 500 | Show a generic error with `traceId` |

The backend keeps these in `Sakina.Domain/Common/ErrorCodes.cs`, and a contract test checks that every code above exists there.

## 5. Pagination

Cursor-based (keyset) pagination. Offsets are never used, because records shift between pages while users add data.

```
GET /masjids/{id}/announcements?limit=20
→ { "data": [ … ], "page": { "limit": 20, "nextCursor": "eyJzIjoiMjAyNi0xMC0xNFQx…" } }

GET /masjids/{id}/announcements?limit=20&cursor=eyJzIjoiMjAyNi0xMC0xNFQx…
→ { "data": [ … ], "page": { "limit": 20, "nextCursor": null } }   // last page
```

- `limit` 1–100, default 20.
- `nextCursor` is opaque (base64url JSON of the sort key and id, HMAC-signed so it can't be tampered with). `null` marks the last page.
- Ordering is fixed per endpoint (documented in each operation; usually newest first).
- Small bounded lists (family members ≤ 6, my families ≤ 2, groups, funds, roles) are not paginated but are still wrapped in `data`.
- Sync endpoints use `updatedSince` (incremental pull) instead of cursors.

## 6. Rate limits

Enforced with ASP.NET Core rate limiting. Breaching a limit returns `429 RATE_LIMITED` with `Retry-After`. Operations name their policy in `x-sakina-rate-limit`.

| Policy | Key | Limit |
|---|---|---|
| `global` (all endpoints) | user ID, else IP | 300 / min |
| `auth-login` | email + IP | 5 / 15 min |
| `auth-register` (also forgot password) | IP | 10 / hour |
| `auth-refresh` | IP | 60 / hour |
| `child-link` | IP | 5 / 10 min |
| `family-join` (also masjid role invites) | user | 10 / hour |
| `encouragement` | sender | 60 / day (plus a domain cap of 10 per recipient per day) |
| `entitlement-refresh` | user | 6 / hour |
| `diagnostics` | IP | 3 / day |
| `webhook` | none | 600 / min |

Clients should back off exponentially on 429/503, honouring `Retry-After`. The sync engine (ARCHITECTURE §3.4) does this automatically.

## 7. Endpoint map

Full schemas live in `openapi.yaml`. 🔓 = anonymous allowed, 👶 = child token allowed, ➕ = Plus required.

### Auth
| Method | Path | Notes |
|---|---|---|
| POST | `/auth/register` 🔓 | 201 `AuthSession` |
| POST | `/auth/login` 🔓 | 200 `AuthSession` |
| POST | `/auth/refresh` 🔓 | Rotation |
| POST | `/auth/social` 🔓 | Google / Apple ID token. 200 existing, 201 new |
| POST | `/auth/logout` 🔓 | The refresh token in the body is the credential |
| POST | `/auth/password/forgot` 🔓 | Always 202 |
| POST | `/auth/password/reset` 🔓 | Revokes all sessions |
| POST | `/auth/child-link` 🔓 | 6-digit code → `ChildSession` |

### Me
| Method | Path | Notes |
|---|---|---|
| GET / PATCH / DELETE | `/me` | DELETE → 202, data erased within 24 h |
| GET | `/me/entitlements` | `plus.active`, `source` |
| POST | `/me/entitlements/refresh` | After purchase or restore |
| GET / PUT / DELETE | `/me/quran-state` ➕ | ETag / If-Match |
| GET / POST / DELETE | `/me/zakat-records` ➕ | DELETE = all (backup off) |
| GET / PUT / DELETE | `/me/zakat-records/{recordId}` ➕ | |
| GET | `/me/follows` | |

### Families
| Method | Path | Notes |
|---|---|---|
| POST | `/families` ➕ | Caller becomes OWNER |
| GET | `/families/mine` 👶 | |
| POST | `/families/join` | Invite code |
| GET / PATCH / DELETE | `/families/{familyId}` 👶(GET) ➕(PATCH) | |
| GET / POST | `/families/{familyId}/invites` ➕(POST) | 8-char code, 7 days |
| DELETE | `/families/{familyId}/invites/{inviteId}` | |
| GET | `/families/{familyId}/members` 👶 | Accounts + children |
| PATCH / DELETE | `/families/{familyId}/members/{memberId}` | Role / shareWorship / leave |
| POST | `/families/{familyId}/children` ➕ | No account |
| PATCH / DELETE | `/families/{familyId}/children/{childId}` | |
| POST | `/families/{familyId}/children/{childId}/link-codes` ➕ | 6-digit, 10 min |

### Worship sync
| Method | Path | Notes |
|---|---|---|
| GET | `/families/{familyId}/prayer-logs?from&to&memberId&updatedSince` 👶 | ≤ 62 days |
| PUT | `/families/{familyId}/prayer-logs` 👶 ➕ | Batch ≤ 200, LWW, `status: null` clears |
| GET / PUT | `/families/{familyId}/members/{memberId}/quran-progress` 👶 ➕(PUT) | |

### Encouragements
| Method | Path | Notes |
|---|---|---|
| GET | `/families/{familyId}/encouragements?memberId&cursor` 👶 | |
| POST | `/families/{familyId}/encouragements` ➕ | → OneSignal data-only push |
| POST | `/families/{familyId}/encouragements/{encouragementId}/seen` 👶 | Recipient only |

### Rates
| Method | Path | Notes |
|---|---|---|
| GET | `/rates/currencies` 🔓 | |
| GET | `/rates/metals?currency=PKR` 🔓 | Per gram, decimal strings, `isStale` |

### Masjids (public / congregant)
| Method | Path | Notes |
|---|---|---|
| GET | `/masjids?cells=ttsg,ttsu&q=&cursor&limit` 🔓 | **geohash-4 only**, ≤ 9 cells |
| GET | `/masjids/{masjidId}` 🔓 | |
| GET | `/masjids/{masjidId}/iqamah?weekStart` 🔓 | ETag / 304 |
| GET | `/masjids/{masjidId}/announcements` 🔓 | Group announcements need a follow |
| GET | `/masjids/{masjidId}/groups` 🔓 | |
| PUT / DELETE | `/masjids/{masjidId}/follow` | `{ groupIds }` |

### Masjid admin (console)
| Method | Path | Min role |
|---|---|---|
| GET / POST | `/admin/masjids` | any user (POST registers as PENDING_VERIFICATION) |
| GET / PATCH | `/admin/masjids/{masjidId}` | EDITOR / ADMIN |
| GET | `/admin/masjids/{masjidId}/stats` | EDITOR |
| GET / PUT | `/admin/masjids/{masjidId}/iqamah/draft?weekStart` | EDITOR |
| POST | `/admin/masjids/{masjidId}/iqamah/publish` | EDITOR |
| GET / POST | `/admin/masjids/{masjidId}/announcements` | EDITOR |
| GET / POST | `/admin/masjids/{masjidId}/groups` | EDITOR / ADMIN |
| PATCH / DELETE | `/admin/masjids/{masjidId}/groups/{groupId}` | ADMIN |
| GET / POST | `/admin/masjids/{masjidId}/funds?month` | ADMIN |
| PATCH / DELETE | `/admin/masjids/{masjidId}/funds/{fundId}` | ADMIN |
| GET / POST | `/admin/masjids/{masjidId}/funds/{fundId}/entries` | ADMIN |
| GET / POST | `/admin/masjids/{masjidId}/rota/shifts?from&to` | EDITOR / ADMIN |
| PATCH / DELETE | `/admin/masjids/{masjidId}/rota/shifts/{shiftId}` | ADMIN |
| GET | `/admin/masjids/{masjidId}/roles` | OWNER |
| PATCH / DELETE | `/admin/masjids/{masjidId}/roles/{userId}` | OWNER (DELETE self = leave) |
| POST | `/admin/masjids/{masjidId}/role-invites` | OWNER |
| POST | `/admin/role-invites/accept` | any user |

### Staff
| Method | Path | Notes |
|---|---|---|
| POST | `/staff/masjids/{masjidId}/verify` | `staff` role. PUBLISHED / SUSPENDED |

### Billing
| Method | Path | Notes |
|---|---|---|
| POST | `/billing/revenuecat/webhook` | `Authorization: Bearer <RevenueCat__WebhookSecret>`. Idempotent on `event.id` |

### Diagnostics and health
| Method | Path | Notes |
|---|---|---|
| POST | `/diagnostics/reports` 🔓 | Rejected if it contains coordinates |
| GET | `/health/live`, `/health/ready` 🔓 | Outside `/api/v1` |

## 8. Push payloads (OneSignal)

The server sends every push through OneSignal's REST API, targeting `include_aliases: { external_id: [...] }`. External IDs are the Sakina user UUID, or `child:<memberId>` for linked child devices. Payloads carry **only IDs and template keys**, apart from masjid-authored announcement text.

| `data.type` | Delivery | `data` fields | Client behaviour |
|---|---|---|---|
| `encouragement` | **data-only** (`content_available`, no `contents`) | `familyId`, `encouragementId` | Fetch it, then schedule a local notification after local Maghrib (SPEC FAM-8) |
| `masjid_announcement` | visible | `masjidId`, `announcementId` | `headings` = masjid name, `contents` = title. Tap → announcement |
| `iqamah_updated` | visible | `masjidId`, `weekStart` | Template key `iqamah_updated`, localised by the server from the follower's `locale` |
| `trial_ending` | visible | `expiresAt` | Template key `trial_ending` |
| `family_joined` | visible | `familyId`, `memberId` | Shown to guardians |

## 9. Example: sync a week of prayer logs

```http
PUT /api/v1/families/01928c6e-7a3f-7c4e-9d2b-3f1a6b0e5c21/prayer-logs
Authorization: Bearer eyJ…
Idempotency-Key: 6f0d2b4e-0a36-4b8e-9a3c-1b8e3f9d7c11
Content-Type: application/json

{ "entries": [
  { "memberId": "01928c6e-…-aisha", "date": "2026-10-17", "prayer": "FAJR", "status": "ON_TIME", "clientUpdatedAt": "2026-10-17T00:05:12Z" },
  { "memberId": "01928c6e-…-aisha", "date": "2026-10-17", "prayer": "ASR",  "status": null,      "clientUpdatedAt": "2026-10-17T11:20:00Z" }
]}
```

```json
{ "results": [
    { "memberId": "…aisha", "date": "2026-10-17", "prayer": "FAJR", "applied": true },
    { "memberId": "…aisha", "date": "2026-10-17", "prayer": "ASR",  "applied": false,
      "current": { "memberId": "…aisha", "date": "2026-10-17", "prayer": "ASR", "status": "LATE",
                   "clientUpdatedAt": "2026-10-17T11:31:40Z", "serverUpdatedAt": "2026-10-17T11:31:41Z" } }
  ],
  "serverTime": "2026-10-17T11:32:02Z" }
```

## 10. Keeping the contract and the code in sync

- **Backend:** Swashbuckle generates `/swagger/v1/swagger.json` in Development and Test. `Sakina.IntegrationTests/Contract/OpenApiContractTests` loads `docs/openapi.yaml` and the generated document and asserts that they have the **same set of (method, path, status codes)** and that every request/response schema name used in the YAML exists. Controllers carry `[ProducesResponseType]` for every documented status.
- **Mobile:** JSON fixtures in `apps/mobile/test/fixtures/api/` are validated against the YAML schemas in CI (`contract.yml`), and the Dart DTOs are tested against those fixtures.
- **Mock server:** `npx @stoplight/prism-cli mock docs/openapi.yaml` lets the mobile track develop before the backend exists (PLAN M0.4).
