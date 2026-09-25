# API request — C14 (c14-edit-profile-a6)

Date: 2026-09-25. Ticket: C14 client — Edit Profile wiring to A6.

## Finding

`EditProfileScreen` (scaffolded C38, submit disabled) has no client for
`PUT /api/user`, `POST /api/user/email/verify`, `POST /api/user/email/resend`
(backend A6, merged). The vendored `api-docs.json` predates A6–A8.

## Backend state (verified, no change needed)

- `PUT /api/user` — name inline; new email → code to that address, login swaps only after verify.
- `POST /api/user/email/verify` + `POST /api/user/email/resend` — 6-digit, 15-min, 60-sec cooldown, 5-strike lock; machine `code` on every error.
- Backend export `storage/api-docs/api-docs.json` carries all three paths.

## Request

No backend change requested. Client syncs vendored `api-docs.json` to the
backend export and regenerates `lib/api` via project codegen
(`dart run swagger_parser` + `dart run build_runner build -d`). The
`lib/api/models/package.dart` hand slim-down (33d38bb tolerant parsers) is
restored over regen output; behavior guarded by `package_parsers_test`.
