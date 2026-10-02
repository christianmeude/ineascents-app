import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/my_bookings_screen.dart';
import 'package:inea_scents_client/utils/feedback_api.dart';
import 'package:inea_scents_client/utils/feedback_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// C146: post-event feedback popup + `Rate experience` action +
/// client-detected completion + Completed Status parsing.
class FakeFeedbackApi implements FeedbackApi {
  final List<int> completedIds = [];
  final List<Map<String, Object?>> feedbacks = [];
  bool throwOnComplete = false;
  bool throwOnFeedback = false;

  @override
  Future<void> completeBooking(int bookingId) async {
    if (throwOnComplete) throw Exception('offline');
    completedIds.add(bookingId);
  }

  @override
  Future<void> submitFeedback({
    required int stars,
    String? text,
    int? bookingId,
  }) async {
    if (throwOnFeedback) throw Exception('offline');
    feedbacks.add({
      'stars': stars,
      'text': text,
      'booking_id': bookingId,
    });
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Booking sample({
    required int id,
    required String status,
    required DateTime date,
  }) =>
      Booking(
        id: id,
        bookingReference: 'REF-$id',
        status: status,
        customerName: 'Customer',
        pax: 50,
        eventDate: date,
        venueAddress: 'The Peninsula Manila',
        package: Package(id: 1, name: 'Essential 10ml', price: 4499),
      );

  DateTime past() => DateTime.now().subtract(const Duration(days: 30));
  DateTime future() => DateTime.now().add(const Duration(days: 30));

  GoRouter buildRouter() => GoRouter(
        initialLocation: '/bookings',
        routes: [
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const MyBookingsScreen(),
          ),
        ],
      );

  Future<FakeFeedbackApi> pumpBookings(
    WidgetTester tester,
    List<Booking> bookings, {
    FakeFeedbackApi? api,
    Map<String, Object>? prefs,
  }) async {
    SharedPreferences.setMockInitialValues(prefs ?? {});
    final fake = api ?? FakeFeedbackApi();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookingsProvider.overrideWith((ref) => Future.value(bookings)),
          feedbackApiProvider.overrideWithValue(fake),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fake;
  }

