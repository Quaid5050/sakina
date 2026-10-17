# ADR-0008: JWT access tokens, rotating refresh tokens, Google/Apple sign-in

## Status
Accepted

## Date
2026-10-17

## Context
Accounts are optional, because worship needs none. They are required for Family, sync, Plus, following masjids and the console. Clients are a mobile app and a Flutter web console. The founder's direction is JWT bearer auth with refresh tokens plus Google and Apple sign-in. We also need **child sessions** on children's devices without child accounts. Requirements: short-lived credentials, revocation, theft detection, and no third-party identity broker holding our users.

## Decision
- **Custom user store** (`users`, `external_logins`, `refresh_tokens`) in our schema. We **do not adopt the full ASP.NET Core Identity stack** (its schema, UI, cookie flows and `UserManager` surface are more than we need, and they bring roles and claims tables we would not use). We do use `Microsoft.Extensions.Identity.Core`'s **`PasswordHasher<TUser>`** (PBKDF2-HMAC-SHA512, 600k iterations by setting `IterationCount`, with versioned hash format and rehash on login when parameters change).
- **Access token:** JWT, **HS256**, 15 min, issued by `JwtTokenIssuer`. It is validated with `Microsoft.AspNetCore.Authentication.JwtBearer` (issuer, audience, lifetime, signing key, 30 s clock skew). Claims: `sub`, `scope` (`user`|`child`), `fid` (child), `roles` (`staff`), `jti`, `iat`, `exp`. HS256 is chosen because the API is the only issuer and the only verifier. A key-rotation overlap is supported through `Jwt__PreviousSigningKey`.
- **Refresh token:** 32 random bytes (base64url). Only the **SHA-256 hash** is stored. **Rotated on every use.** Each login starts a token *family* (chain). Presenting a consumed token revokes the entire family and returns `REFRESH_TOKEN_REUSED` (theft detection). It has a 30-day sliding expiry and a 180-day absolute lifetime.
- **Social sign-in:** the device uses the native Google Sign-In and Sign in with Apple SDKs and sends the provider **ID token** to `POST /auth/social`. The server verifies the signature against the provider JWKS (cached, refreshed on an unknown `kid`), `iss`, `aud` (our client IDs per platform), `exp`, and for Apple a nonce (SHA-256 of the raw nonce the client sends). Users are matched on (provider, `sub`). There is **no automatic linking** to an existing password account with the same email (`409 ACCOUNT_EXISTS`), to prevent takeover by unverified emails (SPEC D-12).
- **Child sessions:** a guardian creates a 6-digit link code (hashed, single use, 10 min, attempts rate-limited). Redeeming it creates a `child_session` and a token pair with `scope=child`, `sub=<childMemberId>`, `fid=<familyId>`. An authorisation policy limits child tokens to the operations marked `x-sakina-child-allowed`.
- **Password policy:** 10–128 chars, checked against a bundled breached-password list (top 100k). No composition rules (NIST 800-63B).
- **Storage on the client:** the refresh token in Keychain/Keystore (`flutter_secure_storage`), the access token in memory. Console: access token in memory, refresh token in `sessionStorage`. That is a known trade-off, mitigated by a strict CSP and short TTLs.
- **Login throttling:** 5 failures per email per 15 min, plus the per-IP limits in ARCHITECTURE §6.4.

## Alternatives considered
- **Full ASP.NET Core Identity** (with the `/register` and `/login` endpoints of `MapIdentityApi`). Its bearer tokens are opaque data-protection tokens rather than the JWTs the founder asked for, its schema is heavier, and its refresh semantics (no reuse detection) are weaker. Rejected; we reuse only the password hasher.
- **An external IdP (Auth0, Cognito, Keycloak).** A new processor holding user identities, plus cost and extra operations. Rejected under the pledge's data-minimisation principle.
- **RS256 / ES256 with JWKS publication.** Needed only if third parties verify our tokens. Rejected for now: HS256 is simpler with a single verifier. Revisit if the console moves to a separate service.
- **Server sessions with cookies.** They don't suit a mobile-first API, and cookies on the console would add CSRF handling.

## Consequences
- We own credential security. Auth code gets the strictest review (OWASP ASVS L2 checklist), mutation-style tests (expired, wrong audience, wrong key, alg=none, reuse), and a dedicated integration suite.
- Access tokens can't be revoked before they expire (15 min max). Account deletion and "sign out of all devices" revoke refresh families immediately, and the remaining window is accepted.
- Email verification is not part of MVP. Unverified emails can't link to social accounts, and password reset proves ownership when it's needed.
