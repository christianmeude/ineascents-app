import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inea_scents_client/api/rest_client.dart';

/// In-memory fake backend used by widget tests to avoid real network I/O.
class FakeApiBackend {
  /// Status the POST /api/bookings handler returns for the created booking.
  String bookingStatusAfterCreate = 'pending';

  /// Status returned when the poller hits GET /api/bookings.
  String nextBookingStatus = 'confirmed';

  /// Number of times GET /api/bookings must be polled before returning
  /// [nextBookingStatus]. Lets tests observe the "processing" screen while
  /// the poll is still running.
  int pollAttemptsToResolve = 0;

  /// Number of GET /api/bookings calls made so far.
  int bookingsEndpointCallCount = 0;

  /// Number of POST /api/bookings calls made so far.
  int createBookingCallCount = 0;

  /// When non-null, the created booking carries this checkout URL.
  String? checkoutUrl = 'https://example.com/checkout/IN-2026-000123';

  /// When true, POST /api/bookings answers with an HTTP 500.
  bool failCreateBooking = false;

  /// When true, GET /api/bookings answers with an HTTP 500.
  bool failBookings = false;

  /// When non-null, GET /api/bookings returns exactly these rows instead
  /// of the single canned booking. Lets tests stage upcoming/past/empty.
  List<Map<String, Object?>>? bookingsOverride;

  /// A single date for the given month/year marked as booked, or null.
  DateTime? bookedDate;

  /// Profile state for PUT /api/user + verify/resend (C14).
  String profileName = 'Maria Clara';
  String profileEmail = 'maria@example.com';
  String? pendingEmail;

  /// Code the fake verify endpoint accepts.
  String acceptedCode = '482916';

  /// When non-null, PUT /api/user answers with this machine code.
  String? failProfileWith;

  /// When non-null, POST /api/user/email/verify answers with this code.
  String? failVerifyWith;

  /// When true, POST /api/user/email/resend answers 429.
  bool failResendCooldown = false;

  /// Password-change state for POST /api/user/password/* (C15).
  /// Current password the fake change endpoint accepts.
  String expectedCurrentPassword = 'current-pass-1';

  /// When non-null, POST /api/user/password/change answers with this code.
  String? failPasswordChangeWith;

  /// When true, POST /api/user/password/request answers 429.
  bool failPasswordRequestCooldown = false;

  int putUserCallCount = 0;
  int verifyCallCount = 0;
  int resendCallCount = 0;
  int passwordRequestCallCount = 0;
  int passwordChangeCallCount = 0;

  /// Forgot/reset state for POST /api/forgot-password + /api/reset-password
  /// (C93). The fake accepts any email (backend never reveals existence)
  /// and tracks whether a code was requested.
  bool resetCodeRequested = false;

  /// When non-null, POST /api/reset-password answers with this code.
  String? failResetPasswordWith;

  int forgotPasswordCallCount = 0;
  int resetPasswordCallCount = 0;

  /// Registration state for POST /api/register + /register/verify +
  /// /register/resend + /api/login (C95/A11). Register creates a pending
  /// user with zero token; verify marks the address verified; login is
  /// gated with EMAIL_NOT_VERIFIED until then.
  String? registeredEmail;
  String registeredName = 'Maria Clara';
  bool registerCodeRequested = false;
  final Set<String> verifiedEmails = {};

  /// When non-null, POST /api/register answers with this machine code.
  String? failRegisterWith;

  /// When non-null, POST /api/register/verify answers with this code.
  String? failRegisterVerifyWith;

  /// When true, POST /api/register/resend answers 429.
  bool failRegisterResendCooldown = false;

  /// When true, POST /api/logout answers 500 (C159: offline-proof logout).
  bool failLogout = false;

  int registerCallCount = 0;
  int registerVerifyCallCount = 0;
  int registerResendCallCount = 0;
  int loginCallCount = 0;
  int logoutCallCount = 0;

  int get _id => 999;
  String get _reference => 'IN-2026-000123';

  Map<String, Object?> bookingJson({required String status}) => {
    'id': _id,
    'booking_reference': _reference,
    'user_id': 1,
    'customer_name': 'Maria Clara',
    'customer_email': 'maria@example.com',
    'customer_phone': '+639171234567',
    'pax': 50,
    'event_date': '2026-09-01T02:00:00.000Z',
    'event_time': '14:00:00',
    'venue_address': 'The Peninsula Manila',
    'payment_method': 'online',
    'status': status,
    if (checkoutUrl != null) 'checkout_url': checkoutUrl,
  };
}

