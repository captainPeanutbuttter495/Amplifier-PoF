# Amplifier

A points-based social amplification platform for the National Challenge. Users earn an **Amplifier Score** by completing verified amplification activities — sharing content, referring participants, attending events — which unlocks rewards and advances them through tiers.

This repository is a **three-week proof of concept**. It is not production software and is not submitted to the App Store. Its purpose is to demonstrate the core product loop end-to-end and surface the engineering and institutional roadblocks that a production build would need to solve.

**Authors:** Matthew Garcia, Duane Cabahug
**Status:** PoC — local development only

---

## Table of Contents

- [What this demonstrates](#what-this-demonstrates)
- [Repository structure](#repository-structure)
- [Tech stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the app](#running-the-app)
- [API reference](#api-reference)
- [Data model](#data-model)
- [Environment variables](#environment-variables)
- [Scripts](#scripts)
- [Architecture](#architecture)
- [Known limitations](#known-limitations)
- [Documentation](#documentation)

---

## What this demonstrates

The PoC covers five screens and the complete core loop:

```
Sign In → Home (score + activity feed) → Activity Detail (submit evidence)
        → points awarded server-side → Profile (history) → Rewards (unlock)
```

| Screen | What it proves |
|---|---|
| Sign In | Auth0 integration works in SwiftUI; user records are created on first login |
| Home | Score and tier render from the API; activity feed is server-driven, not hardcoded |
| Activity Detail | Evidence submission flows to the backend and returns a verification status |
| Profile | Point history is auditable and attributable to specific activities |
| Rewards | Threshold-based unlocking works; duplicate redemption is prevented server-side |

**The central design constraint:** the backend is the authoritative source of all point calculations. The iOS client never computes, stores, or submits a point total — it only displays what the API returns. This is the foundation of the fraud-prevention story.

---

## Repository structure

```
amplifier/
├── frontend/                  # SwiftUI iOS app (Xcode project)
│   ├── Amplifier/
│   │   ├── App/               # App entry point, root navigation
│   │   ├── Features/          # One folder per screen
│   │   │   ├── SignIn/
│   │   │   ├── Home/
│   │   │   ├── ActivityDetail/
│   │   │   ├── Profile/
│   │   │   └── Rewards/
│   │   ├── Models/            # Codable structs matching API responses
│   │   ├── Services/          # APIClient, AuthService, Keychain wrapper
│   │   └── Shared/            # Reusable views, modifiers, design tokens
│   └── Amplifier.xcodeproj
│
├── backend/                   # Express + Prisma REST API
│   ├── src/
│   │   ├── routes/            # One file per resource
│   │   ├── middleware/        # JWT validation, error handling
│   │   ├── services/          # Business logic (scoring, verification, redemption)
│   │   └── lib/               # Prisma client, helpers
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── seed.js            # Seeds activities, rewards, tiers
│   ├── tests/
│   └── docker-compose.yml     # PostgreSQL 16
│
└── docs/
    ├── SRS.docx               # Software Requirements Specification
    ├── c4-context.png         # C4 Level 1 — System Context
    ├── c4-container.png       # C4 Level 2 — Containers
    └── c4-component-api.png   # C4 Level 3 — API components
```

---

## Tech stack

**Frontend**

| | |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Minimum target | iOS 16 |
| Auth | Auth0 iOS SDK (Universal Login) |
| Token storage | iOS Keychain |
| Networking | `URLSession` with `async/await` |

**Backend**

| | |
|---|---|
| Runtime | Node.js 20 LTS |
| Framework | Express |
| ORM | Prisma |
| Database | PostgreSQL 16 (Docker) |
| Auth | Auth0 JWT validation (`express-oauth2-jwt-bearer`) |
| Testing | Vitest + Supertest |

**Why these choices**

- **SwiftUI over React Native for the PoC** — native iOS is the target platform, and SwiftUI is the fastest path to a demo-quality UI. Because all business logic lives behind a REST API, a React Native client can be added later with no backend changes.
- **Express over serverless for now** — deployment is deferred, so there's no benefit to Lambda's cold-start and packaging complexity during local development. The route handlers are written to be portable if the project moves to serverless later.
- **PostgreSQL over DynamoDB** — the data model is relational (users have many submissions, activities have many submissions, rewards have redemptions). Prisma gives type-safe queries and versioned migrations. This also matches the stack used across other projects, which reduces context-switching.

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Xcode | 15+ | Required for the SwiftUI app |
| Node.js | 20 LTS | `node --version` to confirm |
| Docker Desktop | latest | Runs the PostgreSQL container |
| An Auth0 tenant | — | Free tier is sufficient |

---

## Setup

### 1. Clone and install backend dependencies

```bash
git clone <repo-url> amplifier
cd amplifier/backend
npm install
```

### 2. Start PostgreSQL

```bash
docker compose up -d
```

This starts PostgreSQL 16 on port `5432`. Confirm it's healthy:

```bash
docker compose ps
```

### 3. Configure environment

```bash
cp .env.example .env
```

Fill in the Auth0 values from your tenant dashboard (see [Environment variables](#environment-variables)).

### 4. Run migrations and seed

```bash
npx prisma migrate dev
npm run seed
```

The seed script creates:
- 4 amplification activities with varying point values
- 3 rewards at different point thresholds
- 4 tiers (Amplifier, Connector, Advocate, Champion)

### 5. Configure the iOS app

Open `frontend/Amplifier.xcodeproj` in Xcode. In `Amplifier/Services/Config.swift`, set:

```swift
static let apiBaseURL = "http://localhost:3000"
static let auth0Domain = "your-tenant.us.auth0.com"
static let auth0ClientId = "your-client-id"
```

> **Note on the iOS Simulator and localhost:** the Simulator shares the host's network, so `http://localhost:3000` resolves correctly. If you run on a **physical device**, replace `localhost` with your Mac's LAN IP (e.g. `http://192.168.1.42:3000`) and make sure both are on the same network.

> **App Transport Security:** iOS blocks plain HTTP by default. For local development, `NSAllowsLocalNetworking` is already set in `Info.plist`. This must be removed before any production build.

---

## Running the app

**Terminal — backend:**

```bash
cd backend
npm run dev          # starts Express on :3000 with hot reload
```

**Xcode — frontend:**

Select an iOS 16+ simulator and press ⌘R.

**Verify the backend is reachable:**

```bash
curl http://localhost:3000/health
# {"status":"ok"}
```

---

## API reference

All endpoints except `/health` require a valid Auth0 JWT in the `Authorization: Bearer <token>` header. Requests without one receive `401`.

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Liveness check. No auth. |
| `GET` | `/api/profile` | Authenticated user's name, avatar, score, tier, lifetime points |
| `GET` | `/api/activities` | All available activities with per-user completion status |
| `GET` | `/api/activities/:id` | Full detail for one activity |
| `POST` | `/api/submissions` | Submit evidence for an activity |
| `GET` | `/api/rewards` | Rewards with locked/unlocked state for this user |
| `POST` | `/api/rewards/redeem` | Redeem a reward; validates eligibility, prevents duplicates |
| `GET` | `/api/history` | Paginated point history and redemptions |

### `POST /api/submissions`

**Request**

```json
{
  "activityId": 3,
  "verificationType": "TRACKED_LINK",
  "evidence": { "shareUrl": "https://amp.hub/r/a8f3c1" }
}
```

**Response `201`**

```json
{
  "success": true,
  "submissionId": 42,
  "status": "PENDING_VERIFICATION",
  "pointsAwarded": 0
}
```

Points are `0` until verification completes. When an admin approves (or automatic verification fires), the submission moves to `VERIFIED` and points are credited.

**Response `400`** — invalid activity, missing evidence, or a duplicate submission for a non-repeatable activity.

### Verification states

```
NOT_STARTED → SUBMITTED → PENDING_VERIFICATION → VERIFIED
                                               ↘ REJECTED → (resubmit)
```

Points are awarded **only** on transition to `VERIFIED`.

---

## Data model

```prisma
model User {
  id            Int          @id @default(autoincrement())
  auth0Id       String       @unique
  name          String
  avatarUrl     String?
  score         Int          @default(0)
  lifetimePoints Int         @default(0)
  tierId        Int
  createdAt     DateTime     @default(now())

  tier          Tier         @relation(fields: [tierId], references: [id])
  submissions   Submission[]
  redemptions   Redemption[]
}

model Activity {
  id                Int          @id @default(autoincrement())
  title             String
  description       String
  instructions      String
  points            Int
  verificationType  String       // TRACKED_LINK | SCREENSHOT | QR_CODE | ADMIN | AUTO
  repeatable        Boolean      @default(false)
  active            Boolean      @default(true)
  createdAt         DateTime     @default(now())

  submissions       Submission[]
}

model Submission {
  id            Int       @id @default(autoincrement())
  userId        Int
  activityId    Int
  status        String    @default("SUBMITTED")
  evidence      Json?
  pointsAwarded Int       @default(0)
  reviewedAt    DateTime?
  rejectReason  String?
  createdAt     DateTime  @default(now())

  user          User      @relation(fields: [userId], references: [id])
  activity      Activity  @relation(fields: [activityId], references: [id])

  @@index([userId])
  @@index([activityId])
}

model Reward {
  id              Int          @id @default(autoincrement())
  title           String
  description     String
  requiredPoints  Int
  inventory       Int?         // null = unlimited
  repeatable      Boolean      @default(false)

  redemptions     Redemption[]
}

model Redemption {
  id          Int      @id @default(autoincrement())
  userId      Int
  rewardId    Int
  createdAt   DateTime @default(now())

  user        User     @relation(fields: [userId], references: [id])
  reward      Reward   @relation(fields: [rewardId], references: [id])

  @@unique([userId, rewardId])   // enforces one redemption per reward per user
}

model Tier {
  id          Int    @id @default(autoincrement())
  name        String @unique
  threshold   Int    // minimum score to reach this tier

  users       User[]
}
```

**Design notes**

- `Tier.threshold` lives in the database, not in the iOS binary. Changing tier requirements does not require an app update — a hard requirement from the spec.
- `Activity.verificationType` is a string rather than an enum so new verification methods can be added without a migration.
- `Submission.evidence` is `Json` so different verification types can store different shapes (a URL, an S3 key, a scanned code) in one column.
- `@@unique([userId, rewardId])` on `Redemption` enforces the no-duplicate-redemption rule at the database level, not just in application code.
- `User.score` and `User.lifetimePoints` are separate: score is spendable and decreases on redemption, lifetime points only ever increase and drive tier progression.

---

## Environment variables

`backend/.env`

```bash
DATABASE_URL="postgresql://amplifier:amplifier@localhost:5432/amplifier?schema=public"

AUTH0_DOMAIN="your-tenant.us.auth0.com"
AUTH0_AUDIENCE="https://api.amplifier.local"

PORT=3000
NODE_ENV=development
```

`.env` is gitignored. `.env.example` is committed with placeholder values.

---

## Scripts

Run from `backend/`.

| Command | Description |
|---|---|
| `npm run dev` | Start Express with hot reload |
| `npm start` | Start Express without reload |
| `npm run seed` | Reset and reseed activities, rewards, tiers |
| `npm test` | Run the Vitest suite |
| `npm run test:watch` | Vitest in watch mode |
| `npx prisma studio` | Browse the database in a GUI |
| `npx prisma migrate dev` | Create and apply a migration |
| `docker compose up -d` | Start PostgreSQL |
| `docker compose down` | Stop PostgreSQL (data persists in a volume) |
| `docker compose down -v` | Stop and **delete all data** |

---

## Architecture

Architecture is documented using the [C4 model](https://c4model.com/) — a set of nested diagrams that zoom in progressively, from "who uses this system" down to "what's inside this one container." Each level answers a different question, so read whichever one matches what you're trying to understand.

### Level 1 — System Context

**Question it answers:** who uses Amplifier, and what does it depend on?

![C4 Level 1 — System Context](docs/c4-context.png)

Two kinds of people interact with the system. **Amplifiers** are the end users — students, staff, and community members who complete activities and redeem rewards through the iOS app. **Hub administrators** configure activities and review submitted evidence; in the PoC they do this directly against the database rather than through an admin UI.

Three external systems matter. **Auth0** is the identity provider — Amplifier does not store passwords. **Social platforms** receive shared content via the native iOS Share Sheet, and critically, the system gets no callback from them confirming a post happened. That gap is the entire reason verification is a hard problem. The **National Challenge site** is where tracked share links resolve, which is how referral traffic gets attributed back to a specific Amplifier.

### Level 2 — Containers

**Question it answers:** what are the separately-deployable pieces, and how do they talk?

![C4 Level 2 — Containers](docs/c4-container.png)

Three containers. The **iOS app** renders five screens and holds no business logic — it displays whatever the API returns. The **REST API** owns every rule that matters: JWT validation, scoring, the verification state machine, and redemption limits. The **database** stores everything.

The important property of this shape is that the iOS app is a thin client. Points are never calculated on the device, which means a modified or reverse-engineered client cannot inflate a score. It also means a React Native or Android client can be added later against the same API with zero backend changes.

Note the iOS app talks to Auth0 and the social platforms directly, not through the API. Auth0 issues the JWT to the device; the Share Sheet is an OS-level feature the API never sees. The API's only external relationship is generating the tracked links that point at the National Challenge site.

This diagram shows the **local development** topology. Deployment to AWS is deferred — see [Known limitations](#known-limitations).

### Level 3 — Components (REST API)

**Question it answers:** what's inside the API, and where does each rule live?

![C4 Level 3 — REST API components](docs/c4-component-api.png)

Requests enter through **auth middleware**, which validates the Auth0 JWT against Auth0's JWKS endpoint before anything else runs. Unauthenticated requests are rejected with `401` and never reach a route handler.

**Route handlers** parse and validate input, then delegate to one of three services. Keeping business logic out of the route handlers is what makes it testable in isolation and portable if the project later moves to serverless.

- **Scoring Service** — awards points when a submission reaches `VERIFIED`, then recomputes the user's tier from their lifetime points.
- **Verification Service** — owns the state machine (`SUBMITTED → PENDING_VERIFICATION → VERIFIED / REJECTED`). All verification types funnel through here, which is why adding a new one doesn't touch the route layer.
- **Redemption Service** — checks point eligibility and relies on the `@@unique([userId, rewardId])` constraint to make duplicate redemption impossible at the database level rather than only in application code.

All three go through a single **Prisma client**. One data-access path means schema changes surface as type errors at compile time rather than runtime failures in production.

Level 3 is only drawn for the API container. That's intentional — C4 says to drill into the containers whose internals aren't obvious. The iOS app's structure is already described by the five-screen breakdown above.

---

## Known limitations

This is a proof of concept. The following are deliberate omissions, not oversights.

| Limitation | Why | Production path |
|---|---|---|
| Local only, no deployment | Deployment deferred by scope | AWS — Lambda + API Gateway or ECS, RDS for Postgres |
| No admin dashboard | Out of PoC scope | Seed data is edited via Prisma Studio for now |
| Verification method not finalized | Open question in the SRS | Tracked links recommended — no App Review risk, no social platform API dependency |
| No CSUN / university SSO | FERPA and cross-institution complexity | Requires legal and IT review before it can be scoped |
| No push notifications | Stretch goal | `UNUserNotificationCenter` with explicit opt-in |
| No leaderboards | Optional in the spec | Needs privacy controls before it can ship |
| Plain HTTP in local dev | Simulator convenience | HTTPS only; remove `NSAllowsLocalNetworking` before any real build |
| Admin approval is manual DB edits | No admin UI yet | Admin review queue with approve/reject actions |

---

## Documentation

| File | Contents |
|---|---|
| `docs/SRS.docx` | Full requirements specification — five-screen scope, API contract, App Store Review risk analysis, and the open questions blocking Week 2 |
| `docs/c4-context.png` | C4 Level 1 — rendered inline under [Architecture](#architecture) |
| `docs/c4-container.png` | C4 Level 2 — rendered inline under [Architecture](#architecture) |
| `docs/c4-component-api.png` | C4 Level 3 — rendered inline under [Architecture](#architecture) |

The SRS is the source of truth for scope. If this README and the SRS disagree, the SRS wins — open an issue so the drift gets fixed.

---

## License

Internal project. Not licensed for external use.
