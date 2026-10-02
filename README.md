# Inea Scents — Customer App

Flutter customer app for the Inea Scents perfume bar Booking platform: browse Package catalog, pick a Time Slot, and complete Checkout.

**Live:** https://ineascents-app.vercel.app

## Ecosystem

| Repo | Role | URL |
| --- | --- | --- |
| `ineascents-app` (this repo) | Flutter customer app — Booking flow | https://ineascents-app.vercel.app |
| `ineascents-landing` | Marketing site | https://ineascents.vercel.app |
| `ineascents-backend` | Laravel API + Admin | https://ineascents.onrender.com |

The app has no local backend. All data (Package, Availability, Booking, Payment Method) comes from the backend API.

## Prerequisites

Pinned to `pubspec.yaml`:

- Dart SDK `^3.12.2` (see `environment.sdk` in `pubspec.yaml`)
- Flutter (Material, `uses-material-design: true`) — matching the Dart SDK above
- Chrome (web) and/or a connected device/emulator (mobile)
- Key dependencies: `dio ^5.3.2`, `flutter_riverpod ^2.3.6`, `go_router ^7.0.0`, `flutter_secure_storage ^9.1.0`, `retrofit ^4.10.0`, `table_calendar ^3.0.9`, `url_launcher ^6.3.2`

## Quick Start

`API_URL` is build-time only (`String.fromEnvironment`, see `lib/config/environment.dart`). There is no runtime toggle — every run/build must pass it.

```bash
# 1. Install dependencies
flutter pub get

# 2. Regenerate models/API clients (freezed + json_serializable + retrofit)
dart run build_runner build --delete-conflicting-outputs

# 3. Run against local backend (web, pinned port — the landing
# "Book in App" link targets this port, so keep it fixed)
flutter run -d chrome --web-port=62409 --dart-define=API_URL=http://127.0.0.1:8080

# Run against local backend (Android emulator)
flutter run --dart-define=API_URL=http://10.0.2.2:8080

# Run against production backend
flutter run -d chrome --dart-define=API_URL=https://ineascents.onrender.com
```

Release builds fail fast without the flag (see `lib/src/providers/core_providers.dart`): pass `--dart-define=API_URL=...` on every `flutter run` / `flutter build`.

## Project Structure

```text
lib/
├── main.dart                  # Entry point
├── api/
│   ├── rest_client.dart       # Generated API surface: auth, availability, bookings, packages
│   ├── export.dart            # API barrel
│   ├── auth/                  # Auth endpoints
│   ├── availability/          # Availability endpoints
│   ├── bookings/              # Booking endpoints
│   ├── packages/              # Package endpoints
│   ├── user/                  # Customer endpoints
│   └── models/                # API models (freezed + json_serializable)
├── config/
│   ├── environment.dart       # Build-time env docs (do not edit to switch backends)
│   └── router.dart            # go_router navigation
├── models/
│   └── payment.dart           # Payment Method helpers (online vs cash)
├── providers/                 # Booking flow + state (Riverpod)
├── screens/                   # 13 screens + index.dart barrel (14 files)
├── src/
│   ├── app.dart               # App shell
│   ├── network/dio_client.dart       # Dio wiring (auth headers, base URL)
│   ├── providers/core_providers.dart # API_URL resolution, Dio/RestClient providers
│   ├── services/token_storage.dart   # Secure token storage
│   └── utils/
│       ├── checkout_window.dart      # Held-tab checkout abstraction
│       ├── checkout_window_web.dart  # window.open placeholder tab (web)
│       └── checkout_window_stub.dart # No-op + url_launcher fallback (mobile)
├── utils/                     # Shared client utilities
└── widgets/                   # Reusable components
```

Notes:

- The API client is `lib/api/rest_client.dart` (Retrofit-generated `RestClient` with `auth`, `availability`, `bookings`, `packages`). Dio transport wiring lives in `lib/src/network/dio_client.dart`.
- Screens (`lib/screens/`, barrel `index.dart`): splash, login, register, forgot/change password, home, packages, calendar, booking, my bookings, booking detail, profile, edit profile — 13 screens + index.

## Scripts / Tests

```bash
flutter test            # full suite (test/ — Booking flow, Pax tiers, calendar, Checkout, auth)
flutter analyze         # lints (flutter_lints)
dart run build_runner build --delete-conflicting-outputs   # regenerate freezed/retrofit code
```

## Web Production Build

```bash
flutter build web --dart-define=API_URL=https://ineascents.onrender.com
```

`vercel.json` rewrites all routes to `/index.html` (SPA fallback) so `go_router` deep links resolve on the live site.

## PayMongo / Checkout Flow

1. Customer builds a Booking: Package → Pax → Time Slot → details → Payment Method (`lib/providers/index.dart`).
2. Online Payment Method (`online`, see `lib/models/payment.dart`) → backend returns a PayMongo `checkoutUrl` and the Checkout enters `awaitingPayment`. Cash skips PayMongo and waits for admin (`awaitingAdmin`).
3. Web opens a placeholder tab synchronously in the tap handler (`openCheckoutWindow`, `lib/src/utils/checkout_window.dart`) to survive popup blockers, then navigates it to the checkout URL once the Booking POST resolves. Mobile (no tabs) falls back to `url_launcher` plus an on-screen recovery button.
4. The client polls `GET /api/bookings` every 3s (up to 15 min) until the Booking Status resolves to `confirmed`/`paid` or `cancelled`/`expired`; a bare timeout never flips the Checkout — `checkStatusImmediate` stays available so a late PayMongo success still confirms.

## Environment

| Variable | Required | Example | Notes |
| --- | --- | --- | --- |
| `API_URL` | Yes (release); debug falls back per platform | `https://ineascents.onrender.com` | Build-time only via `--dart-define`. Debug fallback: web `http://127.0.0.1:8080`, Android `http://10.0.2.2:8080`. Release without it throws. |

Do not edit `lib/config/environment.dart` to switch backends — pass the flag at build time.

## Connectivity

- Production app: https://ineascents-app.vercel.app
- Production API: https://ineascents.onrender.com (`/api` — auth, packages, availability, bookings, Customer)
- Landing site: https://ineascents.vercel.app

## Troubleshooting

- **Release crash `API_URL dart-define is required`?** Rebuild with `--dart-define=API_URL=https://ineascents.onrender.com`.
- **Can't connect to API (local)?** Backend must be running; Android emulator uses `http://10.0.2.2:8080`, not `127.0.0.1`. Web uses `http://127.0.0.1:8080`.
- **Checkout tab blocked?** The held tab only works when opened inside the tap — use the on-screen recovery button (re-navigates to `checkoutUrl`).
- **Codegen stale?** `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs` (`flutter pub run build_runner` is deprecated — use `dart run`).
- **Booking stuck pending?** Call `checkStatusImmediate` (retry) — only a resolved Status (`confirmed`/`paid`, `cancelled`/`expired`) flips the Checkout.
- **Build failing?** `rm -rf .dart_tool build/` (or delete those dirs on Windows), `flutter pub get`, retry.

## License

Proprietary — all rights reserved. (No LICENSE file by owner decision.)
