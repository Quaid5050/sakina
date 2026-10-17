# Sakina: Product and Engineering Specification (MVP)

| | |
|---|---|
| Status | **Draft v1** for founder review. Decisions were made autonomously and are marked **[D-n]**; see §9 |
| Date | 2026-10-17 |
| Launch target | Ramadan 1448, expected about **8 February 2027** (subject to moonsighting). Code freeze 11 January 2027 |
| Sources | `reports/App user needs and pain points.md` §1 "Sakina"; Claude Design files (Onboarding, Today, Adhan Health, Quran, Family, Ramadan, Zakat, Travel, Plus, Landing, Masjid Console) |
| Related | `ARCHITECTURE.md`, `API.md`, `openapi.yaml`, `PLAN.md`, `DESIGN_TOKENS.md`, `adr/` |

---

## 1. Objective

Sakina is a Muslim companion app for prayer times, a dependable adhan, the Quran and family worship. It never shows ads, never sells or shares location, and never puts worship behind a paywall. It earns from a **Sakina Plus family plan** ($29.99/year or $3.99/month, 7-day trial) and later from a **masjid console** subscription.

**Primary users**
- Practising Muslims aged 18–40 in the UK, EU, North America, the Gulf, and urban Pakistan and India
- **Young parents** building their children's salah and Quran habits
- **Frequent travellers**, whose prayer times drift after a journey
- The **privacy-conscious diaspora**

**Secondary user:** the **masjid**. Admins publish iqamah times and announcements to followers' phones, which also makes masjids a distribution channel.

**What success looks like at launch, measured without tracking SDKs** (store consoles plus server counts only):
1. When the Adhan Health check reports 5/5 on a device, the adhan fires within ±60 s of the computed time on Android (Pixel, Samsung, Xiaomi) and iOS. Verified by the device test matrix (§7.6).
2. Prayer times match the reference implementation (`adhan` library test vectors / praytimes.org) to within ±1 minute for every supported method and madhab across 30 test cities, including high-latitude cities.
3. The app makes **zero network requests** that carry the user's coordinates or anything finer than the coarse cell (§6.1). Verified by a proxy-capture test in CI's release checklist.
4. A parent can create a family, add a child, and see that child's logged prayers on a second device within 30 s of a sync.
5. A masjid admin can publish an iqamah change, and following devices receive a push within 2 minutes.

---

## 2. Scope

### 2.1 In scope (MVP, at launch)

| Area | Included |
|---|---|
| **Onboarding** | 3 steps: Amanah pledge → location (on device) or manual city + calculation method → language (EN / UR / AR) → hand-off to Adhan Health |
| **Today** | Gregorian and Hijri date, next-prayer countdown, the day's six times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) with a method label and "why" sheet, Qibla shortcut, adhan-health chip, a gentle streak |
| **Prayer log (self)** | Mark each prayer as prayed or prayed late. Stored locally. The streak "rests, doesn't reset" |
| **Adhan Health** | 5 checks (notifications, exact alarms, battery optimisation, sound on silent / alarm channel, times up to date), step-by-step fixes, adhan voice choice and preview, test adhan in 1 minute, last delivered time (Android) |
| **Adhan delivery** | Local scheduled notifications only (never server push). Rescheduled on boot, time change, timezone change and app update |
| **Quran reader** | Full Uthmani Arabic text bundled offline. Read, Listen and Memorise modes. Translations EN and UR (downloadable packs). Free reciters (streamed, with optional download per surah). Bookmarks. Memorisation mode (hide words, repeat count) |
| **Family** (Plus) | Family with up to 6 people. Guardian and member accounts, **child profiles without accounts**. Weekly salah grid, Quran journey per member, preset encouragements delivered as push. Invite by code |
| **Ramadan mode** | Auto-on during Ramadan (Hijri on device, ±2 day manual adjustment). Suhoor/iftar times, fasting log (local only), tonight's plan checklist, daily du'a |
| **Zakat** | Guided calculator (cash, gold, silver, investments, debts), gold/silver nisab toggle, live metal prices by currency, 2.5% result. A saved yearly record stays **on the device**. Optional server sync of records (Plus, explicit opt-in) |
| **Travel** | City change detection on app open and on timezone change. Suggested method per country with an explanation. Keep-madhab option. Qibla compass. Times in the new city with the offset to home. Masjids nearby (coarse-cell query, distance computed on device) |
| **Masjids (congregant)** | Search by name or coarse area, view detail, iqamah timetable and announcements, follow/unfollow (needs an account), pick audience groups (e.g. Sisters) |
| **Sakina Plus** | Paywall screen (free vs Plus), yearly/monthly via RevenueCat, 7-day trial, push reminder 2 days before the first charge, restore purchases, entitlement shared across family members |
| **Accounts** | Optional. Worship needs no account. Email + password, Sign in with Apple, Google Sign-In. Delete account in app |
| **Masjid console** (Flutter web) | Sign in, iqamah timetable editing and publishing, announcements with audience. Funds and volunteer rota at API level, with UI as a launch stretch (§2.3) |
| **Backend** | REST `/api/v1` per `openapi.yaml`: auth, me, families, worship sync, Quran progress, encouragements, rates, zakat records, masjids, masjid admin, billing webhook/entitlements, diagnostics |
| **Landing page** | Static page per the design: pledge, comparison table, family, Ramadan countdown, masjid CTA, store links. No analytics scripts |

### 2.2 Out of scope (MVP)

- Ads of any kind, ad SDKs, analytics/attribution SDKs, crash SDKs that collect device identifiers **(permanent, not just MVP)**
- Server-side prayer-time computation or any server receipt of precise location **(permanent)**
- Collecting zakat or donations through Sakina. Online payment processing for masjid donations (needs a licensed partner). The "Give via partner" button opens the partner's site externally
- AI features (tafsir chat, recitation correction)
- End-to-end encrypted sync (planned for v1.1, see [D-7]). MVP sync is encrypted in transit and at rest
- Halal travel/Umrah booking, referral commissions, halal-investing referrals
- Indonesian and Turkish translations/UI (the onboarding tile shows "coming soon")
- Home-screen widgets and themes (Plus, v1.1). Memorisation insights (Plus, v1.1). The Plus screen lists them as "coming soon"
- Masjid lobby screen, printable timetable PDF, masjid console self-serve billing (masjids are invoiced manually at launch)
- Tablet-optimised layouts (the app must work on tablets but needs no bespoke layout)
- Wear OS / watchOS, Apple CarPlay

### 2.3 Launch stretch (ship if on schedule, else first post-launch release)

- Masjid console UI for **Donations by fund** and **Volunteer rota** (the API ships in MVP)
- Downloadable reciter packs for whole-Quran offline audio

---

## 3. User stories and acceptance criteria: mobile screens

Format: **ID, story**, then acceptance criteria (AC) written so each can become one or more tests. "Widget test" means a Flutter widget test; "device test" means the manual/automated device matrix in §7.6.

### 3.1 Onboarding (`Onboarding.dc.html`)

**ONB-1.** As a new user, I see the Amanah pledge before anything else, so I know what Sakina promises.
- AC1: On first launch, step 1 of 3 shows the Bismillah (Amiri, RTL), the headline "Your prayers are not a product.", and four pledge items: No ads. Ever. / Your location stays yours / Worship is free, forever / Checked in public.
- AC2: The step indicator exposes "Step 1 of 3" to screen readers.
- AC3: "Read the full pledge and last year's transparency report" opens `https://sakina.app/amanah` in the system browser, not an in-app webview with tracking.
- AC4: The CTA "I accept this promise" advances to step 2. Nothing is sent to any server during onboarding (verified by a network-mock test that asserts zero calls).

