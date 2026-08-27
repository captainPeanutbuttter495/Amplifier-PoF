# Amplifier — iOS Frontend

The SwiftUI client for the Amplifier proof of concept. Five screens implementing the core product loop — sign in, browse activities, view activity detail, track points, and redeem rewards — ported from the Amplifier design project (`.dc.html` mockups) using the VIP design-system tokens.

> **PoC status:** authentication is real — sign-in goes through Auth0 Universal Login, tokens live in the Keychain, and the session survives relaunches. Everything else still runs on local demo data: there is no networking layer or persistence yet. A backend (planned in Python, details TBD) will eventually be the source of truth for scores and verification; this client is being built UI-first ahead of it.

---

## Requirements

| | |
|---|---|
| Xcode | 26+ (the project targets iOS 26 APIs) |
| Deployment target | iOS 26 |
| UI | SwiftUI, native Liquid Glass tab bar |
| Dependencies | [Auth0.swift](https://github.com/auth0/Auth0.swift) v3 via Swift Package Manager (resolves automatically) |

## Running

Open the project and run — no setup needed:

```bash
open frontend/amplifier/amplifier.xcodeproj
```

Select any iOS 26 simulator and press **⌘R**. Every SwiftUI file also has a `#Preview` for iterating on a single screen in the canvas.

### Auth0 configuration

Auth0 works out of the box — `amplifier/Auth0.plist` ships configured against the dev tenant, and its two values (`ClientId`, `Domain`) are public identifiers, not secrets. The flow uses PKCE with a custom-scheme callback, so no client secret exists anywhere in the app; issued tokens are stored only in the Keychain by the SDK's `CredentialsManager`.

To point at a different Auth0 tenant:

1. Create a **Native** application in the Auth0 Dashboard.
2. Add this to both **Allowed Callback URLs** and **Allowed Logout URLs** (substituting your tenant domain):
   ```
   com.dcabahug1.amplifier://YOUR_DOMAIN/ios/com.dcabahug1.amplifier/callback
   ```
3. Update `ClientId` and `Domain` in `Auth0.plist`.

Known dev-only shortcuts: Google login rides on Auth0's shared development keys (needs own OAuth credentials for production), "Continue with Apple" is unconfigured in the tenant (email/password and Google work), and the custom-scheme callback should become HTTPS Universal Links before production.

---

## Project structure

All source lives flat in `amplifier/amplifier/`:

| File | Purpose |
|---|---|
| `amplifierApp.swift` | `@main` entry point; injects `AuthenticationService` as an environment object |
| `ContentView.swift` | Root switch between sign-in and the tab app, driven by `auth.isAuthenticated` |
| `AuthenticationService.swift` | Auth0 Web Auth login/logout, Keychain credential storage, silent session renewal |
| `Auth0.plist` | Auth0 `ClientId` + `Domain` (public values — safe to commit) |
| `SignInView.swift` | Sign-in screen. One CTA that opens Auth0 Universal Login (Apple / Google / email live on the hosted page) |
| `RootTabView.swift` | Native iOS 26 `TabView` (Home / Rewards / Profile) with Liquid Glass and `tabBarMinimizeBehavior(.onScrollDown)` |
| `HomeView.swift` | Score header + activity feed with filtering and point sorting |
| `ActivityDetailView.swift` | Per-activity detail; banner and CTA are driven by verification status |
| `RewardsView.swift` | Rewards list with locked/unlocked state; redemption uses a native medium-detent sheet |
| `ProfileView.swift` | User card, point history, sign-out |
| `Activity.swift` | Demo data model: `Activity`, `ActivityStatus`, `ActivityFilter`, and the seeded sample activities |
| `Theme.swift` | `VIP` design tokens (colors ported from the design system's `colors.css` / `semantic.css`) plus a `Color(hex:)` helper |

## Design conventions

- **Design source:** each screen implements a specific mockup, named in the file's header comment (e.g. `"Amplifier Home.dc.html"`). When a screen and its mockup disagree, the header comment notes the deliberate deviation.
- **Native over custom:** where the design used custom chrome, the app prefers the native iOS 26 equivalent — the custom blurred tab bar became the Liquid Glass `TabView`, and the custom bottom sheet in Rewards became a native sheet with a medium detent.
- **Tokens, not hex:** all colors go through the `VIP` enum in `Theme.swift`. Don't inline hex values in views; add a token if one is missing.
- **Verification states:** `ActivityStatus` mirrors the backend state machine (`Not Started → Submitted → Pending Verification → Verified / Rejected`) and maps statuses into the three feed filters (To Do / In Review / Done).

## What's next

Planned work to connect this UI to the real system once the backend (Python, TBD) exists:

- Register the backend as an API in Auth0 and add `.audience(...)` to the login call, so access tokens are JWTs the backend can verify
- An `APIClient` (`URLSession` + `async/await`) replacing the demo data in `Activity.swift`, sending `AuthenticationService.accessToken()` as a Bearer header
- Evidence submission from `ActivityDetailView` posting to the API
- Server-driven scores, tiers, and reward eligibility — the client never computes points; it only displays what the API returns
