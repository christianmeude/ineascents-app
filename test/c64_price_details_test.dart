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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final longPackage = Package(
    id: 42,
    name: 'Dior Women Luxury Experience Extra Long Package Name Wrapping',
    description: 'x',
    price: 1234567.0,
    rating: 4.9,
    reviewsCount: 1,
    inclusions: [
      'An extremely long inclusion line that must wrap and never truncate the amount column at 360px width',
      '4 Inspired scents',
    ],
    freebies: ['Selfie Mirror with a very long freebie description wrapping'],
    paxOptions: [50],
    images: const [],
  );

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        packageDetailsProvider(42).overrideWith((ref) => longPackage),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(FakeApiBackend()),
        ),
      ],
    );
    // C169: Scent is required to proceed — seed one (as the Package
    // detail shelf would) so the flow can advance past Schedule.
    container.read(bookingFlowProvider.notifier).toggleScent(1);
    return container;
  }

  Widget buildWidget(ProviderContainer container) {
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

  testWidgets(
    'C64: Price Details rows render Pax→total in order, no overflow at 360px',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = buildContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(buildWidget(container));
      await tester.pumpAndSettle();

      // Step 2 → Step 3.
      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      // Step 3 → Step 4 (payment).
      await fillMobileContacts(tester);
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();

      expect(find.text('Price Details'), findsOneWidget);

      final paxRow = find.byKey(const Key('price_details_pax_row'));
      final totalRow = find.byKey(const Key('price_details_total_row'));
      final totalAmount = find.byKey(
        const Key('price_details_total_amount'),
      );
      expect(paxRow, findsOneWidget);
      expect(totalRow, findsOneWidget);
      expect(totalAmount, findsOneWidget);

      // Order: Pax row above total row.
      final paxY = tester.getTopLeft(paxRow).dy;
      final totalY = tester.getTopLeft(totalRow).dy;
      expect(paxY, lessThan(totalY));

      // Amounts render in full (never truncated with ellipsis).
      final amountText =
          tester.widget<Text>(find.descendant(
            of: totalAmount,
            matching: find.byType(Text),
          ));
      expect(amountText.data, contains('₱'));
      expect(amountText.overflow, isNot(TextOverflow.ellipsis));

      // Overflow-free at 360px.
      expect(tester.takeException(), isNull);
    },
  );
}
