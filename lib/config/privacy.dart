/// C159: single source for the bundled privacy policy identity.
///
/// Must match backend `LegalController::VERSION` — the server pins consent
/// to that exact version, so bump this together with the backend and the
/// landing page (`PRIVACY_VERSION`) on every policy change.
const privacyPolicyVersion = '2026-10-01';

/// Privacy contact printed in-app (owner decision 2026-10-01: gmail).
const privacyContactEmail = 'ineascents.app@gmail.com';
