import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/booking_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

/// C19 wizard merge: 3-step breadcrumbs/timeline, no package-details
/// route in the booking flow, Back preserves the chosen date.
Package _c19Package() => const Package(
  id: 42,
  name: 'Dior Women Luxury Experience',
  price: 4500.0,
  paxOptions: [20, 30, 50, 75, 100],
);

Widget _c19Harness(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: ResponsiveAppShell(
        child: BookingScreen(packageId: 42),
      ),
    ),
  );
}

ProviderContainer _c19Container() {
  final container = ProviderContainer(
    overrides: [
      packageDetailsProvider(42).overrideWith((ref) => _c19Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(FakeApiBackend()),
      ),
    ],
  );
  return container;
}

void main() {
  group('c19 wizard merge', () {
    testWidgets('desktop header shows unified Schedule Details Payment', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = _c19Container();
      addTearDown(container.dispose);
      await tester.pumpWidget(_c19Harness(container));
      await tester.pumpAndSettle();

      // C27: one timeline everywhere — desktop matches mobile labels.
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('01 Date & Time'), findsNothing);
      expect(find.text('02 Details'), findsNothing);
      expect(find.text('03 Review & Pay'), findsNothing);
      expect(find.text('01 Details'), findsNothing);
      expect(find.text('02 Pax Choice'), findsNothing);
      expect(find.text('04 Checkout'), findsNothing);
      expect(find.text('05 Confirmed'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile timeline shows Schedule Details Payment only', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = _c19Container();
      addTearDown(container.dispose);
      await tester.pumpWidget(_c19Harness(container));
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Pax Choice'), findsNothing);
      // Note: 'Scents' still appears as in-flow content (scent shelf),
      // just no longer as a timeline step.
      expect(tester.takeException(), isNull);
    });

    testWidgets('header Back preserves the selected date', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = _c19Container();
      addTearDown(container.dispose);
      await tester.pumpWidget(_c19Harness(container));
      await tester.pumpAndSettle();

      final target = DateTime(2030, 6, 15);
      container.read(bookingFlowProvider.notifier).setSelectedDate(target);
      // C169: Scent is required to proceed — seed one (as the Package
      // detail shelf would) so the flow can advance past Schedule.
      container.read(bookingFlowProvider.notifier).toggleScent(1);
      await tester.pumpAndSettle();

      // C74: Schedule → Details → Payment (no direct jump).
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('desktop_details_form_view')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('desktop_payment_panel_view')),
        findsNothing,
      );

      // Fill Details, then proceed to Payment.
      const detailsFields = {
        'desktop_customer_name': 'Maria Clara',
        'desktop_customer_email': 'maria@example.com',
        'desktop_customer_phone': '+639171234567',
        'desktop_venue_address': 'The Peninsula Manila',
      };
      for (final entry in detailsFields.entries) {
        final finder = find.byKey(Key(entry.key));
        await tester.ensureVisible(finder);
        await tester.enterText(finder, entry.value);
        await tester.pump();
      }
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('desktop_payment_panel_view')),
        findsOneWidget,
      );

      final back = find.text('Back');
      await tester.ensureVisible(back);
      await tester.pumpAndSettle();
      await tester.tap(back);
      await tester.pumpAndSettle();

      // Stepwise back (mobile parity): 4→3 lands on the Details form
      // with the selected date preserved in the flow.
      expect(
        container.read(bookingFlowProvider).selectedDate,
        equals(target),
      );
      expect(
        find.byKey(const Key('desktop_details_form_view')),
        findsOneWidget,
      );

      // 3→2 returns to the schedule layout; the date survives there too.
      final backAgain = find.text('Back');
      await tester.ensureVisible(backAgain);
      await tester.pumpAndSettle();
      await tester.tap(backAgain);
      await tester.pumpAndSettle();

      expect(
        container.read(bookingFlowProvider).selectedDate,
        equals(target),
      );
      expect(
        find.byKey(const Key('reservation_calendar_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
