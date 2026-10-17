# ADR-0006: RevenueCat for subscriptions and entitlements

## Status
Accepted (vendor fixed by the founder)

## Date
2026-10-17

## Context
Sakina Plus is a family subscription: $29.99/year or $3.99/month with a 7-day trial, sold through the App Store and Google Play, with store-localised prices (e.g. PKR). Worship features are always free, so the entitlement may gate **only** convenience and family features. The server must know who has Plus, to gate family creation, sync and zakat backup, and to extend Plus to family members. Reconciling store receipts ourselves is error-prone.

## Decision
- **RevenueCat** handles purchases on device (`purchases_flutter`), with **`appUserID` = the Sakina user UUID**. Purchasing requires sign-in, so entitlements bind to accounts and never to anonymous IDs. No subscriber attributes (email, name) are sent to RevenueCat.
- Products: `sakina_plus_family_yearly` and `sakina_plus_family_monthly`, both granting entitlement **`plus`**. Offerings are configured in RevenueCat, so the paywall reads prices from the SDK.
- **Server source of truth for `plus`:** the `entitlements` table, recomputed from the RevenueCat REST API (`GET /v1/subscribers/{app_user_id}`) whenever:
  1. a webhook arrives at `POST /billing/revenuecat/webhook`, authenticated by **`Authorization: Bearer <shared secret>`** (constant-time compare). Each event is persisted idempotently by `event.id`, and a 200 is returned before the recompute runs through the outbox; or
  2. the client calls `POST /me/entitlements/refresh` after purchase or restore (rate-limited).
- Recompute-from-source (instead of applying event deltas) makes processing order-independent and idempotent. `TRANSFER` events recompute both users.
- **Family sharing:** account members of a family whose OWNER has `plus` get `source=FAMILY`. Store-level family sharing is not used; our family model is the source.
- Trial reminder: a server job pushes 48 h before a trial converts (SPEC BILL-3), on top of the store's own notices.

## Alternatives considered
- **Own receipt validation (App Store Server API + Play Developer API).** Full control and no extra processor, but considerably more code and edge cases (grace periods, refunds, upgrades). Rejected for MVP. The `ISubscriptionProvider` port allows a later replacement.
- **Trusting entitlement state reported by the client.** Insecure. Rejected.
- **Applying webhook events as deltas.** Fragile when events arrive out of order. Rejected in favour of recompute-from-source.

## Consequences
- RevenueCat is a processor. It receives the opaque user UUID and purchase data, and this is disclosed in the privacy policy.
- The server needs `RevenueCat__ApiKey` (secret key, read-only), `RevenueCat__WebhookSecret` and `RevenueCat__EntitlementId`.
- If RevenueCat is down, the last computed entitlement stays valid until `expiresAt` + 24 h grace. Refresh returns 503 `UPSTREAM_UNAVAILABLE`.
- A guard test asserts that no Quran, prayer-time, adhan, Qibla, Ramadan or zakat-calculator route or screen checks the `plus` entitlement.
