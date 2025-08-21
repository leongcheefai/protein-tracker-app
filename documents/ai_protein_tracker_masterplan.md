# AI Protein Tracker — Masterplan

## 1) App Overview & Objectives

**Working title:** Protein Pace (iOS)

**Elevator pitch:** A camera-first, AI-assisted protein intake tracker for people who exercise but under-eat protein. Snap a meal → instant protein estimate → quick chip tweaks → per‑meal targets that roll up to a daily goal.

**Primary objectives (v1):**

- Reduce friction: photo-first logging with quick adjustments.
- Educate pacing: even per‑meal targets to avoid end‑of‑day catch‑up.
- Build trust: transparent portion controls, simple stats, and privacy-first photo handling.

**Target launch markets:** Singapore & Malaysia (English-first, metric units).

---

## 2) Target Audience

Active adults in SG/MY (beginner to intermediate training) who are motivated to improve protein intake but find tracking tedious. They want fast logging, accurate enough estimates, and simple guidance.

---

## 3) Core Features (v1)

1. **Onboarding & Goal Setting**

   - Inputs: height, weight, training frequency, goal (maintain/bulk/cut optional later).
   - **Activity-tiered target** (g/kg): Light 1.6 • Moderate 1.8 • Heavy 2.0 • Very heavy/cutting 2.2 (cap). Manual override allowed.
   - Per‑meal split: **evenly divided** by selected meals (Breakfast/Lunch/Dinner, optional Snack toggle).

2. **Camera‑first Logging**

   - Launch app into camera.
   - Photo → **Google Cloud Vision** (label detection) → map top foods.
   - **Portion confirmation UI:** gram chips (100/150/200g) + custom; piece‑based chips where natural (eggs, satay, scoops). Optional S/M/L labels.
   - Quick assignment to meal; auto-advance to next meal by time of day.
   - **Privacy:** meal photos **deleted immediately after extraction**.

3. **Quick Add Fallback**

   - “Add X g protein to [meal]” (no food detail); fast, low friction.

4. **Food Data Source**

   - **USDA FoodData Central** for protein per 100g baseline; local foods bridged via user presets later.

5. **Today Dashboard (minimal)**

   - Daily ring (protein grams vs goal) + per‑meal mini‑rings.
   - Recent 3–5 logged items with edit/delete.

6. **History Tab**

   - Default **last 7 days**; user-selectable date range.
   - Stats: daily totals, % goal hit, simple streak, **average grams per meal**.

7. **Notifications**

   - Defaults (local push): Breakfast 08:00, Lunch 12:30, Snack 16:00, Dinner 19:00.
   - **Context-aware suppression** if a meal’s target already met.
   - Nightly summary at 21:30.
   - Do‑not‑disturb: 22:00–07:00.

8. **Accounts & Privacy**

   - **Full account** via Firebase Auth (email/password + SSO later).
   - Clear consent copy for photo processing and data storage; privacy policy and terms linked in onboarding and settings.

9. **Monetization**

   - **Free MVP**; later “Pro” tier (barcode scan, richer history/exports, adaptive coaching, Health integrations, enhanced vision parsing).

---

## 4) High‑Level Architecture & Stack (Conceptual)

- **Client:** Flutter (iOS first). CameraX/AVFoundation via Flutter plugins; local notifications.
- **Auth & Data:** Firebase Auth + **Firestore** (asia‑southeast1). Cloud Storage only for **temporary** photo upload.
- **Backend logic:** **Firebase Cloud Functions v2 (TypeScript)** in asia‑southeast1.
  - Endpoints: `/vision/label`, `/food/lookup`, `/log/create`, `/stats/daily`, `/stats/history`.
  - Responsibilities: verify Firebase ID token; call Google Cloud Vision; normalize foods; map to USDA; compute per‑meal & daily aggregates; enforce rate limits.
- **External Services:** Google Cloud Vision (label detection), USDA FDC.
- **Analytics & Crash:** Firebase Analytics/Crashlytics (basic funnels: onboarding complete, first log, D1/D7 retention).

**Notes:**

- Keep the backend provider‑agnostic (interface layer) to swap in richer parsing later.
- Host everything in **asia‑southeast1** for latency to SG/MY.

---

## 5) Conceptual Data Model (Firestore‑centric)

```
users/{userId}
  profile: { heightCm, weightKg, trainingFrequency, targetGPerDay, mealsEnabled: [B,L,D,S], unitSystem: "metric" }
  settings: { notificationsEnabled, reminderTimes:{B,L,S,D}, dnd:{start,end} }

users/{userId}/days/{yyyy-mm-dd}
  summary: { targetG, totalG, perMeal:{B: {goalG, totalG}, L:..., D:..., S:...}, createdAt, updatedAt, streakCount }

users/{userId}/days/{date}/meals/{mealId}
  meal: { type: "B|L|D|S", loggedAt, itemsCount, totalG }

users/{userId}/days/{date}/meals/{mealId}/items/{itemId}
  item: { source: "vision|quickAdd|manual", label, fdcId?, grams?, pieces?, proteinG, photoRef?, confidence?, createdAt }

users/{userId}/presets/{presetId}
  preset: { name, proteinG, defaultMealType, defaultSize }

system/foodMap/{hash}
  mapping: { visionLabel, normalizedFood, fdcId, proteinPer100g, lastUpdated }
```