**ONB-2.** As a new user, I choose where I pray from, so my times are right, knowing my location stays on the phone.
- AC1: "Use my location on this device" requests while-in-use location permission only, never "always".
- AC2: When permission is granted, the city name is resolved **offline** from the bundled city database (nearest city). No network geocoding.
- AC3: When permission is denied, the city search field works offline against the bundled database (prefix match, diacritic-insensitive, EN/UR/AR names).
- AC4: The calculation method defaults from the country table (e.g. PK → Karachi with Hanafi Asr, GB → Moonsighting Committee). The three design options are shown first, with "More methods" listing all supported methods.
- AC5: Exactly one method is selected (radio semantics, `aria-pressed` equivalent `Semantics(selected:)`).
- AC6: Coordinates, method and madhab are persisted locally. Restarting the app skips onboarding.

**ONB-3.** As a new user, I choose my language, so the app and translation feel like home.
- AC1: Options English, اردو, العربية. Bahasa shows "Indonesian · coming soon" and is disabled.
- AC2: Choosing Urdu or Arabic switches the app to RTL **immediately** (widget test: `Directionality.of(context) == TextDirection.rtl`).
- AC3: The Quran is always shown in Arabic. The choice sets the default translation (EN → English, UR → Urdu, AR → none).
- AC4: The CTA "Check my adhan" goes to Adhan Health and marks onboarding complete.

### 3.2 Today (`Main.dc.html`)

**TODAY-1.** As a user, I see the next prayer and a live countdown, so I know how long I have.
- AC1: The header shows the weekday, the Hijri date (e.g. "Saturday · 6 Jumada al-Ula 1448") and the Gregorian date, localised.
- AC2: "Next prayer in {city}", with the prayer name in the UI language plus the Arabic name, a countdown in `Hh Mm` that updates at least every minute, and the absolute time.
- AC3: After Isha, the next prayer is tomorrow's Fajr.
- AC4: Works in airplane mode (widget test with no network providers).

**TODAY-2.** As a user, I see today's six times with the method used, so I can trust them.
- AC1: Rows for Fajr, Sunrise, Dhuhr, Asr, Maghrib and Isha with Arabic names. Sunrise is visually muted and cannot be logged.
- AC2: The next prayer row is highlighted (night teal background). Prayed rows show "Prayed".
- AC3: The method label (e.g. "Karachi · Hanafi Asr") opens a "Why these times" sheet explaining the method, Fajr/Isha angles, Asr rule and high-latitude rule in plain language.
- AC4: Times match the reference vectors to within ±1 min (unit tests over the 30-city fixture).

**TODAY-3.** As a user, I log a prayer, and my streak is gentle.
- AC1: Tapping a past or current prayer row offers "Prayed" / "Prayed late" / "Clear".
- AC2: Streak card copy: "{n} days of Fajr on time", with the sub-line "Missed one? Your streak rests, it doesn't reset."
- AC3: Streak rule: consecutive days with Fajr ON_TIME. A day not logged pauses the streak ("rests"); it never zeroes it [D-11]. Unit-tested.
- AC4: Logs are stored locally. If the user is a family member with sharing on, logs are queued to the sync outbox (FAM-6).

**TODAY-4.** As a user, I switch between my home city and my current city when they differ (city chips).
- AC1: Chips appear only when a travel city is active. Selecting one switches all displayed times and the Qibla.

**TODAY-5.** Navigation.
- AC1: A bottom nav with Today, Quran, Family, More. "More" leads to Ramadan (when relevant), Zakat, Travel, Masjids, Plus, Settings.
- AC2: Each nav item has a minimum 48×48 dp hit area and an accessible label. The current item is announced as selected.

### 3.3 Adhan Health (`AdhanHealth.dc.html`)

**ADHAN-1.** As an Android user, I see whether anything could stop my adhan, so I can fix it before I miss a prayer.
- AC1: A ring shows `{pass}/5`, with the summary "Everything is set…" at 5/5 and "One setting could stop your adhan…" otherwise.
- AC2: The five checks are evaluated live from platform APIs:
  1. Notifications allowed (`POST_NOTIFICATIONS` on Android 13+, authorisation status on iOS)
  2. Exact alarms (`AlarmManager.canScheduleExactAlarms()` on Android 12+; on iOS always passes)
  3. Battery optimisation (`PowerManager.isIgnoringBatteryOptimizations`, plus an OEM heuristic for Samsung "Sleeping apps" and Xiaomi "Autostart")
  4. Sound on silent: the Android notification channel uses alarm audio attributes and the channel is not muted. On iOS this is "Sound enabled", plus an explanation that iOS limits the adhan to 30 s
  5. Times up to date: the schedule covers at least the next 48 h and was computed for the current city and timezone
- AC3: A failing check expands with the numbered steps and a **Fix** button that deep-links to the right settings screen (OEM-specific intent when known, generic otherwise).
- AC4: On return to the app (`AppLifecycleState.resumed`), checks re-run automatically.
- AC5: Unit tests cover each check's mapping from platform state to pass/fail via a fake `PlatformHealthProbe`.

**ADHAN-2.** As a user, I choose and preview my adhan voice.
- AC1: Voice list (at least Makkah, Madinah, Mishary Alafasy) bundled offline. Preview plays and stops. Selection persists.
- AC2: Fajr can use a separate voice (default: a Fajr-specific adhan where available).

**ADHAN-3.** As a user, I send a test adhan.
- AC1: "Send a test adhan in 1 minute" schedules a local notification 60 s ahead through the **same code path** as real adhans.
- AC2: On Android, the delivery timestamp is recorded locally and shown as "Last delivered on time: {prayer} today, {time}" (on time means within ±60 s). On iOS the line reads "Next adhan scheduled: {prayer}, {time}".

**ADHAN-4.** Adhan scheduling is reliable (no UI).
- AC1: Android schedules the next 7 days (35 alarms) of exact alarms. iOS schedules the next 64 pending notifications at most (iOS limit) and refreshes on every app open and background app refresh.
- AC2: Rescheduled on `BOOT_COMPLETED`, `TIME_SET`, `TIMEZONE_CHANGED`, `MY_PACKAGE_REPLACED`, city/method change, and per-prayer toggle changes.
- AC3: Per-prayer settings: adhan / silent notification / off. The default is adhan for all five.
- AC4: The scheduler is a pure function `schedule(times, settings, now) → List<Alarm>`, unit-tested including DST transitions (Europe/London 25 Oct 2026 and 28 Mar 2027).

### 3.4 Quran (`Quran.dc.html`)

**QURAN-1.** As a reader, I open any surah offline and read the Uthmani text.
- AC1: All 114 surahs and 6,236 ayat are available with no network (bundled text). The surah header shows the name, number, ayah count and juz.
- AC2: Arabic uses Amiri, RTL, at least 26 sp by default and scales with the user's font-size setting (up to 200%) without clipping.
- AC3: Ayah markers use the 8-point star ornament with the ayah number (Arabic-Indic digits in AR locale).

**QURAN-2.** As a reader, I toggle the translation (English / Urdu / Arabic only).
- AC1: The toggle persists per user. Urdu renders in Noto Nastaliq Urdu with line height ≥ 2.2.
- AC2: When a translation pack isn't downloaded, the app offers to download it (size shown). Packs come from the content CDN (§4 of ARCHITECTURE).

