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

/// C157: web stage swaps instantly (no AnimatedSwitcher on web widths),
/// mobile keeps slide + fade, reduced-motion gate intact.
Package _c157Package() => const Package(
  id: 42,
  name: 'Dior Women Luxury Experience',
  price: 4500.0,
  paxOptions: [20, 30, 50, 75, 100],
);

ProviderContainer _c157Container() {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(42).overrideWith((ref) => _c157Package()),
      apiClientProvider.overrideWithValue(buildFakeRestClient(FakeApiBackend())),
    ],
  );
}

Widget _c157Harness(ProviderContainer container, {bool disableAnimations = false}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: ResponsiveAppShell(child: BookingScreen(packageId: 42)),
    ),
  );
}

Future<void> _pumpSize(
  WidgetTester tester,
  ProviderContainer container,
  Size size, {
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    _c157Harness(container, disableAnimations: disableAnimations),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('c157 no stage anim on web', () {
    testWidgets('web width swaps instantly: no AnimatedSwitcher', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      debugBookingStageWebInstant = true;
      addTearDown(() => debugBookingStageWebInstant = null);
      final container = _c157Container();
      addTearDown(container.dispose);
      await _pumpSize(tester, container, const Size(1280, 800));

      // Desktop schedule stage renders with no AnimatedSwitcher.
      expect(find.byType(AnimatedSwitcher), findsNothing);

      container.read(bookingFlowProvider.notifier).goToStep(3);
      await tester.pump();

      // Instant: details visible after one frame, still no switcher.
      expect(find.byType(AnimatedSwitcher), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile keeps AnimatedSwitcher with slide + fade', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      debugBookingStageWebInstant = false;
      addTearDown(() => debugBookingStageWebInstant = null);
      final container = _c157Container();
      addTearDown(container.dispose);
      await _pumpSize(tester, container, const Size(390, 844));

      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      container.read(bookingFlowProvider.notifier).goToStep(3);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SlideTransition), findsWidgets);
      expect(find.byType(FadeTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('mobile_details_summary_card')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced-motion gate intact on mobile path', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      debugBookingStageWebInstant = false;
      addTearDown(() => debugBookingStageWebInstant = null);
      final container = _c157Container();
      addTearDown(container.dispose);
      await _pumpSize(
        tester,
        container,
        const Size(390, 844),
        disableAnimations: true,
      );

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, Duration.zero);
      expect(tester.takeException(), isNull);
    });
  });
}