**Indexes & access patterns**

- Composite index on `users/{uid}/days` by date descending.
- Per‑meal rollups stored on day docs to avoid N+1 reads on dashboard.

**Storage**

- `gs://.../temp/{uid}/{uuid}.jpg` uploaded → processed → **deleted immediately**.

---

## 6) UX & UI Principles

- **Camera‑first** entry; 1–2 taps to log.
- **Transparency:** show protein math (e.g., “150g chicken × 31g/100g ≈ 46g”).
- **Correction-first:** chips for grams/pieces; single‑field custom input.
- **Pacing:** per‑meal mini‑rings + subtle color coding when behind target.
- **Accessibility & Localization:** metric by default; large tap targets; color‑blind friendly palette; English copy tuned for SG/MY.
- **Delight:** micro‑animations on ring completion; lightweight confetti when daily goal met.

---

## 7) Security, Privacy & Compliance (Conceptual)

- **Auth:** Firebase Auth; Functions enforce ID token on every request.
- **Rules:** Firestore Security Rules — users can only read/write their own docs; validation on fields (e.g., proteinG 0–250 per item).
- **Photos:** stored short‑term only; purge immediately post‑processing; never used for model training.
- **Secrets:** API keys kept in Cloud Functions (not in app). Per‑user rate limits.
- **PII minimization:** store only necessary health data (protein totals, body metrics needed for target). Consider optional anonymization for analytics.
- **Legal:** Privacy Policy + Terms (cover data use, deletion, contact). Not a medical device; include disclaimer.

---

## 8) Development Phases & Milestones

**M0 – Project Setup (Week 0–1)**

- Flutter iOS project, Firebase Auth/Firestore wiring (asia‑southeast1), baseline theme.
- Cloud Functions project + CI/CD.

**M1 – Onboarding & Targets (Week 1–2)**

- Height/weight/frequency; activity‑tiered calc; per‑meal selection & split; manual override.

**M2 – Camera Flow (Week 2–4)**

- Camera launch, photo capture, upload to temp storage, Vision label call, mapping UI, portion chips, item save, auto‑delete photo.

**M3 – Today Dashboard (Week 4–5)**

- Daily/progress rings; recent items; edit/delete; per‑meal rollups.

**M4 – Quick Add (Week 5)**

- Add X g to meal; edit/delete.

**M5 – History Tab (Week 6)**

- 7‑day default, selectable range, stats (daily totals, % hit, streak, avg g/meal).

**M6 – Notifications (Week 6–7)**

- Fixed times + suppression; nightly summary; DND window.

**M7 – Polish & Beta (Week 7–8)**

- Empty states, error states, light onboarding coach marks, TestFlight build.

**M8 – Soft Launch (Week 9)**

- App Store submission for SG/MY; monitor analytics and costs.

---

## 9) Risks & Mitigations

- **Vision accuracy on mixed dishes:** rely on chips; allow multi‑item logging (e.g., chicken + rice). Keep a server‑side mapping cache to normalize common labels. Add “enhanced parse” later.
- **USDA coverage gaps for SEA foods:** support user presets; curate a starter set of local staples.
- **Portion ambiguity:** default to common sizes; hand/palm tip in tooltip; allow quick corrections.
- **Firestore cost growth:** store per‑day rollups; batch writes; avoid chatty reads; paginate history.
- **Notification fatigue:** suppression when target met; easy mute in settings.
- **App Store review sensitivities:** clear privacy copy; no health claims; opt‑in notifications.

---

## 10) Future Expansion (Pro tier candidates)

- **Barcode scanning** (Open Food Facts + commercial databases).
- **Adaptive AI targets** (nudge within safe band based on adherence/training).
- **Richer vision parsing** (LLM vision, on‑device model, or Gemini/OpenAI swap).
- **Health integrations** (Apple Health read workouts/weight, write protein).
- **Android app** and multi‑language (BM/BI/Thai/VN/Tagalog).
- **Voice/text logging** (NLP portion parsing).
- **Advanced analytics** (weekly/monthly insights, export CSV, coach tips).
- **Team/coach mode** (share summaries with PTs; privacy‑controlled).

---

## 11) Success Metrics (initial)

- Activation: % users who log ≥1 meal in first 24h.
- Retention: D1, D7, D30.
- Engagement: avg logs/day; % days hitting daily goal; edits per log (proxy for AI accuracy).
- Cost: avg Vision/API cost per active user per month.

---

## 12) Open Questions (for later)

- Data retention policy & export/delete account flows.
- Local curated food library (SEA staples) scope for v1 or v1.1.
- In‑app education: short tips on protein timing/servings.
- A/B: camera‑first vs dashboard‑first for certain cohorts.

---

**End of masterplan v1.**