**QURAN-3.** As a listener, I play recitation from free reciters.
- AC1: Listen mode plays from the current ayah with the ayah highlighted, and continues in the background with lock-screen controls.
- AC2: Every reciter is labelled "free". No reciter, translation or mode is ever behind a paywall (a test asserts that no Quran route checks entitlements).

**QURAN-4.** As a reader, I bookmark ayat and resume where I left off.
- AC1: Bookmark toggles per ayah. The bookmarks list is reachable from the header. Last read position is restored on open.
- AC2: Stored locally. With Plus and sync enabled, synced via `/me/quran-state` (QSYNC-1).

**QURAN-5.** As a learner, I use Memorise mode.
- AC1: The banner shows "Memorising · Ayah {n} of {total}" and a repeat count (1×, 3×, 5×, 10×). Words of the target ayah are hidden. Tapping a hidden word reveals it.
- AC2: Marking a surah's status (Learning / Memorised / Revising) updates the local memorisation record. For a family member with sharing on, it updates their Quran progress summary (FAM-7).

### 3.5 Family (`Family.dc.html`), Plus

**FAM-1.** As a parent with Plus, I create a family and name it ("The Rahman family").
- AC1: Requires sign-in and an active Plus entitlement. Without Plus, the Family tab shows the Plus explainer, not an error.
- AC2: The creator becomes OWNER (a guardian).

**FAM-2.** As a guardian, I add a child profile without an account.
- AC1: Fields: display name (required, ≤ 40 chars), birth year (optional), colour. Nothing else is collected about a child [D-9].
- AC2: The family total is ≤ 6 people (accounts + child profiles). The 7th addition shows "Family plan covers up to 6 people."

**FAM-3.** As a guardian, I invite my spouse or teen with a code.
- AC1: "Invite" creates an 8-character code (shown and shareable through the OS share sheet), valid for 7 days, chosen role GUARDIAN or MEMBER.
- AC2: The invitee enters the code after signing in and joins. Owners can revoke a code.

**FAM-4.** As a child on my own device, I link to my profile without creating an account.
- AC1: A guardian generates a 6-digit link code for a child profile (valid 10 minutes, single use).
- AC2: On the child's device, "I'm a child in a family" → enter code → the device receives a **child-scoped** session. It can only log that child's prayers and Quran progress and read encouragements addressed to that child.

**FAM-5.** As a parent, I see each child's salah this week.
- AC1: Child tabs (initial tile, name, age). Grid of Fajr–Isha × 7 days (Sat–Fri, week start configurable). Cells are Prayed (teal), Prayed late (gold), Not logged (outline). Header "{n} of 35".
- AC2: The grid is exposed to screen readers as one summary label ("{name} prayed {n} of 35 prayers this week") plus a per-day breakdown on focus.
- AC3: **No "missed" state exists anywhere.** Unlogged is neutral (encouragement, not surveillance).
- AC4: The data comes from `GET /families/{id}/prayer-logs?from&to`, cached locally, and readable offline.

**FAM-6.** As a member, my logs reach my family only if I choose.
- AC1: Account-holding members have a per-member "Share my prayers and Quran progress with my family" toggle, **off by default** for MEMBER and **on** for child profiles (guardian-managed).
- AC2: Logs sync through an outbox. Offline edits sync when connectivity returns. Conflicts are resolved last-write-wins per (member, date, prayer) using the client `updatedAt`.

**FAM-7.** As a parent, I see each child's Quran journey.
- AC1: Track (Qaida / Nazira / Hifz), label (e.g. "Juz Amma", "Para 12", "Lesson 9"), progress bar 0–100%, detail line (≤ 120 chars).
- AC2: Editable by guardians, and by the member themself (or a linked child device).

**FAM-8.** As a parent, I send an encouragement.
- AC1: Presets "MashaAllah, Fajr every day!", "Proud of your Quran today" and "Let's pray Isha together" (localised by key), plus an optional custom note ≤ 140 chars.
- AC2: Confirmation "Sent. {name} will see it after Maghrib."
- AC3: The recipient device receives a data-only push and shows a local notification after its **locally computed** Maghrib (or immediately if Maghrib has passed and before Isha ends; otherwise at the next Maghrib) [D-6]. The server never learns the child's location or prayer times.
- AC4: Encouragements are also listed in-app (`GET /families/{id}/encouragements?memberId=`).

### 3.6 Ramadan (`Ramadan.dc.html`)

**RAM-1.** As a fasting user, Ramadan mode shows suhoor and iftar times.
- AC1: Automatically available from 29 Sha'ban to 1 Shawwal (Hijri on device). Users can shift the Hijri date ±2 days to match their local moonsighting.
- AC2: Header "Ramadan {year} · Day {n}" and "Iftar in {h}h {m}m". Cards: "Suhoor ends {time}" (Fajr minus a configurable precaution, default 5 min, with "Fajr adhan {time}") and "Iftar · Maghrib {time}" with the difference from yesterday.

**RAM-2.** As a fasting user, I keep a fasting log.
- AC1: A 30-day grid: kept (gold), today (outline), future (muted). Tapping a past day toggles Kept / Not fasted / To make up. The summary reads "{n} kept · {m} to make up".
- AC2: **Local only. Never synced, in any tier** [D-10].

**RAM-3.** As a fasting user, I follow tonight's plan.
- AC1: Checklist items (Taraweeh with time and place, Juz reading with page estimate, evening adhkar) are user-editable. A Khatam plan auto-distributes the juz to finish by a chosen night (default 27).
- AC2: The du'a card shows the iftar du'a in Arabic (Amiri) with the translation in the UI language.

### 3.7 Zakat (`Zakat.dc.html`)

**ZAKAT-1.** As a user, I calculate zakat using live metal prices.
- AC1: Steps: (1) zakat year and currency, (2) wealth (cash and bank, gold, silver, shares and funds (zakatable portion), debts due now), (3) result.
- AC2: Shows the current gold 24k and silver price for the chosen currency from `GET /rates/metals?currency=` with "updated {time}". If offline, it uses the last cached rate with a "stale" label. If there's no rate at all, it asks the user to enter a price manually.
- AC3: Gold and silver can be entered in grams or tola (1 tola = 11.6638 g).
- AC4: Nisab toggle: Silver (612.36 g) / Gold (87.48 g). Zakat due = 2.5% × net wealth when net ≥ nisab, else 0. Unit-tested with fixed rates. All money uses decimal arithmetic, never doubles.
- AC5: Footer shows "Method reviewed by {scholar board}" and the giving disclaimer. "Give via partner" opens the external partner URL. Sakina never holds zakat.
- AC6: The calculator is free and needs no account.

**ZAKAT-2.** As a user, I save a yearly record.
- AC1: "Save to {year} record" stores it **on the device** by default (copy: "Amounts stay on this phone").
- AC2: With Plus, an explicit "Back up my zakat records" toggle (off by default, with a privacy explainer) syncs records via `/me/zakat-records`. Turning it off offers to delete server copies.

### 3.8 Travel (`Travel.dc.html`)

**TRAVEL-1.** As a traveller, the app notices I've arrived somewhere new and adjusts.
- AC1: On app open and on OS timezone-change events, the device location (if permitted) is compared with the active city. If it is more than 50 km away, or in a different timezone, the arrival card appears: "You've arrived in {city}". No background location is used [D-8].
- AC2: The card explains the method chosen for the new country ("Times now follow … the most common choice among {city} masjids") and offers "Keep {madhab} Asr" and "Why this method?".
- AC3: Home city stays saved. Today shows city chips (TODAY-4). The day grid shows "{home} {±offset}".

