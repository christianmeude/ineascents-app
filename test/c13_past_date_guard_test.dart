import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/booking_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

/// C13: submit-time past-date guard + booking re-entry preserves the
/// selected date.
///
/// Guard point is `_handleConfirmAndPay` (the single production caller of
/// `submitBooking`): a date whose calendar day is before today is rejected
/// with a message and never reaches POST. Today itself stays allowed.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testPackage = Package(
    id: 7,
    name: 'Test Celebration Bar',
    price: 4500.0,
    paxOptions: [50],
  );

  /// Pumps [BookingScreen] on a fresh container using [backend].
  /// Returns the container so tests can preset/inspect flow state.
  Future<ProviderContainer> pumpBooking(
    WidgetTester tester, {
    required FakeApiBackend backend,
    DateTime? initialDate,
    Size size = const Size(375, 667),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        packageDetailsProvider(7).overrideWith((ref) => testPackage),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(backend),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ResponsiveAppShell(
            child: BookingScreen(packageId: 7, initialDate: initialDate),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// Re-pumps a fresh [BookingScreen] instance on the same [container],
  /// simulating booking re-entry (provider state persists across routes).
  Future<void> reenterBooking(
    WidgetTester tester,
    ProviderContainer container, {
    DateTime? initialDate,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ResponsiveAppShell(
            child: BookingScreen(packageId: 7, initialDate: initialDate),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// C48: conversion lives in the sticky bottom bar outside the page
  /// scroll — bar buttons tap directly, never via scrollUntilVisible.
  Future<void> tapBar(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Fills the contact fields on the mobile Step 3 (Details) view.
  Future<void> fillMobileContacts(WidgetTester tester) async {
    const fields = {
      'mobile_customer_name': 'Maria Clara',
      'mobile_customer_email': 'maria@example.com',
      'mobile_customer_phone': '+639171234567',
      'mobile_venue_address': 'The Peninsula Manila',
    };
    for (final entry in fields.entries) {
      final finder = find.byKey(Key(entry.key));
      await tester.ensureVisible(finder);
      await tester.enterText(finder, entry.value);
      await tester.pump();
    }
  }

  /// Drives the mobile flow to the Step 4 payment screen.
  Future<void> driveToPayment(WidgetTester tester) async {
    await tapBar(tester, find.text('Proceed'));
    await fillMobileContacts(tester);
    await tapBar(tester, find.text('Proceed to Payment'));
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.textContaining('Confirm & Pay'), findsOneWidget);
  }

  void presetSchedule(
    ProviderContainer container, {
    required DateTime date,
  }) {
    container.read(bookingFlowProvider.notifier)
      ..setSelectedPackage(testPackage)
      ..setSelectedDate(date)
      ..setSelectedTime('14:00:00')
      ..setSelectedPax(50)
      // C169: Scent is required to proceed — seed one (as the Package
      // detail shelf would) so the flow can advance past Schedule.
      ..toggleScent(1)
      ..setPaymentMethod('online');
  }

  group('C13 submit-time past-date guard', () {
    testWidgets(
      'past selected date is rejected with a message and never POSTs',
      (WidgetTester tester) async {
        final backend = FakeApiBackend();
        final container = await pumpBooking(tester, backend: backend);
        final yesterday =
            DateTime.now().subtract(const Duration(days: 1));
        presetSchedule(container, date: yesterday);

        await driveToPayment(tester);
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'The selected date has passed. Please choose a new date.',
          ),
          findsOneWidget,
        );
        expect(backend.createBookingCallCount, 0);
        final flow = container.read(bookingFlowProvider);
        expect(flow.booking, isNull);
        expect(flow.checkoutStatus, BookingCheckoutStatus.idle);
        expect(find.text('Payment Successful'), findsNothing);
      },
    );

    testWidgets(
      'today is allowed and submits normally',
      (WidgetTester tester) async {
        final backend = FakeApiBackend();
        final container = await pumpBooking(tester, backend: backend);
        presetSchedule(container, date: DateTime.now());

        await driveToPayment(tester);
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();

        expect(backend.createBookingCallCount, 1);
        expect(
          find.text(
            'The selected date has passed. Please choose a new date.',
          ),
          findsNothing,
        );
        expect(find.text('Payment Successful'), findsOneWidget);
      },
    );

    testWidgets(
      'after rejection, choosing a new date submits normally',
      (WidgetTester tester) async {
        final backend = FakeApiBackend();
        final container = await pumpBooking(tester, backend: backend);
        final yesterday =
            DateTime.now().subtract(const Duration(days: 1));
        presetSchedule(container, date: yesterday);

        await driveToPayment(tester);
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();
        expect(backend.createBookingCallCount, 0);

        // Recovery: pick a fresh date and confirm again. Let the
        // rejection SnackBar expire first so it can't cover the button.
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        container
            .read(bookingFlowProvider.notifier)
            .setSelectedDate(DateTime.now());
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();

        expect(backend.createBookingCallCount, 1);
        expect(find.text('Payment Successful'), findsOneWidget);
      },
    );
  });

  group('C13 booking re-entry preserves the selected date', () {
    testWidgets(
      're-entry without a carried date keeps the chosen date',
      (WidgetTester tester) async {
        final container = await pumpBooking(
          tester,
          backend: FakeApiBackend(),
        );
        final chosen = DateTime(2030, 5, 4);
        container.read(bookingFlowProvider.notifier)
          ..setSelectedPackage(testPackage)
          ..setSelectedDate(chosen);

        await reenterBooking(tester, container);

        expect(
          container.read(bookingFlowProvider).selectedDate,
          chosen,
        );
      },
    );

    testWidgets(
      're-entry with a stale carried date keeps the in-flow choice',
      (WidgetTester tester) async {
        final container = await pumpBooking(
          tester,
          backend: FakeApiBackend(),
        );
        final chosen = DateTime(2030, 5, 4);
        container.read(bookingFlowProvider.notifier)
          ..setSelectedPackage(testPackage)
          ..setSelectedDate(chosen);

        await reenterBooking(
          tester,
          container,
          initialDate: DateTime(2030, 1, 15),
        );

        expect(
          container.read(bookingFlowProvider).selectedDate,
          chosen,
        );
      },
    );
  });
}
