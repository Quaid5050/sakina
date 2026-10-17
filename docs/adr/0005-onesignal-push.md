# ADR-0005: OneSignal for push, server-driven via REST

## Status
Accepted (vendor fixed by the founder; this ADR records how we use it within the pledge)

## Date
2026-10-17

## Context
Some pushes must come from the server: family encouragements, masjid announcements and iqamah changes, and trial reminders. The adhan must **not** depend on server push, because push is best-effort and Doze or battery savers delay it. Push vendors typically collect device data, location and engagement analytics, which conflicts with the Amanah pledge.

## Decision
- **OneSignal** delivers server-initiated push on iOS (APNs) and Android (FCM).
- **The adhan never uses push.** It is scheduled locally on the device (ADR-0007).
- **Identity:** the device calls `OneSignal.login(externalId)` with the Sakina user UUID, or `child:<memberId>` for linked child devices, and `OneSignal.logout()` on sign-out. No email, phone, tags or attributes are ever set.
- **Device SDK configuration** (enforced by a wrapper with a unit test): `OneSignal.Location.setShared(false)`, no location permission requested by the SDK, in-app messaging unused, and no outcome or engagement tracking used by us. The privacy-policy consent gate (`OneSignal.consentRequired(true)`) is satisfied only when the user enables notifications.
- **Server:** `Sakina.Infrastructure/Push/OneSignalClient` is a typed `HttpClient` calling `POST https://api.onesignal.com/notifications` with `include_aliases: { external_id: [...] }` and `target_channel: "push"`, in batches of ≤ 2,000 aliases, with an `idempotency_key` = outbox message ID. The REST API key comes only from `OneSignal__ApiKey`.
- **Payloads:** IDs and template keys only (API.md §8). Encouragements are **data-only**, so the device decides when to show them (after local Maghrib), and the server never needs the child's prayer times.
- On account deletion, the server deletes the OneSignal user by external ID.

## Alternatives considered
- **Direct FCM + APNs.** This is the most private option, with no third party beyond Apple and Google. It means more server work (APNs token auth, FCM v1 OAuth, token bookkeeping). The founder fixed OneSignal for speed. The `IPushSender` port keeps a later swap to direct FCM/APNs to a single adapter.
- **Firebase Cloud Messaging only.** iOS would still need APNs, and the Firebase SDK pulls in analytics components. Rejected.
- **Self-hosted (ntfy / Gotify).** Not reliable on iOS. Rejected.

## Consequences
- OneSignal becomes a processor, and the privacy policy names it. What it receives: the device push token, OS and SDK metadata, the opaque external ID, and the notification content.
- Announcement open rates are available only through OneSignal's stats. We show them in the console when they're present. We never track opens ourselves.
- Data-only pushes on iOS are throttled by the OS. For encouragements on iOS we accept best-effort delivery, and the client also pulls `GET /families/{id}/encouragements` when it opens.
