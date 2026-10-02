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

/// C169: booking-flow stepper + copy polish with scent required — the
/// step order (Schedule → Details → Payment) is unchanged, every step
/// carries helper copy in domain terms, and the flow cannot proceed
/// without at least 1 chosen Scent.
Package _c169Package() => const Package(
  id: 42,
  name: 'Dior Women Luxury Experience',
  price: 4500.0,
  paxOptions: [20, 30, 50, 75, 100],
);

ProviderContainer _c169Container({FakeApiBackend? backend}) {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(42).overrideWith((ref) => _c169Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(backend ?? FakeApiBackend()),
      ),
    ],
  );
}

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ResponsiveAppShell(child: BookingScreen(packageId: 42)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillMobileContacts(WidgetTester tester) async {
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c169 stepper copy', () {
    testWidgets('mobile schedule carries the sharpened step copy', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      // Timeline order unchanged.
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      // Sharpened step label + helper copy.
      expect(find.text('Choose Your Schedule'), findsOneWidget);
      expect(
        find.text('Pick an open date and Time Slot for your Booking.'),
        findsOneWidget,
      );
      // No Scent chosen yet: the requirement hint shows.
      expect(find.byKey(const Key('scent_required_hint')), findsOneWidget);
      expect(
        find.text(
          'Choose at least 1 Scent on the Package detail to continue your Booking.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop schedule carries the rail Scent hint', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(1200, 800));

      // C144 geometry intact: no in-card helper, no chips when empty.
      expect(find.byKey(const Key('schedule_datetime_card')), findsOneWidget);
      expect(find.text('Select Date & Time'), findsOneWidget);
      expect(find.byKey(const Key('selected_scents_chips')), findsNothing);
      // The sticky rail carries the Scent requirement at the decision
      // point instead (internal scroll — fixed geometry unaffected).
      expect(
        find.byKey(const Key('order_summary_scent_hint')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Choose at least 1 Scent on the Package detail to continue your Booking.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('details + payment steps carry helper copy', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      container.read(bookingFlowProvider.notifier).toggleScent(1);
      await _pump(tester, container, const Size(390, 844));

      // Requirement hint retires once a Scent is chosen.
      expect(find.byKey(const Key('scent_required_hint')), findsNothing);

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();
      expect(find.text('Booking Details'), findsOneWidget);
      expect(
        find.text(
          'Confirm your Package, Time Slot and Pax below, then share your contact details.',
        ),
        findsOneWidget,
      );

      await _fillMobileContacts(tester);
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      expect(find.text('Price Details'), findsOneWidget);
      expect(
        find.text(
          'Review your Booking below, then choose a Payment Method for Checkout.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet schedule shows helper copy plus rail Scent hint', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(900, 1200));

      expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
      expect(
        find.text('Pick an open date and Time Slot for your Booking.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('order_summary_scent_hint')),
        findsOneWidget,
      );
      // The in-flow hint is mobile-only; the rail owns it here.
      expect(find.byKey(const Key('scent_required_hint')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('c169 scent-required gate', () {
    testWidgets('mobile proceed is blocked with no Scent', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      // Still on Schedule with the inline gate message.
      expect(find.text('Choose Your Schedule'), findsOneWidget);
      expect(find.text('Booking Details'), findsNothing);
      expect(
        find.text('Choose at least 1 Scent to continue your Booking.'),
        findsOneWidget,
      );
      expect(
        container.read(bookingFlowProvider).currentStep,
        2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile proceed is allowed with one Scent', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      container.read(bookingFlowProvider.notifier).toggleScent(2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('Booking Details'), findsOneWidget);
      expect(
        find.text('Choose at least 1 Scent to continue your Booking.'),
        findsNothing,
      );
      expect(
        container.read(bookingFlowProvider).currentStep,
        3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop rail is blocked with no Scent', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c169Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(1200, 800));

      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('schedule_datetime_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('desktop_details_form_view')),
        findsNothing,
      );
      expect(
        find.text('Choose at least 1 Scent to continue your Booking.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('submit is blocked with no Scent and never POSTs', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final backend = FakeApiBackend();
      final container = _c169Container(backend: backend);
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      // Jump straight to Payment (deep link / resumed draft edge): the
      // submit guard still refuses without a Scent.
      container.read(bookingFlowProvider.notifier).goToStep(4);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Confirm & Pay'));
      await tester.pumpAndSettle();

      expect(backend.createBookingCallCount, 0);
      expect(
        container.read(bookingFlowProvider).booking,
        isNull,
      );
      expect(
        find.text('Choose at least 1 Scent to continue your Booking.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
