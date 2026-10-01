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

/// C27 wizard mobile pass: Details step single-column under 768px,
/// desktop multi-column intact, one unified Schedule/Details/Payment
/// timeline on mobile + web.
Package _c27Package() => const Package(
  id: 42,
  name: 'Dior Women Luxury Experience',
  price: 4500.0,
  paxOptions: [20, 30, 50, 75, 100],
);

Widget _c27Harness(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: ResponsiveAppShell(child: BookingScreen(packageId: 42)),
    ),
  );
}

ProviderContainer _c27Container() {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(42).overrideWith((ref) => _c27Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(FakeApiBackend()),
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
  await tester.pumpWidget(_c27Harness(container));
  await tester.pumpAndSettle();
}

void main() {
  group('c27 wizard mobile single-column + unified timeline', () {
    testWidgets('Details step stacks one column at 390px', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c27Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      container.read(bookingFlowProvider.notifier).goToStep(3);
      await tester.pumpAndSettle();

      final summary = find.byKey(const Key('mobile_details_summary_card'));
      final card = find.byKey(const Key('mobile_details_package_card'));
      expect(summary, findsOneWidget);
      // C151: offering recap card removed from Details stage.
      expect(card, findsNothing);

      // Totals intact in summary card + contact section follows.
      expect(find.text('Total Cost:'), findsOneWidget);
      expect(find.text('Your Contact Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop schedule card intact at 1280px', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c27Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(1280, 800));

      // C92: one datetime card — calendar (inner col 1) beside time
      // (inner col 2), no Pax header, no event recap, desktop fixed.
      expect(
        find.byKey(const Key('desktop_schedule_stack_view')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('schedule_datetime_card')), findsOneWidget);
      expect(find.text('Select Date & Time'), findsOneWidget);
      final calRect = tester.getRect(
        find.byKey(const Key('reservation_calendar_panel')),
      );
      final timeRect = tester.getRect(
        find.byKey(const Key('event_time_picker_button')),
      );
      expect(calRect.left, lessThan(timeRect.left));
      expect(find.byKey(const Key('schedule_pax_header')), findsNothing);
      expect(find.byKey(const Key('schedule_event_summary')), findsNothing);
      expect(find.byKey(const Key('app_shell_scroll_view')), findsNothing);

      // Unified timeline labels, exactly once each.
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile timeline labels appear exactly once (no twin)', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c27Container();
      addTearDown(container.dispose);
      await _pump(tester, container, const Size(390, 844));

      for (final step in [2, 3, 4]) {
        container.read(bookingFlowProvider.notifier).goToStep(step);
        await tester.pumpAndSettle();
        // Timeline labels identical on every step; step 3 also shows
        // the in-step 'Details' section title (pre-existing content).
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);
        expect(
          find.text('Details'),
          step == 3 ? findsNWidgets(2) : findsOneWidget,
        );
      }
      expect(find.text('01 Date & Time'), findsNothing);
      expect(find.text('03 Review & Pay'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