**TRAVEL-2.** As a traveller, I find the Qibla.
- AC1: A compass shows the bearing to the Kaaba (great-circle, computed on device), compass direction words, and distance to Makkah.
- AC2: A calibration state is shown ("Compass calibrated" / "Move your phone in a figure 8"). Falls back to a static bearing with a north reference if there is no magnetometer.

**TRAVEL-3.** As a traveller, I see masjids nearby.
- AC1: The app sends only coarse geohash cells (precision 4, about 39 × 20 km) to `GET /masjids?cells=`. Distances and sorting are computed on device.
- AC2: Each row shows the name, distance and area, and the next iqamah if the masjid publishes on Sakina. Tapping opens masjid detail. "Directions" opens the OS maps app with the masjid's coordinates (an outbound intent, not an API call).

### 3.9 Masjids (congregant), no design board; follows the Travel and Today patterns

**MASJID-1.** As a user, I search masjids by name or area and open one.
- AC1: Search by text (`q`) or coarse cells. Results are paginated. Detail shows the name, address, iqamah timetable for the week, announcements, and a "publishes on Sakina" badge for verified masjids.

**MASJID-2.** As a signed-in user, I follow a masjid to get its announcements as push.
- AC1: Follow/unfollow. While following, I choose audience groups that the masjid offers (e.g. "Sisters", "Volunteers"). "Everyone" is implicit.
- AC2: Without an account, I can still view the masjid, and "Follow" prompts sign-in with an explanation of why.
- AC3: Followed masjids' iqamah times appear on Today as a secondary line under each prayer ("Iqamah 4:15 PM · Masjid an-Noor").

### 3.10 Sakina Plus (`Plus.dc.html`)

**PLUS-1.** As a user, I understand what Plus pays for.
- AC1: Two columns. "Always free": Prayer times and adhan / Every reciter / All translations / Memorisation mode / Qibla, Ramadan, zakat. "With Plus": Family dashboard, up to 6 / Sync across devices / Travel planner* / Themes and widgets* / Memorisation insights* (*"coming soon" badge in MVP).
- AC2: Copy says "Sync across devices, encrypted in transit and at rest" until E2EE ships [D-7].

**PLUS-2.** As a user, I start a trial and subscribe.
- AC1: Plans come from RevenueCat offerings: Family yearly $29.99 ("Save 37%", "$2.50 a month") and Family monthly $3.99. Store-localised prices are shown when available (e.g. PKR).
- AC2: The CTA reads "Start 7 free days · then {price}/{period}". The note says "We remind you 2 days before any charge, and you can cancel in one tap."
- AC3: Purchase needs sign-in first (so the entitlement binds to the Sakina user ID). "Restore purchases" is available.
- AC3a: "Cancel in one tap" means one tap into the store's subscription management screen, which the app opens directly.
- AC4: After purchase, `GET /me/entitlements` reflects `plus.active = true` within 60 s (webhook path) or immediately (the client refresh endpoint).
- AC5: "Continue with free Sakina" closes the paywall. The paywall is never shown unprompted more than once per 30 days.

**PLUS-3.** As a family member, I get Plus through my family's owner.
- AC1: Every account member of a family whose owner has an active Plus has `plus.active = true` with `source = FAMILY`.

### 3.11 Settings and account (no design board; uses design tokens)

**SET-1.** Account: sign in / sign up (Apple, Google, email), sign out, **delete account** (two-step confirmation, then `DELETE /me`). Local data is kept unless the user also chooses "Erase this device".
- AC1: Deleting the account removes all server data for the user within 24 h (see ME-3), and the user is told that the store subscription must be cancelled in the store (with a deep link).

**SET-2.** Prayer settings: method, madhab (Asr), high-latitude rule, per-prayer minute adjustments (±30), per-prayer adhan mode, Hijri adjustment (±2).

**SET-3.** Language and numerals: EN / UR / AR. Digit style follows the locale by default (Western for EN; Arabic-Indic for AR; Extended Arabic-Indic for UR), with a "Use 0–9 digits" override.

**SET-4.** Privacy: a "What leaves this phone" screen listing exactly which data is synced (by feature, live from the settings toggles), with links to the pledge and privacy policy.

**SET-5.** Diagnostics: "Send a diagnostic report" shows the report contents (app version, OS, device model, adhan-health results, last 50 scheduler log lines with times only) for review before sending to `POST /diagnostics/reports`. It never contains coordinates or a city name.

### 3.12 Masjid console, web (`MasjidConsole.dc.html`)

**CONSOLE-1.** As a masjid admin, I sign in and see my masjid's overview.
- AC1: Sign-in uses the same Sakina account. The console lists the masjids where the user has an admin role (OWNER / ADMIN / EDITOR).
- AC2: Overview stats: followers, announcement open rate (when available from OneSignal), rota filled, donations this month (manual entries).

**CONSOLE-2.** As an admin, I edit and publish the weekly iqamah timetable.
- AC1: Table of Fajr, Dhuhr, Asr, Maghrib, Isha and Jumu'ah with the adhan time (computed in the browser from the masjid's own public coordinates and method), iqamah time, and rule (Fixed / Adhan + N min / Khutbah time).
- AC2: Edits are a draft ("Draft · {n} change") until "Publish this week", which shows "Publishing notifies {followers} phones" and then "Published to {n} phones".
- AC3: Publishing sends one push to followers ("Iqamah times updated") unless the change is only within the current day's already-passed prayers.

**CONSOLE-3.** As an admin, I send an announcement to an audience.
- AC1: Title (≤ 80), message (≤ 500), audience (Everyone / a group), and a "Send to {count}" button showing the live count.
- AC2: The sent list shows the title, date, audience and opens (when available).

**CONSOLE-4 (stretch UI).** Donations by fund (name, goal, amount this month, ring-fenced zakat flag) and manual donation entries. **CONSOLE-5 (stretch UI).** Volunteer rota: shifts with role, time, assignees, and a Needed/Confirmed state.

### 3.13 Landing page (`Landing.dc.html`)

**LAND-1.** The pledge is front and centre, with the comparison table, the family section, a Ramadan countdown computed client-side, a masjid CTA and store links.
- AC1: No third-party scripts except self-hosted fonts. No cookies. Lighthouse accessibility ≥ 95, performance ≥ 90.
- AC2: The Ramadan countdown reads its target date from a static JSON file, so ops can update it without redeploying code.

---

## 4. User stories and acceptance criteria: backend features

All endpoints are defined in `openapi.yaml`. Every story implies these **cross-cutting ACs (X)**, which are tested per endpoint:
- **X1** Unauthenticated calls to protected endpoints return `401` problem+json with code `UNAUTHENTICATED`.
- **X2** Accessing another tenant's resource returns `404` (never `403`) so that existence is not revealed. Each resource gets an explicit cross-tenant integration test.
- **X3** Invalid bodies return `422` with code `VALIDATION_FAILED` and an `errors` map keyed by camelCase JSON path.
- **X4** Responses never include fields that are not in the contract (contract test).
- **X5** Rate-limited calls return `429` with `Retry-After`.

### 4.1 Accounts (auth and me)

