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

Package _tiered() => const Package(
  id: 7,
  name: 'Unified Celebration Bar',
  price: 4499,
  paxOptions: [50, 70, 100, 150],
  paxPrices: {50: 4499.0, 70: 6399.0, 100: 8799.0, 150: 13119.0},
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'C24: higher ?pax= survives refresh to Checkout (no lowest downgrade)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          packageDetailsProvider(7).overrideWith((ref) => _tiered()),
          apiClientProvider.overrideWithValue(
            buildFakeRestClient(FakeApiBackend()),
          ),
        ],
      );
      addTearDown(container.dispose);

      // C169: Scent is required to proceed — seed one (as the Package
      // detail shelf would) so the flow can advance past Schedule.
      container.read(bookingFlowProvider.notifier).toggleScent(1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResponsiveAppShell(
              child: BookingScreen(packageId: 7, initialPax: 100),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Booking shows the carried higher option, never the lowest.
      expect(container.read(bookingFlowProvider).selectedPax, 100);
      expect(find.textContaining('100 PAX'), findsWidgets);

      // A package refetch (loading→data) must not wipe the higher pax.
      container.invalidate(packageDetailsProvider(7));
      await tester.pumpAndSettle();
      expect(container.read(bookingFlowProvider).selectedPax, 100);
      expect(find.textContaining('100 PAX'), findsWidgets);

      // C74: Checkout (payment step) keeps the higher pax — reached
      // via Details (Schedule → Details → Payment, no direct jump).
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
      expect(container.read(bookingFlowProvider).selectedPax, 100);
      expect(find.textContaining('100 PAX'), findsWidgets);
    },
  );

  testWidgets('C24: async package load still honors higher ?pax=', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        packageDetailsProvider(7).overrideWith((ref) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return _tiered();
        }),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(FakeApiBackend()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ResponsiveAppShell(
            child: BookingScreen(packageId: 7, initialPax: 150),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(container.read(bookingFlowProvider).selectedPax, 150);
    expect(find.textContaining('150 PAX'), findsWidgets);
  });
}
