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

  final package = Package(
    id: 42,
    name: 'Test Package',
    description: 'x',
    price: 10000.0,
    rating: 4.9,
    reviewsCount: 1,
    inclusions: ['4 Inspired scents', '2 Souvenirs'],
    freebies: ['Selfie Mirror'],
    paxOptions: [50, 150],
    images: const [],
  );

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        packageDetailsProvider(42).overrideWith((ref) => package),
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
          child: BookingScreen(packageId: 42, initialPax: 150),
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
    'C155: Price Details distilled — no per-row Included/Free, no tier-price subtitle, 150 pax kept',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = buildContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(buildWidget(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      await fillMobileContacts(tester);
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();

      expect(find.text('Price Details'), findsOneWidget);

      // 150 pax row kept (no tier-price subtitle).
      expect(find.text('150 PAX'), findsOneWidget);
      expect(find.textContaining('tier price'), findsNothing);

      // No per-row Included/Free trailing texts.
      expect(find.text('Included'), findsNothing);
      expect(find.text('Free'), findsNothing);

      // Inclusion labels still render as bullets; amounts + total kept.
      expect(find.textContaining('4 Inspired scents'), findsOneWidget);
      expect(
        find.byKey(const Key('price_details_pax_row')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('price_details_total_row')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('price_details_total_amount')),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    },
  );
}
