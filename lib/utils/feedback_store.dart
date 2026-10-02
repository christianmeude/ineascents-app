import 'package:shared_preferences/shared_preferences.dart';

/// C146: post-event feedback helpers.
///
/// Glossary: Booking Status values are `Pending` / `Confirmed` / `Completed`
/// / `Cancelled`. `Completed` is new — parsing must never regress the other
/// three.

/// True when [status] is the Completed Booking Status (case-insensitive).
bool isCompletedStatus(String? status) =>
    (status ?? '').trim().toLowerCase() == 'completed';

/// True when [status] is a live (pre-event) Confirmed Booking Status.
/// `paid` is the legacy alias the poller also treats as confirmed.
bool isConfirmedStatus(String? status) {
  final s = (status ?? '').trim().toLowerCase();
  return s == 'confirmed' || s == 'paid';
}

/// True when [eventDate]'s calendar day is strictly before today's
/// calendar day (local time). A Booking dated today is not past.
bool isEventPast(DateTime? eventDate, {DateTime? now}) {
  if (eventDate == null) return false;
  final ref = now ?? DateTime.now();
  final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
  final today = DateTime(ref.year, ref.month, ref.day);
  return eventDay.isBefore(today);
}

/// Local persistence for feedback popup state: per-Booking ids the Customer
/// already submitted feedback for, or already saw (dismissed via `Not now`).
/// Either set suppresses the once-per-booking popup.
class FeedbackStore {
  static const submittedKey = 'feedback_submitted_ids';
  static const seenKey = 'feedback_seen_ids';

  static Future<Set<int>> submittedIds() => _readIds(submittedKey);

  static Future<Set<int>> seenIds() => _readIds(seenKey);

  static Future<void> markSubmitted(int bookingId) =>
      _addId(submittedKey, bookingId);

  static Future<void> markSeen(int bookingId) => _addId(seenKey, bookingId);

  static Future<Set<int>> _readIds(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key)?.map(int.parse).toSet() ?? <int>{};
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> _addId(String key, int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(key)?.map(int.parse).toSet() ?? <int>{};
      ids.add(bookingId);
      await prefs.setStringList(
        key,
        ids.map((id) => id.toString()).toList(),
      );
    } catch (_) {
      // Offline / storage failure: popup may reappear next launch, but the
      // feedback flow itself stays usable.
    }
  }
}
