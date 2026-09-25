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

  int putUserCallCount = 0;
  int verifyCallCount = 0;
  int resendCallCount = 0;

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

