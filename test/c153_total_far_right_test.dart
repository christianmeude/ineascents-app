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

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        packageDetailsProvider(42).overrideWith((ref) => longPackage),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(FakeApiBackend()),
        ),
      ],
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

  Future<void> goToMobilePayment(WidgetTester tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Step 2 → Step 3.
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();

    // Step 3 → Step 4 (payment).
    await fillMobileContacts(tester);
    await tester.tap(find.text('Proceed to Payment'));
    await tester.pumpAndSettle();
  }

  for (final width in [360.0, 767.0]) {
    testWidgets(
      'C153: total amount pinned far-right, no overflow at ${width.toInt()}px',
      (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await goToMobilePayment(tester);

        expect(find.text('Price Details'), findsOneWidget);
        final totalRow = find.byKey(const Key('price_details_total_row'));
        final totalAmount = find.byKey(
          const Key('price_details_total_amount'),
        );
        expect(totalRow, findsOneWidget);
        expect(totalAmount, findsOneWidget);

        await tester.ensureVisible(totalRow);
        await tester.pumpAndSettle();

        // Amount cell flush with the row's right edge (far-right of card).
        final rowRight = tester.getRect(totalRow).right;
        final cellRight = tester.getRect(totalAmount).right;
        expect(cellRight, moreOrLessEquals(rowRight, epsilon: 1.0));

        // Rendered text itself ends at the cell's right edge (no left drift
        // from wrapping) and is never truncated with ellipsis.
        final amountText = tester.widget<Text>(
          find.descendant(of: totalAmount, matching: find.byType(Text)),
        );
        expect(amountText.data, contains('₱'));
        expect(amountText.textAlign, TextAlign.end);
        expect(amountText.overflow, isNot(TextOverflow.ellipsis));
        final textRight = tester
            .getRect(
              find.descendant(of: totalAmount, matching: find.byType(Text)),
            )
            .right;
        expect(textRight, moreOrLessEquals(cellRight, epsilon: 1.0));

        // Overflow-free.
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'C153: tablet rail untouched at 768px, no overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Mobile price-details card does not render on tablet; the rail owns
      // the total there.
      expect(find.byKey(const Key('price_details_total_row')), findsNothing);
      expect(
        find.byKey(const Key('tablet_order_summary_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