/// A [Dio] [HttpClientAdapter] that replays canned responses for the two
/// booking endpoints plus availability. All other routes answer 404.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.backend);

  final FakeApiBackend backend;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final method = options.method.toUpperCase();

    if (path == '/api/availability') {
      final month = options.queryParameters['month'];
      final year = options.queryParameters['year'];
      final booked = backend.bookedDate;
      if (booked != null &&
          month != null &&
          year != null &&
          '${booked.year}' == year.toString() &&
          ('${booked.month}' == month.toString() ||
              '${booked.month}'.padLeft(2, '0') == month.toString())) {
        final day = booked.day.toString().padLeft(2, '0');
        final m = booked.month.toString().padLeft(2, '0');
        return _json(
          '[{"date": "${booked.year}-$m-$day", "status": "Booked"}]',
        );
      }
      return _json('[]');
    }

    if (method == 'GET' && path == '/api/user') {
      return _json(jsonEncode(_profileJson()));
    }

    if (method == 'POST' && path == '/api/logout') {
      backend.logoutCallCount++;
      if (backend.failLogout) {
        return _status(500, '{"detail":"logout unavailable"}');
      }
      return _json('{"message":"Logged out."}');
    }

    if (method == 'POST' && path == '/api/bookings') {
      backend.createBookingCallCount++;
      if (backend.failCreateBooking) {
        return _status(500, '{"detail":"payment provider unavailable"}');
      }
      return _json(
        jsonEncode({
          'data': backend.bookingJson(status: backend.bookingStatusAfterCreate),
        }),
      );
    }

    if (method == 'GET' && path == '/api/bookings') {      backend.bookingsEndpointCallCount++;
      if (backend.failBookings) {
        return _status(500, '{"detail":"bookings unavailable"}');
      }
      final override = backend.bookingsOverride;
      if (override != null) {
        return _json(jsonEncode({'data': override}));
      }
      final resolved =
          backend.bookingsEndpointCallCount > backend.pollAttemptsToResolve;
      return _json(
        jsonEncode({
          'data': [
            backend.bookingJson(
              status: resolved ? backend.nextBookingStatus : 'pending',
            ),
          ],
        }),
      );
    }

    if (method == 'PUT' && path == '/api/user') {
      backend.putUserCallCount++;
      final body = _bodyMap(options);
      if (backend.failProfileWith != null) {
        return _status(
          422,
          jsonEncode({
            'message': 'That email is already in use.',
            'code': backend.failProfileWith,
          }),
        );
      }
      if (body['name'] is String && (body['name'] as String).isNotEmpty) {
        backend.profileName = body['name'] as String;
      }
      final email = body['email']?.toString() ?? '';
      if (email.isNotEmpty && email != backend.profileEmail) {
        backend.pendingEmail = email;
        return _json(
          jsonEncode({
            'data': _profileJson(),
            'email_pending': email,
            'code_expires_at': '2026-09-25T10:00:00.000Z',
          }),
        );
      }
      return _json(jsonEncode({'data': _profileJson()}));
    }

    if (method == 'POST' && path == '/api/user/email/verify') {
      backend.verifyCallCount++;
      final body = _bodyMap(options);
      if (backend.failVerifyWith != null) {
        return _status(
          422,
          jsonEncode({
            'message': "That code doesn't match.",
            'code': backend.failVerifyWith,
            'attempts_left': 4,
          }),
        );
      }
      if (body['code']?.toString() == backend.acceptedCode &&
          backend.pendingEmail != null) {
        backend.profileEmail = backend.pendingEmail!;
        backend.pendingEmail = null;
        return _json(jsonEncode({'data': _profileJson()}));
      }
      return _status(
        422,
        jsonEncode({
          'message': "That code doesn't match.",
          'code': 'EMAIL_CODE_MISMATCH',
          'attempts_left': 4,
        }),
      );
    }

    if (method == 'POST' && path == '/api/user/email/resend') {
      backend.resendCallCount++;
      if (backend.failResendCooldown) {
        return _status(
          429,
          jsonEncode({
            'message': 'Please wait a minute.',
            'code': 'EMAIL_CODE_RESEND_TOO_SOON',
          }),
        );
      }
      return _json(
        jsonEncode({
          'message': 'Code re-sent.',
          'code_expires_at': '2026-09-25T10:00:00.000Z',
        }),
      );
    }

    if (method == 'POST' && path == '/api/user/password/request') {
      backend.passwordRequestCallCount++;
      if (backend.failPasswordRequestCooldown) {
        return _status(
          429,
          jsonEncode({
            'message': 'Please wait a minute.',
            'code': 'EMAIL_CODE_RESEND_TOO_SOON',
          }),
        );
      }
      return _json(
        jsonEncode({
          'message': 'Code sent.',
          'code_expires_at': '2026-09-25T10:00:00.000Z',
        }),
      );
    }

    if (method == 'POST' && path == '/api/user/password/change') {
      backend.passwordChangeCallCount++;
      final body = _bodyMap(options);
      if (backend.failPasswordChangeWith != null) {
        return _status(
          422,
          jsonEncode({
            'message': 'Password change failed.',
            'code': backend.failPasswordChangeWith,
            if (backend.failPasswordChangeWith == 'EMAIL_CODE_MISMATCH')
              'attempts_left': 4,
          }),
        );
      }
      if (body['current_password']?.toString() !=
          backend.expectedCurrentPassword) {
        return _status(
          422,
          jsonEncode({
            'message': 'Current password is incorrect.',
            'code': 'CURRENT_PASSWORD_WRONG',
          }),
        );
      }
      if (body['code']?.toString() == backend.acceptedCode) {
        return _json(
          jsonEncode({
            'message': 'Password changed.',
            'code': 'PASSWORD_CHANGED',
          }),
        );
      }
      return _status(
        422,
        jsonEncode({
          'message': "That code doesn't match.",
          'code': 'EMAIL_CODE_MISMATCH',
          'attempts_left': 4,
        }),
      );
    }

    if (method == 'POST' && path == '/api/forgot-password') {
      backend.forgotPasswordCallCount++;
      backend.resetCodeRequested = true;
      return _json(
        jsonEncode({
          'message': 'If that email exists, a code was sent.',
          'code': 'PASSWORD_RESET_SENT',
        }),
      );
    }

    if (method == 'POST' && path == '/api/reset-password') {
      backend.resetPasswordCallCount++;
      final body = _bodyMap(options);
      if (backend.failResetPasswordWith != null) {
        return _status(
          backend.failResetPasswordWith == 'PASSWORD_RESET_NONE' ? 404 : 422,
          jsonEncode({
            'message': 'Password reset failed.',
            'code': backend.failResetPasswordWith,
            if (backend.failResetPasswordWith == 'EMAIL_CODE_MISMATCH')
              'attempts_left': 4,
          }),
        );
      }
      if (!backend.resetCodeRequested) {
        return _status(
          404,
          jsonEncode({
            'message': 'No pending code. Request a new one first.',
            'code': 'PASSWORD_RESET_NONE',
          }),
        );
      }
      if (body['code']?.toString() == backend.acceptedCode) {
        backend.resetCodeRequested = false;
        return _json(
          jsonEncode({
            'message': 'Password reset.',
            'code': 'PASSWORD_RESET_DONE',
          }),
        );
      }
      return _status(
        422,
        jsonEncode({
          'message': "That code doesn't match.",
          'code': 'EMAIL_CODE_MISMATCH',
          'attempts_left': 4,
        }),
      );
    }

    if (method == 'POST' && path == '/api/register') {
      backend.registerCallCount++;
      final body = _bodyMap(options);
      if (backend.failRegisterWith != null) {
        return _status(
          422,
          jsonEncode({
            'message': 'That email is already in use.',
            'code': backend.failRegisterWith,
          }),
        );
      }
      final email = body['email']?.toString() ?? '';
      final name = body['name']?.toString() ?? '';
      backend.registeredEmail = email;
      if (name.isNotEmpty) backend.registeredName = name;
      backend.registerCodeRequested = true;
      // Zero token: pending users verify first, then log in.
      return _status(
        201,
        jsonEncode({
          'user': {
            'id': 1,
            'name': backend.registeredName,
            'email': email,
            'is_admin': false,
          },
          'message': 'Verify your email to finish registration.',
          'code_expires_at': '2026-09-27T10:00:00.000Z',
        }),
      );
    }

    if (method == 'POST' && path == '/api/register/verify') {
      backend.registerVerifyCallCount++;
      final body = _bodyMap(options);
      if (backend.failRegisterVerifyWith != null) {
        return _status(
          backend.failRegisterVerifyWith == 'REGISTER_NONE' ? 404 : 422,
          jsonEncode({
            'message': 'Registration verification failed.',
            'code': backend.failRegisterVerifyWith,
            if (backend.failRegisterVerifyWith == 'EMAIL_CODE_MISMATCH')
              'attempts_left': 4,
          }),
        );
      }
      final email = body['email']?.toString() ?? '';
      if (email == backend.registeredEmail &&
          backend.verifiedEmails.contains(email)) {
        // A11: verify is idempotent once the address is verified.
        return _json(
          jsonEncode({
            'id': 1,
            'name': backend.registeredName,
            'email': email,
            'is_admin': false,
          }),
        );
      }
      if (!backend.registerCodeRequested ||
          backend.registeredEmail == null ||
          email != backend.registeredEmail) {
        return _status(
          404,
          jsonEncode({
            'message': 'No pending registration.',
            'code': 'REGISTER_NONE',
          }),
        );
      }
      if (body['code']?.toString() == backend.acceptedCode) {
        backend.verifiedEmails.add(email);
        backend.registerCodeRequested = false;
        return _json(
          jsonEncode({
            'id': 1,
            'name': backend.registeredName,
            'email': email,
            'is_admin': false,
          }),
        );
      }
      return _status(
        422,
        jsonEncode({
          'message': "That code doesn't match.",
          'code': 'EMAIL_CODE_MISMATCH',
          'attempts_left': 4,
        }),
      );
    }

    if (method == 'POST' && path == '/api/register/resend') {
      backend.registerResendCallCount++;
      final body = _bodyMap(options);
      final email = body['email']?.toString() ?? '';
      if (backend.registeredEmail == null || email != backend.registeredEmail) {
        return _status(
          404,
          jsonEncode({
            'message': 'No pending registration.',
            'code': 'REGISTER_NONE',
          }),
        );
      }
      if (backend.failRegisterResendCooldown) {
        return _status(
          429,
          jsonEncode({
            'message': 'Please wait a minute.',
            'code': 'EMAIL_CODE_RESEND_TOO_SOON',
          }),
        );
      }
      backend.registerCodeRequested = true;
      return _json(
        jsonEncode({
          'message': 'Code re-sent.',
          'code_expires_at': '2026-09-27T10:00:00.000Z',
        }),
      );
    }

    if (method == 'POST' && path == '/api/login') {
      backend.loginCallCount++;
      final body = _bodyMap(options);
      final email = body['email']?.toString() ?? '';
      if (email == backend.registeredEmail &&
          !backend.verifiedEmails.contains(email)) {
        return _status(
          422,
          jsonEncode({
            'message': 'Verify your email first.',
            'code': 'EMAIL_NOT_VERIFIED',
          }),
        );
      }
      if (email != backend.registeredEmail ||
          !backend.verifiedEmails.contains(email)) {
        // Unknown address: legacy 404 (no test user exists).
        return _status(404, '{"detail":"not found"}');
      }
      return _json(
        jsonEncode({
          'user': {
            'id': 1,
            'name': backend.registeredName,
            'email': email,
            'is_admin': false,
          },
          'access_token': 'fake-token',
          'token_type': 'Bearer',
        }),
      );
    }

    return _status(404, '{"detail":"not found"}');
  }

  Map<String, Object?> _profileJson() => {
        'id': 1,
        'name': backend.profileName,
        'email': backend.profileEmail,
        'is_admin': false,
      };

  Map<String, Object?> _bodyMap(RequestOptions options) {
    final data = options.data;
    if (data is Map) return Map<String, Object?>.from(data);
    if (data is String && data.isNotEmpty) {
      return Map<String, Object?>.from(jsonDecode(data) as Map);
    }
    try {
      final json = (data as dynamic).toJson() as Map;
      return Map<String, Object?>.from(json);
    } catch (_) {
      return {};
    }
  }
}

ResponseBody _json(String body) {
  return ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ResponseBody _status(int code, [String? body]) {
  return ResponseBody.fromString(
    body ?? '',
    code,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

RestClient buildFakeRestClient(FakeApiBackend backend) {
  final dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
    ..httpClientAdapter = FakeHttpClientAdapter(backend);
  return RestClient(dio);
}