**AUTH-1. Register.** `POST /auth/register` {email, password, displayName?, locale?} → 201 with tokens and user.
- AC1: Email is normalised (trim + lowercase) and must be unique. A duplicate returns `409 EMAIL_TAKEN`.
- AC2: Password is 10–128 chars and is checked against a bundled top-100k breached-password list → `422`.
- AC3: Passwords are hashed with ASP.NET Core `PasswordHasher<T>` (PBKDF2-HMAC-SHA512, 600k iterations; see ADR-0008).

**AUTH-2. Login.** `POST /auth/login` → 200 tokens.
- AC1: Wrong email and wrong password return the same `401 INVALID_CREDENTIALS` with similar timing.
- AC2: 5 failed attempts per email per 15 min trigger `429`.

**AUTH-3. Refresh.** `POST /auth/refresh` {refreshToken} → 200 with a new access token **and a new refresh token** (rotation).
- AC1: The old refresh token is invalid after use.
- AC2: Reusing a rotated token revokes the whole token family (all sessions from that login) → `401 REFRESH_TOKEN_REUSED`.

**AUTH-4. Social sign-in.** `POST /auth/social` {provider: GOOGLE|APPLE, idToken, nonce?, displayName?} → 200 (existing) or 201 (new).
- AC1: The token signature is verified against the provider JWKS (cached, refreshed on unknown `kid`), along with `iss`, `aud` (our client IDs), `exp`, and `nonce` for Apple.
- AC2: Users are matched by (provider, subject). A provider email that matches an existing password account is **not** auto-linked → `409 ACCOUNT_EXISTS` [D-12].
- AC3: An Apple private-relay email is stored as given. Apple only supplies the display name on first sign-in, so the client passes it.

**AUTH-5. Logout.** `POST /auth/logout` {refreshToken, allDevices?} → 204. Revokes that token family, or all of the user's families when `allDevices` is true.

**AUTH-6. Password reset.** `POST /auth/password/forgot` {email} → 202 always (no enumeration), and sends a single-use link valid for 30 min. `POST /auth/password/reset` {token, newPassword} → 204 and revokes all refresh tokens.

**AUTH-7. Child device link.** `POST /auth/child-link` {code} → 200 child-scoped tokens (`scope=child`, `sub` = child profile ID). The code is 6 digits, single use, valid 10 min, with 5 attempts per IP per 10 min. Child tokens can call only: prayer-log sync for that child, Quran progress for that child, encouragements for that child, and logout.

**ME-1. Get me.** `GET /me` → user profile: id, email, displayName, locale, createdAt, preferences (notification toggles), families (IDs + roles).

**ME-2. Update me.** `PATCH /me` (JSON merge patch semantics) with displayName, locale and preferences. Email change is not in MVP.

**ME-3. Delete me.** `DELETE /me` → 202.
- AC1: Revokes tokens immediately. Within 24 h it hard-deletes the user, their prayer logs, Quran state, zakat records, follows, memberships and admin roles. A family the user owns is transferred to the longest-standing other guardian, or deleted with its child profiles if there is none. Masjids the user solely owns are flagged for staff follow-up, not deleted.
- AC2: Deletes the OneSignal user by external ID and requests deletion of the RevenueCat subscriber's personal attributes (the purchase history itself is the store's).
- AC3: Writes an audit row with no personal data (user ID hash, timestamp).

### 4.2 Families

**FAMAPI-1.** `POST /families` (Plus required, else `403 PLUS_REQUIRED`) → 201. A user can own at most one family and belong to at most two.
**FAMAPI-2.** `GET /families/mine` → the families the caller belongs to, with members.
**FAMAPI-3.** `PATCH /families/{id}` (OWNER) to rename. `DELETE /families/{id}` (OWNER) deletes the family and all its child profiles and logs.
**FAMAPI-4.** `POST /families/{id}/invites` (guardian) → code. `GET` lists active codes. `DELETE /families/{id}/invites/{inviteId}` revokes one.
**FAMAPI-5.** `POST /families/join` {code} → 200 membership. Errors: `404 INVITE_NOT_FOUND` (also for expired or revoked codes, so nothing is enumerable), `409 ALREADY_MEMBER`, `409 FAMILY_FULL`. Limited to 10 attempts per user per hour.
**FAMAPI-6.** `GET /families/{id}/members`, `PATCH /families/{id}/members/{memberId}` (role change by OWNER; `shareWorship` by self), `DELETE …/members/{memberId}` (remove by OWNER/guardian, or leave by self; the OWNER cannot leave without transferring ownership).
**FAMAPI-7.** Child profiles: `POST /families/{id}/children` {displayName, birthYear?, color} (guardian), `PATCH`, `DELETE`. `POST /families/{id}/children/{childId}/link-codes` (guardian) → 6-digit code (AUTH-7).
**FAMAPI-8.** Entitlement gate: while the owner's Plus is inactive, the family is **read-only** (writes → `403 PLUS_REQUIRED`) for 90 days, then soft-archived. Nothing is deleted without notice.

### 4.3 Worship sync

**SYNC-1. Prayer logs.** `PUT /families/{id}/prayer-logs` (batch upsert, ≤ 200 entries) with entries {memberId, date (YYYY-MM-DD local), prayer (FAJR|DHUHR|ASR|MAGHRIB|ISHA), status (ON_TIME|LATE|null), clientUpdatedAt}.
- AC1: Only members with `shareWorship = true` can be written. A writer must be that member, a linked child device for that child, or a guardian writing for a child profile.
- AC2: Last-write-wins per (memberId, date, prayer) by `clientUpdatedAt`. Older writes are ignored and reported back in `results[].applied=false`.
- AC3: `status: null` deletes the entry ("Not logged").
- AC4: Dates more than 1 day in the future or older than 400 days → `422`.
- AC5: The response reports per-entry results plus `serverTime`.

**SYNC-2.** `GET /families/{id}/prayer-logs?from&to&memberId&updatedSince` → entries. The `from`/`to` range is ≤ 62 days. Visible to all family members, for members who share.

**SYNC-3. Quran progress (family-visible).** `GET /families/{id}/members/{memberId}/quran-progress` and `PUT` the same path {track, label, percent, detail, memorisedSurahs[]} (≤ 120-char detail; surahs 1–114 unique).

**QSYNC-1. Personal Quran state (Plus sync).** `GET /me/quran-state` → {bookmarks[], lastRead, memorisation{}, version} with an `ETag`. `PUT /me/quran-state` with `If-Match` → 200, or `412 VERSION_CONFLICT` with the current document so the client can merge. Max 256 KB.

**ENC-1. Encouragements.** `POST /families/{id}/encouragements` {toMemberId, presetKey? | text?} (guardian; or any member to another member) → 201, and enqueues a OneSignal data-only push to the recipient's external ID (an account user, or the child device's child external ID).
- AC1: Supports an `Idempotency-Key` header. Max 10 per sender per recipient per day.
- AC2: `GET /families/{id}/encouragements?memberId&cursor` lists them, newest first. Recipients can mark one seen: `POST …/{encId}/seen`.

### 4.4 Rates

**RATES-1.** `GET /rates/metals?currency=PKR` (anonymous) → {currency, gold24kPerGram, silverPerGram, asOf, source, isStale}.
- AC1: Upstream is fetched at most every 15 min per currency and cached in memory and in Postgres (`metal_rates`). If the upstream fails, the response serves the last known value with `isStale: true` (if it is younger than 72 h), otherwise `503 RATES_UNAVAILABLE`.
- AC2: Supported currencies are listed by `GET /rates/currencies`. Others return `422`.
- AC3: Values are decimals serialised as strings (to avoid float loss), e.g. `"23714.55"`.
- AC4: `Cache-Control: public, max-age=300`.