  group('Completed Status parsing', () {
    test('isCompletedStatus matches only Completed', () {
      expect(isCompletedStatus('Completed'), isTrue);
      expect(isCompletedStatus('completed'), isTrue);
      // Never regress Pending / Confirmed / Cancelled.
      expect(isCompletedStatus('Pending'), isFalse);
      expect(isCompletedStatus('Confirmed'), isFalse);
      expect(isCompletedStatus('Cancelled'), isFalse);
      expect(isCompletedStatus('paid'), isFalse);
      expect(isCompletedStatus(null), isFalse);
      expect(isCompletedStatus(''), isFalse);
    });

    test('isConfirmedStatus matches Confirmed + paid alias only', () {
      expect(isConfirmedStatus('Confirmed'), isTrue);
      expect(isConfirmedStatus('confirmed'), isTrue);
      expect(isConfirmedStatus('paid'), isTrue);
      expect(isConfirmedStatus('Completed'), isFalse);
      expect(isConfirmedStatus('Pending'), isFalse);
      expect(isConfirmedStatus(null), isFalse);
    });

    test('isEventPast is day-level: past yes, today/future/null no', () {
      expect(isEventPast(past()), isTrue);
      final now = DateTime.now();
      expect(isEventPast(DateTime(now.year, now.month, now.day)), isFalse);
      expect(isEventPast(future()), isFalse);
      expect(isEventPast(null), isFalse);
    });

    testWidgets('all four Status badges render, Completed included', (
      tester,
    ) async {
      await pumpBookings(tester, [
        sample(id: 1, status: 'Pending', date: future()),
        sample(id: 2, status: 'Confirmed', date: future()),
        sample(id: 3, status: 'Completed', date: past()),
        sample(id: 4, status: 'Cancelled', date: past()),
      ], prefs: {
        // Suppress the popup so badges assert without dialog interference.
        'feedback_seen_ids': ['3'],
      });

      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('post-event popup', () {
    testWidgets('shows once per Completed past Booking', (tester) async {
      await pumpBookings(tester, [
        sample(id: 7, status: 'Completed', date: past()),
      ]);

      expect(find.text('How was your experience?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Not now dismisses and never nags again', (tester) async {
      await pumpBookings(tester, [
        sample(id: 7, status: 'Completed', date: past()),
      ]);
      expect(find.text('How was your experience?'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('How was your experience?'), findsNothing);

      // Fresh tree, same persisted storage: still no popup.
      final fake = FakeFeedbackApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingsProvider.overrideWith(
              (ref) => Future.value(
                  [sample(id: 7, status: 'Completed', date: past())]),
            ),
            feedbackApiProvider.overrideWithValue(fake),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: buildRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('How was your experience?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no popup for future or non-Completed Bookings', (
      tester,
    ) async {
      await pumpBookings(tester, [
        sample(id: 1, status: 'Completed', date: future()),
        sample(id: 2, status: 'Pending', date: past()),
      ]);

      expect(find.text('How was your experience?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submit posts stars + booking_id, hides popup + action', (
      tester,
    ) async {
      final fake = await pumpBookings(tester, [
        sample(id: 7, status: 'Completed', date: past()),
      ]);
      expect(find.text('How was your experience?'), findsOneWidget);

      // Stars required: Submit starts disabled.
      final submit = find.byKey(const Key('feedback_submit'));
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

      await tester.tap(find.byKey(const Key('feedback_star_4')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('feedback_text_field')),
        'Loved the Scent bar!',
      );
      await tester.pumpAndSettle();

      // Optional text capped at 500.
      expect(
        tester.widget<TextField>(find.byKey(const Key('feedback_text_field')))
            .maxLength,
        500,
      );

      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(fake.feedbacks, hasLength(1));
      expect(fake.feedbacks.single['stars'], 4);
      expect(fake.feedbacks.single['text'], 'Loved the Scent bar!');
      expect(fake.feedbacks.single['booking_id'], 7);
      expect(find.text('How was your experience?'), findsNothing);
      expect(find.text('Rate experience'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offline submit stays open with retryable message', (
      tester,
    ) async {
      final fake = FakeFeedbackApi()..throwOnFeedback = true;
      await pumpBookings(
        tester,
        [sample(id: 7, status: 'Completed', date: past())],
        api: fake,
      );

      await tester.tap(find.byKey(const Key('feedback_star_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('feedback_submit')));
      await tester.pumpAndSettle();

      // Graceful offline: dialog stays, nothing persisted.
      expect(find.text('How was your experience?'), findsOneWidget);
      expect(find.textContaining('Could not send feedback'), findsOneWidget);
      expect(fake.feedbacks, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('Rate experience action', () {
    testWidgets('visible for Completed past Booking without feedback', (
      tester,
    ) async {
      await pumpBookings(
        tester,
        [sample(id: 7, status: 'Completed', date: past())],
        prefs: {
          'feedback_seen_ids': ['7'],
        },
      );

      expect(find.text('Rate experience'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hidden once feedback is submitted', (tester) async {
      await pumpBookings(
        tester,
        [sample(id: 7, status: 'Completed', date: past())],
        prefs: {
          'feedback_submitted_ids': ['7'],
        },
      );

      expect(find.text('Rate experience'), findsNothing);
      expect(find.text('How was your experience?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hidden for non-Completed Bookings', (tester) async {
      await pumpBookings(tester, [
        sample(id: 1, status: 'Pending', date: past()),
        sample(id: 2, status: 'Confirmed', date: future()),
        sample(id: 3, status: 'Cancelled', date: past()),
      ]);

      expect(find.text('Rate experience'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens the same form any time', (tester) async {
      await pumpBookings(
        tester,
        [sample(id: 7, status: 'Completed', date: past())],
        prefs: {
          'feedback_seen_ids': ['7'],
        },
      );

      await tester.tap(find.text('Rate experience'));
      await tester.pumpAndSettle();
      expect(find.text('How was your experience?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('client-detected completion', () {
    testWidgets('fires complete for past Confirmed Bookings', (tester) async {
      final fake = await pumpBookings(tester, [
        sample(id: 9, status: 'Confirmed', date: past()),
        sample(id: 10, status: 'Confirmed', date: future()),
        sample(id: 11, status: 'Pending', date: past()),
      ]);

      expect(fake.completedIds, contains(9));
      expect(fake.completedIds, isNot(contains(10)));
      expect(fake.completedIds, isNot(contains(11)));
      expect(find.text('How was your experience?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offline complete is swallowed, list still renders', (
      tester,
    ) async {
      final fake = FakeFeedbackApi()..throwOnComplete = true;
      await pumpBookings(
        tester,
        [sample(id: 9, status: 'Confirmed', date: past())],
        api: fake,
      );

      expect(find.text('REF-9'), findsOneWidget);
      expect(find.text('How was your experience?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
