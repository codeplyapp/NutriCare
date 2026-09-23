# AGENTS.md

## What this repo is

Design/spec-only repo for **NutriCare**, a nutrition-health app (Flutter client + modular-monolith backend). There is **no source code yet** — everything lives under `docs/`. Do not run builds/tests; implementing means scaffolding from scratch per the specs. Not a git repo (no `.git`).

## Source of truth (docs, in priority order)

- `docs/TSD.md` — technical spec: stack, Flutter `lib/` folder structure, REST endpoints, DB schema. Follow its prescribed Clean Architecture layout (`core/`, `data/`, `domain/`, `presentation/`, `routing/`) verbatim when scaffolding.
- `docs/PRD.md` — scope & roadmap. Features are phase-gated (MVP → Fase 2 → Fase 3); don't build Fase 3 features into an MVP deliverable.
- `docs/ARCHITECTURE.md` + `docs/USER_FLOW.md` — service boundaries and flows (Mermaid diagrams).
- `docs/LIB_THEME.md` — maps DESIGN.md tokens + brand palette onto Flutter theme (`ColorScheme`/`TextTheme`/spacing/radius/components). Authoritative when scaffolding `lib/core/theme/`.
- `docs/ADAPTASI_SIGAP.md` — UI/UX pattern maps from the SIGAP prototype (shared DESIGN.md) onto NutriCare features + phase gates. Consult before borrowing any SIGAP-looking pattern in specs.

Docs cross-reference each other; keep them in sync when scope changes.

## Locked-in stack (TSD.md)

- Frontend: Flutter 3.x, **Riverpod** (state), **go_router** (routing + route guard forcing gizi-profile onboarding).
- Backend: **undecided** — FastAPI (Python) or NestJS (TS); modular monolith with modules User, Nutrition, AI Gateway, Consultation, IoT Gateway, Content, Notification. Confirm before assuming.
- Data: PostgreSQL + Redis (state only there; backend is stateless). Firebase Auth/FCM, Gemini AI, MQTT for IoT.
- Client never calls third-party APIs (Gemini, Agora, MQTT) directly — always via the backend; no third-party keys in the client.
- IoT uses a `DeviceAdapter` interface so new watch brands don't touch core nutrition-eval logic.

## Docs language

All docs are written in **Indonesian**. Write new specs/content in Indonesian to match.

## UI conventions (`docs/DESIGN.md`)

DESIGN.md is a design-token spec (Apple-inspired), not loose prose. Build UI against its token names — `{colors.primary}`, `{typography.body}`, `{rounded.pill}`, `{spacing.lg}`, `{component.button-primary}` — never inline hex. For the concrete Flutter implementation mapping, use `docs/LIB_THEME.md`.

- Single accent Action Blue `#0066cc`; no second brand color, no decorative gradients.
- Weight ladder 300/400/600/700 only — 500 is deliberately absent; body copy at 17px (not 16px).
- Exactly one drop-shadow (`rgba(0,0,0,0.22) 3px 5px 30px`), reserved for product imagery — never cards/buttons/text.
- Button active state = `transform: scale(0.95)`.
- Off-Apple platforms: substitute Inter (`ss03`, tighter letter-spacing, line-height 1.44 for body).

## App brand palette

The app's actual brand colors are these four scales (Tailwind-style 50–950). They override DESIGN.md's single-accent "Action Blue `#0066cc`" statement for brand theming; DESIGN.md's token-referencing and typography/shape conventions still apply.

- **frozen-water** (mint): `#e5fff9` 50 · `#ccfff4` 100 · `#99ffe9` 200 · `#66ffde` 300 · `#33ffd3` 400 · `#00ffc8` 500 · `#00cca0` 600 · `#009978` 700 · `#006650` 800 · `#003328` 900 · `#00241c` 950
- **dark-amethyst** (purple): `#eeebfa` 50 · `#ddd7f4` 100 · `#bcafe9` 200 · `#9a87de` 300 · `#785fd3` 400 · `#5637c8` 500 · `#452ca0` 600 · `#342178` 700 · `#231650` 800 · `#110b28` 900 · `#0c081c` 950
- **turquoise**: `#ebf9f8` 50 · `#d7f4f0` 100 · `#b0e8e2` 200 · `#88ddd3` 300 · `#61d1c4` 400 · `#39c6b5` 500 · `#2e9e91` 600 · `#22776d` 700 · `#174f49` 800 · `#0b2824` 900 · `#081c19` 950
- **rich-cerulean** (blue): `#eaf4fb` 50 · `#d5e9f6` 100 · `#aad3ee` 200 · `#80bde5` 300 · `#56a6dc` 400 · `#2b90d4` 500 · `#2373a9` 600 · `#1a577f` 700 · `#113a55` 800 · `#091d2a` 900 · `#06141e` 950

## Non-obvious app rules (PRD/TSD)

- Floating bottom dock frosted 4 tab (Beranda, Nutri Mate, Nutri Meal, Nutri Doc) hanya tampil di area utama pasca-onboarding; Profil, Nutri Calculator, dan Nutri Education diakses dari dalam Beranda tanpa tab terpisah di dock. Halaman detail di-push ke root navigator menutupi dock. Tombol back kiri atas hanya muncul pada halaman non-root (`canPop`).
- Subtle Apple-like motion: durasi UI ≤300ms (mikro-interaksi tombol 150ms, data sweep 700ms), GPU-only (transform & opacity), wajib patuhi reduce-motion (0ms/instant).
- Every Nutri Mate (Gemini) response carries an educational disclaimer; if a serious/risky condition is detected, escalate to Nutri Doc with a booking CTA.
- AI Gateway builds the prompt (system + user gizi context + short history), rate-limits per user, caches FAQs.
- Health data must comply with Indonesian UU PDP: explicit consent at registration, delete rights, encryption at-rest, audit log for medical/consultation access.