### 4.5 Zakat records (Plus)

**ZREC-1.** `GET/POST /me/zakat-records`, `GET/PUT/DELETE /me/zakat-records/{id}`. Each record has {hijriYear, gregorianDate, currency, nisabStandard (GOLD|SILVER), ratesUsed{gold,silver}, assets{cash, gold, silver, investments, other}, liabilities, netWealth, zakatDue, notes?}. Plus required → `403 PLUS_REQUIRED`. `DELETE /me/zakat-records` (collection) deletes all of them (used when backup is turned off).

### 4.6 Masjids (public and congregant)

**MASJIDAPI-1.** `GET /masjids?cells=tsq4,tsq5&q=&cursor&limit` (anonymous allowed).
- AC1: `cells` take 1–9 geohashes of **exactly 4 characters**. Any other length → `422 LOCATION_TOO_PRECISE` / `VALIDATION_FAILED`. The server never accepts lat/lng parameters.
- AC2: Returns public masjid data including coordinates (public places), so the client can compute distance. Only `PUBLISHED` masjids are returned.
- AC3: The API never logs the `cells` parameter (a log-scrubbing test asserts this).

**MASJIDAPI-2.** `GET /masjids/{id}` → detail. `GET /masjids/{id}/iqamah?weekStart=` → the published timetable for the week. `GET /masjids/{id}/announcements?cursor` → published announcements (EVERYONE audience for anonymous callers; group audiences only for followers in that group).

**MASJIDAPI-3.** `PUT /masjids/{id}/follow` {groupIds[]} (idempotent) → 200. `DELETE /masjids/{id}/follow` → 204. `GET /me/follows` → followed masjids.

### 4.7 Masjid administration

**ADMIN-1.** Roles per masjid: OWNER, ADMIN, EDITOR. EDITOR can edit drafts and post announcements; ADMIN also manages funds, rota and groups; OWNER also manages roles. All role checks are object-level (§ARCHITECTURE 6.2).
**ADMIN-2. Masjid registration.** `POST /admin/masjids` (any signed-in user) → 201 in `PENDING_VERIFICATION`. Sakina staff verify it out-of-band (phone or letter) and set it to `PUBLISHED` through the staff-only `POST /staff/masjids/{id}/verify`, using the `staff` role claim. This prevents impersonation of masjids.
**ADMIN-3. Iqamah.** `GET /admin/masjids/{id}/iqamah/draft?weekStart` and `PUT` the same path → upsert of the draft rows. `POST /admin/masjids/{id}/iqamah/publish` {weekStart, notify: true} → 200 with {publishedAt, notifiedCount}. Publishing is idempotent per draft version.
**ADMIN-4. Announcements.** `POST /admin/masjids/{id}/announcements` {title, body, audience: {type: EVERYONE|GROUP, groupId?}, sendPush: true} → 201. Push fan-out runs asynchronously through the outbox, in OneSignal batches of ≤ 2,000 external IDs. `GET` lists them with stats.
**ADMIN-5. Groups.** `GET/POST/PATCH/DELETE /admin/masjids/{id}/groups` (e.g. "Sisters", "Volunteers"). Group membership is chosen by followers themselves; admins cannot add people to groups.
**ADMIN-6. Funds.** `GET/POST/PATCH/DELETE /admin/masjids/{id}/funds` {name, goalAmount?, currency, isZakatRingFenced}. `POST /admin/masjids/{id}/funds/{fundId}/entries` {amount, receivedOn, method: CASH|BANK|OTHER, note?} for manual donation records. No donor personal data is stored.
**ADMIN-7. Volunteer rota.** `GET/POST/PATCH/DELETE /admin/masjids/{id}/rota/shifts` {date, role, startTime, endTime, needed, assignees: [{name, userId?}]}, with status computed as Needed/Confirmed. Assignee names are free text entered by admins. Linking `userId` needs the user's consent through a follow plus group membership.
**ADMIN-8. Roles.** `GET/PUT/DELETE /admin/masjids/{id}/roles/{userId}` (OWNER only), by invite code like families.

### 4.8 Billing

**BILL-1. RevenueCat webhook.** `POST /billing/revenuecat/webhook` with `Authorization: Bearer <shared secret>`.
- AC1: A wrong or missing secret returns `401`, compared in constant time.
- AC2: Idempotent on `event.id` (duplicates → 200 no-op).
- AC3: On any event, the service fetches the subscriber from the RevenueCat REST API (`GET /v1/subscribers/{app_user_id}`) and recomputes the `plus` entitlement. This makes processing order-independent.
- AC4: Responds within 5 s. Heavy work is deferred to the outbox, and a `200` is returned once the event is persisted.
- AC5: Handles `TEST` events. `TRANSFER` updates both users.

**BILL-2. Entitlements.** `GET /me/entitlements` → {plus: {active, source: PURCHASE|FAMILY|NONE, productId?, expiresAt?, willRenew?, isTrial?}}. `POST /me/entitlements/refresh` forces a RevenueCat fetch (rate-limited to 6 per user per hour).

**BILL-3. Trial reminder.** For a trial whose first charge is due, a push is sent 48 h ± 1 h before `expiresAt`: "Your Sakina Plus trial ends in 2 days. You won't be charged if you cancel before {date}."

### 4.9 Notifications

**NOTIF-1.** OneSignal is the only push channel. The `external_id` is the Sakina user ID, or `child:{childProfileId}` for child devices. No tags, location or personal data are ever sent to OneSignal. Pushes carry template keys plus IDs. Masjid announcements carry the admin-authored title and body.
**NOTIF-2.** Users control push categories through `PATCH /me` preferences: `encouragements`, `masjidAnnouncements`, `billingReminders` (all on by default). The server checks preferences before sending.
**NOTIF-3.** Failures are retried with exponential backoff (max 5 attempts) through the outbox, with dead-letter rows visible in logs and metrics.

### 4.10 Diagnostics

**DIAG-1.** `POST /diagnostics/reports` (anonymous allowed, 3 per IP per day, ≤ 64 KB) stores the user-reviewed report for 30 days. The schema forbids coordinate-like fields, and the server rejects reports that contain coordinate-looking patterns (`422`).

---

## 5. Non-functional requirements

### 5.1 Privacy (the Amanah pledge, made testable)

| ID | Requirement | Verification |
|---|---|---|
| P1 | No ads, ad SDKs, analytics/attribution SDKs, or advertising-ID access. iOS has no ATT prompt because none is needed. The Android manifest removes `com.google.android.gms.permission.AD_ID` | CI script greps `pubspec.lock` against a deny-list. Merged-manifest check in the release build |
| P2 | Precise location never leaves the device. Only geohash-4 cells are sent (masjid search). No reverse geocoding over the network | Unit test of the API client. Release proxy-capture test (mitmproxy) on the onboarding + Today + Travel flows |
| P3 | Prayer times, Qibla, Hijri date and Ramadan dates are computed on device | Architecture rule: no endpoint exists for them |
| P4 | Server data is only what the user explicitly syncs: account, family membership, shared prayer logs/Quran progress, opt-in Quran state and zakat records, masjid follows | Data inventory in ARCHITECTURE §5 is reviewed at each schema change |
| P5 | Fasting logs and any data that could reveal menstruation (no "excused" status) are never synced | There is no such field in the contract |
| P6 | Third-party processors get the minimum: OneSignal (opaque external ID, push content), RevenueCat (opaque app user ID, purchases), metals rate provider (currency code only), email provider (email address for resets) | ADRs 0005 and 0006 |
| P7 | GDPR: religious-belief data is Article 9 special category. Explicit consent is given at sign-up and at each sync toggle. Data export via `GET /me/export` (post-MVP; manual on request at launch). Erasure via `DELETE /me` | Privacy review before launch |
| P8 | Children: child profiles store only a display name, optional birth year and a colour. Created by a guardian (parental consent). No push to a child device unless a guardian linked it | Contract schema |
| P9 | Server logs never contain request or response bodies, tokens, emails, or query strings for `/masjids` | Serilog destructuring policy + log-scrubbing integration test |
| P10 | OneSignal SDK: location sharing off (`OneSignal.Location.setShared(false)`), in-app messages unused, no tags | Code review checklist + unit test on the init wrapper |
| P11 | Fonts and content are bundled or served from Sakina's own CDN. No runtime Google Fonts or third-party CDNs that receive user IPs per request | Network capture |

