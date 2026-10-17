# ADR-0007: On-device prayer computation; location never leaves the device

## Status
Accepted. This is a product-defining decision, and changing it needs the founder's sign-off.

## Date
2026-10-17

## Context
The Amanah pledge promises: "Your location stays yours. Never sold, never shared." The incumbents' credibility collapsed over location data sales. Prayer times, Qibla and Ramadan times depend on location, so the obvious design (send coordinates to a server, get times back) breaks the pledge. Accuracy and offline availability also matter, because people pray on planes, in basements and abroad without data.

## Decision
1. **All location-dependent computation happens on the device.** That covers prayer times (all methods and madhabs, high-latitude rules, per-prayer adjustments), Qibla bearing and distance, Hijri date (Umm al-Qura with a user adjustment of ±2 days), Ramadan suhoor/iftar, travel detection, and distances to masjids. Implementation: the pure-Dart `adhan` port, wrapped by `PrayerTimeCalculator`, plus our own Qibla and Hijri services, all table-tested.
2. **City lookup is offline.** A bundled `cities.sqlite` (about 150k cities, names in EN, AR and UR, coordinates, timezone, country) resolves "nearest city" and search. No network geocoding is ever used.
3. **No endpoint accepts user coordinates.** The only location-derived value that ever leaves the device is a set of at most 9 **geohash-4 cells** (about 39 × 20 km each) for masjid search. The server enforces the 4-character limit (`LOCATION_TOO_PRECISE`) and never logs the parameter.
4. **Location permission is "while in use" only.** No background location, and no geofencing. Travel is detected on app open and on OS timezone-change events.
5. **Masjid coordinates are public data** returned to the device, so the device ranks by distance itself.
6. The **console** computes adhan times for a masjid in the browser, from the masjid's own public coordinates.
7. **Third-party SDKs must not access location.** OneSignal location sharing is off (ADR-0005), and no analytics or ad SDKs are allowed at all.
8. **Diagnostics** exclude coordinates and city names. The server rejects coordinate-like patterns.

## Alternatives considered
- **A server-side prayer-times API.** Easier to fix bugs centrally. Rejected: it breaks the pledge and the offline requirement.
- **Sending a city ID instead of coordinates.** Still a location disclosure, at city granularity, on every request. Rejected for times. For masjid search we use geohash-4, which is deliberately coarser than a city in dense areas, and only when the user opens masjid search.
- **Reverse geocoding via the platform APIs** (Apple CLGeocoder, Android Geocoder). These send coordinates to Apple or Google. Rejected in favour of the bundled city database.

## Consequences
- Calculation bugs need an app release to fix. We mitigate this with exhaustive test vectors (30 cities × methods × DST dates) and by remotely updatable data files (the method-per-country table and city DB deltas from our CDN, plain static files with no identifiers).
- The app bundle grows (cities DB about 8 MB compressed). Acceptable.
- Masjid search is coarse. Results within about 40–80 km are fetched, then filtered and sorted on device. That's good enough for "masjids nearby".
- A CI and release check (proxy capture) verifies that no request carries coordinates (SPEC P2).
