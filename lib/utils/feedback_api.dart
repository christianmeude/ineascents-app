import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/providers/core_providers.dart';

/// C146: post-event feedback + client-detected completion API.
///
/// Uses raw [Dio] (not the generated clients) so `lib/api/**` stays
/// untouched. Both calls are idempotent server-side; failures (backend A37
/// not live, offline) surface as thrown errors for callers to swallow —
/// the UI degrades gracefully and never nags.
///
/// Contract:
/// - POST /api/feedback (sanctum) body
///   `{stars: 1-5 required, text: max 500 optional, booking_id: nullable}`.
/// - POST /api/bookings/{id}/complete flips a past Confirmed Booking to
///   Completed (server validates Asia/Manila).
abstract class FeedbackApi {
  Future<void> submitFeedback({
    required int stars,
    String? text,
    int? bookingId,
  });

  Future<void> completeBooking(int bookingId);
}

class DioFeedbackApi implements FeedbackApi {
  DioFeedbackApi(this._dio);

  final Dio _dio;

  @override
  Future<void> submitFeedback({
    required int stars,
    String? text,
    int? bookingId,
  }) async {
    final trimmed = (text ?? '').trim();
    await _dio.post('/api/feedback', data: {
      'stars': stars,
      if (trimmed.isNotEmpty) 'text': trimmed,
      if (bookingId != null) 'booking_id': bookingId,
    });
  }

  @override
  Future<void> completeBooking(int bookingId) async {
    await _dio.post('/api/bookings/$bookingId/complete');
  }
}

final feedbackApiProvider = Provider<FeedbackApi>((ref) {
  return DioFeedbackApi(ref.watch(dioClientProvider).dio);
});

/// Bumped whenever feedback state changes (submit / dismiss) so the
/// `Rate experience` action and popup guards rebuild off fresh storage.
final feedbackRefreshProvider = StateProvider<int>((ref) => 0);