### 5.2 Security

- TLS 1.2+ only. HSTS on the API and console. The mobile app pins the API's public key (two pins: current and backup) [D-13].
- JWT access tokens: 15 min, HS256 with a 256-bit secret from the environment (ADR-0008), claims `sub`, `scope` (`user` | `child`), `roles` (`staff` when applicable), `jti`, `iat`, `exp`. Refresh tokens: 30 days sliding, opaque 256-bit random, stored as SHA-256 hashes, rotated on each use with reuse detection.
- Mobile stores tokens in the Keychain / Android Keystore (`flutter_secure_storage`).
- Object-level authorisation on every resource, with cross-tenant tests (X2).
- Rate limiting via ASP.NET Core `RateLimiter` (ARCHITECTURE §6.4).
- Secrets only from the environment or the host's secret store, with separate keys per environment. The RevenueCat webhook secret, OneSignal REST key and JWT key are rotated at least yearly.
- Dependency scanning (Dependabot for NuGet, pub, GitHub Actions). `dotnet list package --vulnerable` runs in CI.
- OWASP ASVS L2 as the review checklist for auth and session handling.

### 5.3 Offline-first

- Everything in worship works with **no network, indefinitely**: Today, adhan, Qibla, Quran text, bundled translations (EN), downloaded packs, Ramadan, the zakat calculator (with cached or manual rates), and the self prayer log.
- Synced features (Family, Quran state, zakat backup) read from the local database first and sync in the background through an **outbox** with retry. The UI never blocks on the network, and a "Last synced {time}" label is shown.
- A cold start to the Today screen takes under 1.5 s on a mid-range Android (Samsung A14 class) in release mode.

### 5.4 Internationalisation

