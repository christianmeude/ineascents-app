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

/// C166: package-detail web layout — `Package Details` parent header plus
/// compact scent tiles on wide layouts (all 8 visible at a glance).
Package _c166Package() => const Package(
  id: 1,
  name: 'Essential 10ml Scent Bar',
  description: 'A signature scent experience for your celebration.',
  price: 4499,
  rating: 4.5,
  reviewsCount: 232,
  paxOptions: [50, 70, 100, 150],
  paxPrices: {50: 4499.0, 70: 6399.0, 100: 8799.0, 150: 13119.0},
  inclusions: ['2-hour scent bar', 'On-site scent concierge'],
  freebies: ['Keepsake atomizer'],
);

ProviderContainer _c166Container() {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(1).overrideWith((ref) => _c166Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(FakeApiBackend()),
      ),
    ],
  );
}

GoRouter _detailRouter() {
  return GoRouter(
    initialLocation: '/packages/1?pax=70',
    routes: [
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

Future<void> _pumpDetail(
  WidgetTester tester,
  ProviderContainer container,
  GoRouter router,
  Size size,
) async {
  tester.view.physicalSize = size;
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

String _counterText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('scent_counter'))).data!;
}

double _gridExtent(WidgetTester tester, String category) {
  final grid = tester.widget<GridView>(
    find.byKey(Key('scent_grid_$category')),
  );
  final delegate =
      grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  return delegate.mainAxisExtent!;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c166 package detail web layout', () {
    testWidgets('wide shows parent header + all 8 scents compact', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c166Container();
      addTearDown(container.dispose);
      final router = _detailRouter();
      addTearDown(router.dispose);
      await _pumpDetail(tester, container, router, const Size(1280, 800));

      expect(find.text('Package Details'), findsOneWidget);
      final viewRect = Offset.zero & const Size(1280, 800);
      for (var id = 1; id <= 8; id++) {
        final tile = find.byKey(Key('scent_tile_$id'));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(tile.hitTestable(), findsOneWidget);
        final tileRect = tester.getRect(tile);
        expect(
          viewRect.contains(tileRect.topLeft) &&
              viewRect.contains(tileRect.bottomRight),
          isTrue,
          reason: 'scent_tile_$id fully within viewport',
        );
      }
      expect(_gridExtent(tester, 'Women'), 124);
      expect(_gridExtent(tester, 'Men'), 124);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile keeps header + roomy tiles', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c166Container();
      addTearDown(container.dispose);
      final router = _detailRouter();
      addTearDown(router.dispose);
      await _pumpDetail(tester, container, router, const Size(390, 844));

      expect(find.text('Package Details'), findsOneWidget);
      expect(_counterText(tester), '0/4');
      expect(_gridExtent(tester, 'Women'), 168);
      expect(_gridExtent(tester, 'Men'), 168);
      // Toggle 4 tiles on → counter hits the cap.
      for (var id = 1; id <= 4; id++) {
        final tile = find.byKey(Key('scent_tile_$id'));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pump();
      }
      expect(_counterText(tester), '4/4');
      // 5th tap is over the cap → ignored, counter unchanged.
      final overCap = find.byKey(const Key('scent_tile_5'));
      await tester.ensureVisible(overCap);
      await tester.pumpAndSettle();
      await tester.tap(overCap);
      await tester.pump();
      expect(_counterText(tester), '4/4');
      // Toggle tile 1 off → counter drops, deselect always allowed.
      final first = find.byKey(const Key('scent_tile_1'));
      await tester.ensureVisible(first);
      await tester.pumpAndSettle();
      await tester.tap(first);
      await tester.pump();
      expect(_counterText(tester), '3/4');
      expect(tester.takeException(), isNull);
    });
  });
}
