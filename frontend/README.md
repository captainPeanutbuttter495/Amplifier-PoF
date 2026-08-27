# Amplifier — iOS Frontend

The SwiftUI client for the Amplifier proof of concept. Five screens implementing the core product loop — sign in, browse activities, view activity detail, track points, and redeem rewards — ported from the Amplifier design project (`.dc.html` mockups) using the VIP design-system tokens.

> **PoC status:** this app currently runs entirely on local demo data. There is no networking layer, no Auth0 integration, and no persistence yet — every sign-in button continues straight into the app. A backend (planned in Python, details TBD) will eventually be the source of truth for scores and verification; this client is being built UI-first ahead of it.

---

## Requirements

| | |
|---|---|
| Xcode | 26+ (the project targets iOS 26 APIs) |
| Deployment target | iOS 26 |
| UI | SwiftUI, native Liquid Glass tab bar |
| Dependencies | None — no packages, no CocoaPods |

## Running

Open the project and run — no setup needed:

```bash
open frontend/amplifier/amplifier.xcodeproj
```

Select any iOS 26 simulator and press **⌘R**. Every SwiftUI file also has a `#Preview` for iterating on a single screen in the canvas.

---

## Project structure

All source lives flat in `amplifier/amplifier/`:

| File | Purpose |
|---|---|
| `amplifierApp.swift` | `@main` entry point |
| `ContentView.swift` | Root switch between sign-in and the tab app (`isSignedIn` state) |
| `SignInView.swift` | Sign-in screen. Auth buttons are stubs — any option calls `onContinue` |
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

- Auth0 Universal Login replacing the stubbed sign-in, with Keychain token storage
- An `APIClient` (`URLSession` + `async/await`) replacing the demo data in `Activity.swift`
- Evidence submission from `ActivityDetailView` posting to the API
- Server-driven scores, tiers, and reward eligibility — the client never computes points; it only displays what the API returns
