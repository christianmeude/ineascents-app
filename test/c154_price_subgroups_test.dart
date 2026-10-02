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
    name: 'C154 Subgroups Package',
    description: 'x',
    price: 50000.0,
    rating: 4.9,
    reviewsCount: 1,
    inclusions: ['Inclusion Alpha', 'Inclusion Beta'],
    freebies: ['Freebie Gamma'],
    paxOptions: [50],
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
    'C154: Price Details shows Inclusions/Freebies subgroups with items under the correct group',
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
      expect(find.text('Inclusions:'), findsOneWidget);
      expect(find.text('Freebies:'), findsOneWidget);

      // Items render under the correct group header (top-to-bottom order).
      final inclusionsY = tester.getTopLeft(find.text('Inclusions:')).dy;
      final alphaY =
          tester.getTopLeft(find.text('• Inclusion Alpha')).dy;
      final betaY = tester.getTopLeft(find.text('• Inclusion Beta')).dy;
      final freebiesY = tester.getTopLeft(find.text('Freebies:')).dy;
      final gammaY = tester.getTopLeft(find.text('• Freebie Gamma')).dy;
      expect(inclusionsY, lessThan(alphaY));
      expect(alphaY, lessThan(freebiesY));
      expect(betaY, lessThan(freebiesY));
      expect(freebiesY, lessThan(gammaY));

      // C155: distilled rows — no per-row Included/Free trailing
      // texts (redundant with group headers); amounts live on Pax + Total.
      expect(find.text('Included'), findsNothing);
      expect(find.text('Free'), findsNothing);

      // Totals unchanged.
      expect(
        find.byKey(const Key('price_details_total_row')),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    },
  );
}
