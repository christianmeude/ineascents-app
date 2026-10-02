import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/package_detail_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C167: package detail back button returns to the packages list.
Package _c167Package() => const Package(
  id: 1,
  name: 'Essential 10ml Scent Bar',
  description: 'A signature scent experience for your celebration.',
  price: 4499,
  rating: 4.5,
  reviewsCount: 232,
  paxOptions: [50, 70, 100, 150],
  paxPrices: {50: 4499.0, 70: 6399.0, 100: 8799.0, 150: 13119.0},
  inclusions: ['2-hour scent bar'],
  freebies: ['Keepsake atomizer'],
);

ProviderContainer _c167Container() {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(1).overrideWith((ref) => _c167Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(FakeApiBackend()),
      ),
    ],
  );
}

GoRouter _c167Router({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/packages',
        builder: (context, state) => const Text('Packages Page'),
      ),
      GoRoute(
        path: '/packages/:id',
        builder: (context, state) => PackageDetailScreen(
          packageId: int.parse(state.pathParameters['id']!),
          initialPax: int.tryParse(state.queryParameters['pax'] ?? ''),
        ),
      ),
    ],
  );
}

Future<void> _pumpRouter(
  WidgetTester tester,
  ProviderContainer container,
  GoRouter router,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c167 detail back button', () {
    testWidgets('back button renders on the detail screen', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c167Container();
      addTearDown(container.dispose);
      final router = _c167Router(initialLocation: '/packages/1?pax=70');
      addTearDown(router.dispose);
      await _pumpRouter(tester, container, router);

      expect(find.byKey(const Key('detail_back')), findsOneWidget);
      expect(find.text('Back to Packages'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deep link back falls back to /packages', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c167Container();
      addTearDown(container.dispose);
      final router = _c167Router(initialLocation: '/packages/1?pax=70');
      addTearDown(router.dispose);
      await _pumpRouter(tester, container, router);

      await tester.ensureVisible(find.byKey(const Key('detail_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_back')));
      await tester.pumpAndSettle();

      expect(find.text('Packages Page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pushed detail back pops to the packages list', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c167Container();
      addTearDown(container.dispose);
      final router = _c167Router(initialLocation: '/packages');
      addTearDown(router.dispose);
      await _pumpRouter(tester, container, router);
      expect(find.text('Packages Page'), findsOneWidget);

      router.push('/packages/1?pax=70');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_back')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('detail_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_back')));
      await tester.pumpAndSettle();

      expect(find.text('Packages Page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