- UI languages at launch: **English, Urdu, Arabic**. Urdu and Arabic are **RTL**. All layouts use directional insets/alignments, and icons that imply direction (back chevrons, progress) are mirrored.
- Strings live in ARB files (`lib/l10n/app_en.arb`, `app_ur.arb`, `app_ar.arb`) using ICU plural/select. A CI check fails on missing keys.
- Fonts: Fraunces (EN headings), Manrope (EN UI), Noto Naskh Arabic (AR UI), Amiri (Quran text and Arabic display), Noto Nastaliq Urdu (UR UI and translation). Line-height overrides apply per script (DESIGN_TOKENS §3).
- Dates: Gregorian via `intl`. Hijri on device (Umm al-Qura tables, with the user's ±2 day adjustment). Numerals per SET-3.
- Server error messages are English for developers. The client maps the problem `code` to localised copy. Push content uses template keys that the client localises, except masjid-authored text.
- Translation content (Quran translations, du'a translations) is reviewed by the scholar board before release.

### 5.5 Accessibility

- WCAG 2.2 AA equivalent on mobile and web: text contrast ≥ 4.5:1 (≥ 3:1 for large text and UI components). DESIGN_TOKENS §2.4 lists the design pairs that fail, with fixes.
- Touch targets ≥ 48×48 dp (Android) / 44×44 pt (iOS). The designs already use 44–60 px.
- Every icon-only button has a semantic label (the designs specify `aria-label`s, which map to `Semantics(label:)` / `tooltip`).
- Supports text scaling to 200% without truncating prayer times or Quran text (widget tests at `textScaler: TextScaler.linear(2.0)`).
- Reduce motion: the countdown and ring animations are disabled when `MediaQuery.disableAnimations` is set.
- Screen reader pass (TalkBack and VoiceOver) on every MVP screen in EN and AR before launch.
- Colour is never the only signal. The salah grid uses a shape or pattern for "late" in addition to gold.

### 5.6 Reliability and performance (backend)

- Availability target 99.5% monthly for the API. Mobile worship features do not depend on it.
- p95 latency < 300 ms for reads and < 500 ms for writes, at 50 RPS on a single 2 vCPU instance.
- Announcement fan-out to 10k followers completes in < 2 min.
- Daily Postgres backups with 7-day point-in-time recovery. Restores are tested quarterly.

---

## 6. Data and privacy boundaries (summary)

### 6.1 Coarse cell definition
The geohash precision is 4, which covers about 39 km × 19.5 km at the equator. The client sends the cell containing the device plus its 8 neighbours (at most 9 cells) so that edge-of-cell masjids are found. Cells cover overlapping areas and reveal roughly a metropolitan area, which is accepted as non-identifying for this purpose.

### 6.2 What the server stores

| Data | When | Tier |
|---|---|---|
| Email, password hash or social subject, display name, locale, preferences | Only if the user creates an account | Free |
| Family, memberships, child profiles (name, birth year, colour) | Only if a family is created or joined | Plus |
| Prayer logs (date, prayer, ON_TIME/LATE) | Only for members with sharing on | Plus |
| Quran progress summary (family) | Only for members with sharing on | Plus |
| Quran state (bookmarks, last read, memorisation) | Only if sync is turned on | Plus |
| Zakat records | Only if backup is turned on (off by default) | Plus |
| Masjid follows and self-selected groups | Only if the user follows | Free (account) |
| Entitlement state | From RevenueCat | n/a |
| Encouragements | When sent | Plus |
| Diagnostic reports (30-day retention) | Only when the user sends one | Free |

---

## 7. Engineering workflow

### 7.1 Tech stack (fixed by the founder)

| Layer | Choice |
|---|---|
| Mobile | Flutter (stable 3.x) / Dart 3, Riverpod, go_router, Drift (SQLite), Dio, flutter_local_notifications, adhan (Dart), purchases_flutter (RevenueCat), onesignal_flutter, flutter_secure_storage |
| Console | Flutter web (same repo, `apps/mobile` with a `console` entrypoint, ADR-0002) |
| Backend | ASP.NET Core 8 (LTS) Web API, C# 12, Clean Architecture (Domain / Application / Infrastructure / Api) |
| Data | PostgreSQL 16, EF Core 8 + Npgsql, code-first migrations |
| Validation | FluentValidation |
| Auth | Custom users + `PasswordHasher<T>`, JWT bearer + rotating refresh tokens, Google and Apple ID token verification |
| Push | OneSignal (REST API from Infrastructure; Flutter SDK on device) |
| Subscriptions | RevenueCat (SDK on device; webhook + REST API on the server) |
| Logging | Serilog (JSON to stdout), OpenTelemetry metrics/traces (OTLP) |
| Tests | xUnit, FluentAssertions 7.x, NSubstitute, Testcontainers (PostgreSQL), WireMock.Net; flutter_test, mocktail, golden tests |
| CI | GitHub Actions (`backend.yml`, `mobile.yml`, `contract.yml`) |

Library versions are pinned at task B0/M0. pub.dev and NuGet are unreachable from the planning environment, so the M0/B0 builder must verify each package's current version and licence.

### 7.2 Commands

```sh
# backend
dotnet restore apps/backend/Sakina.sln
dotnet build   apps/backend/Sakina.sln -c Release --no-restore
dotnet test    apps/backend/Sakina.sln -c Release --collect:"XPlat Code Coverage"
dotnet format  apps/backend/Sakina.sln --verify-no-changes
dotnet ef migrations add <Name> -p apps/backend/src/Sakina.Infrastructure -s apps/backend/src/Sakina.Api
# mobile
cd apps/mobile && flutter pub get && dart format --set-exit-if-changed . && flutter analyze && flutter test --coverage
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs   # drift, riverpod_generator, freezed
# contract
npx @redocly/cli lint docs/openapi.yaml
```

Make wrappers for all of these are in the root `Makefile`.

### 7.3 Project structure
See `ARCHITECTURE.md` §3.2 (mobile) and §4.2 (backend).

### 7.4 Code style
`CONTRIBUTING.md` §7. An example of the expected backend style for an application service:

```csharp
public sealed class JoinFamilyService(
    ISakinaDbContext db, IClock clock, IValidator<JoinFamilyRequest> validator)
{
    public async Task<Result<MembershipDto>> JoinAsync(
        UserId caller, JoinFamilyRequest request, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(request, ct);
        var invite = await db.FamilyInvites.ActiveByCode(request.Code, clock.UtcNow, ct);
        if (invite is null) return Errors.Families.InviteNotFound;      // 404, not enumerable
        var family = await db.Families.WithMembers(invite.FamilyId, ct);
        var membership = family.AddMember(caller, invite.Role, clock.UtcNow); // domain enforces ≤ 6, no duplicates
        if (membership.IsFailure) return membership.Error;
        await db.SaveChangesAsync(ct);
        return membership.Value.ToDto();
    }
}
```

### 7.5 Testing strategy
`CONTRIBUTING.md` §2 (levels and gates). Prayer-time, Qibla, Hijri, zakat and scheduler logic are **pure Dart** with table-driven tests.

### 7.6 Device test matrix (adhan reliability)
Pixel 7 (Android 14/15), Samsung Galaxy A-series (One UI 6), Xiaomi Redmi (HyperOS), Oppo/Realme (ColorOS) if available, iPhone SE (iOS 17) and iPhone 15 (iOS 18). Each one: schedule a test adhan, lock the device, wait 60 s and 6 h (Doze), record delivery. This runs before every release.

### 7.7 Boundaries

- **Always:** write the test first; keep `openapi.yaml` in sync; run lint and tests before pushing; use directional layout; validate at the API boundary; return 404 for other tenants' objects.
- **Ask first (founder or architect):** a new third-party SDK or service, schema changes that add personal data, changes to the Amanah-relevant data inventory, breaking contract changes, new Plus gates.
- **Never:** add tracking, ad or analytics SDKs; send coordinates to any server; log personal data or tokens; paywall worship; commit secrets; disable a failing test to get green.

---

## 8. Success criteria (definition of done for MVP)

1. Every AC in §3 and §4 has at least one automated test (except device-matrix items), and CI is green on `main`.
2. `openapi.yaml` lints clean, and the backend contract test passes (implemented routes ⊆ contract, and every contract operation is implemented).
3. Release proxy-capture shows no precise location, no third-party analytics hosts, and no Google Fonts requests.
4. The device test matrix passes for the adhan.
5. Accessibility pass in EN and AR is complete, with no P1 issues.
6. A privacy policy and Amanah terms are published, and the scholar board has signed off on methods, translations and zakat copy.
7. Store listings are approved (iOS + Android). On Android the exact-alarm permission justification is accepted.

---

## 9. Decisions made without the founder (review list)

| ID | Decision | Rationale | Reversible? |
|---|---|---|---|
| D-1 | Backend is ASP.NET Core 8 + EF Core (founder update), with plain application services and no MediatR | MediatR v13+ needs a commercial licence; plain services are simpler (ADR-0012) | Yes |
| D-2 | Accounts are optional. Worship needs none | Pledge + landing copy "No account needed" | n/a |
| D-3 | Family is Plus-gated (create/write). Read-only for 90 days after a lapse, not deleted | Spec lists the family dashboard under Plus; no surprise data loss | Yes |
| D-4 | Child profiles have no account. A child device links via a 6-digit guardian code and gets child-scoped tokens | Lets children receive encouragements and self-log without collecting child PII | Medium |
| D-5 | No "missed" prayer state. Only ON_TIME, LATE, or not logged | "Encouragement, not surveillance" | Yes |
| D-6 | Encouragement push is data-only; the device shows it after local Maghrib | The server never knows the child's prayer times or location | Yes |
| D-7 | MVP sync is TLS + encryption at rest, not E2EE. E2EE for personal Quran state and zakat records in v1.1. Plus copy must not claim E2EE | Key management across devices and families is too risky for the launch date; honesty matters for a privacy brand | Yes (planned) |
| D-8 | No background location. Travel is detected on app open and on OS timezone-change events | Privacy and store review; the battery cost of background location | Yes |
| D-9 | A child profile stores only name, optional birth year and colour | COPPA / UK AADC data minimisation | Yes |
| D-10 | The fasting log is local only, forever | It can reveal menstruation | Permanent |
| D-11 | The streak "rests" (pauses) on unlogged days and never resets | Design copy | Yes |
| D-12 | No automatic account linking between social and password accounts at launch | Prevents account takeover; no email verification at launch | Yes |
| D-13 | Certificate (public key) pinning in the mobile app | Protects religious data on hostile networks | Yes |
| D-14 | Masjids are verified manually by staff before they are public | Prevents impersonation and fake iqamah times | Yes |
| D-15 | Masjid console = Flutter web inside `apps/mobile` (a second entrypoint) | Founder stack; reuses the design system and API client | Medium |
| D-16 | Online donations are not processed in MVP; funds take manual entries | Needs a licensed payment partner; spec says zakat goes through licensed charities | Yes |
| D-17 | Geohash precision 4 for masjid search, max 9 cells, enforced by the server | Coarse enough to be non-identifying, fine enough for useful results | Yes |
| D-18 | Money and metal rates are decimals as JSON strings | Avoids float loss in zakat | Costly later |
| D-19 | FluentAssertions pinned to 7.x (Apache-2.0); v8+ needs a commercial licence. Fallback: AwesomeAssertions | Licence | Yes |

## 10. Open questions for the founder

1. Scholar advisory board names and sign-off process (blocks method copy, translations and zakat text).
2. The Quran translation licences (English: which translation? Urdu: which?) and recitation audio rights and hosting (own CDN vs a licensed source).
3. Metals rate provider and its commercial terms (ARCHITECTURE §4.6 proposes an adapter interface, so the choice is late-bound).
4. Hosting region and provider (default proposal: EU region, containers + managed Postgres). Any Pakistan data-localisation requirement?
5. Masjid console pricing tiers ($19 / $29 / $49) and what each unlocks; invoicing tool.
6. Charity partner for "Give via partner".
7. The independent auditor for the transparency report.
8. Whether Ramadan mode should support a masjid-announced start date (masjid publishes "Ramadan begins") in addition to manual adjustment.
