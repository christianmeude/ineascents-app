import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/scents.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/booking_screen.dart';
import 'package:inea_scents_client/screens/package_detail_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

/// C144: Pax Choice detail + Scent shelf — grouped Women 4 / Men 4 with an
/// n/4 counter capped at 4, CTA into the booking flow, and read-only
/// Scent chips in the Schedule stage (no editing there).
Package _c144Package() => const Package(
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

ProviderContainer _c144Container() {
  return ProviderContainer(
    overrides: [
      packageDetailsProvider(1).overrideWith((ref) => _c144Package()),
      apiClientProvider.overrideWithValue(
        buildFakeRestClient(FakeApiBackend()),
      ),
    ],
  );
}

Future<void> _pumpDetail(
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

GoRouter _detailRouter({required void Function(String) onBook}) {
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
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          onBook(
            'id=${state.pathParameters['id']}'
            '&pax=${state.queryParameters['pax']}',
          );
          return const Text('Booking Screen Page');
        },
      ),
    ],
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c144 shelf catalog', () {
    test('bundle fallback groups Women 4 / Men 4', () {
      final groups = groupScentChoices(null);
      expect(groups['Women']!.length, 4);
      expect(groups['Men']!.length, 4);
      expect(
        groups['Women']!.map((c) => c.asset),
        everyElement(startsWith('assets/images/scents/')),
      );
    });

    test('API names win, bundle supplies category + asset', () {
      const api = [
        Scent(id: 11, name: 'Ariana Cloud'),
        Scent(id: 12, name: 'Creed Aventus'),
      ];
      final groups = groupScentChoices(api);
      final women = groups['Women']!;
      final men = groups['Men']!;
      expect(women.length, 1);
      expect(men.length, 1);
      expect(women.first.id, 11);
      expect(women.first.asset, 'assets/images/scents/ariana-cloud.png');
      expect(men.first.id, 12);
      expect(men.first.asset, 'assets/images/scents/creed-aventus.png');
    });

    test('counter label reads n/4 and gate caps at 4', () {
      expect(scentCounterLabel(0), '0/4');
      expect(scentCounterLabel(2), '2/4');
      expect(canSelectMoreScent([1, 2, 3, 4], 5), isFalse);
      expect(canSelectMoreScent([1, 2, 3, 4], 4), isTrue);
      expect(canSelectMoreScent([1], 2), isTrue);
    });
  });

  group('c144 provider cap', () {
    test('toggleScent keeps at most 4 ids', () {
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(
            buildFakeRestClient(FakeApiBackend()),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(bookingFlowProvider.notifier);
      for (var i = 1; i <= 5; i++) {
        notifier.toggleScent(i);
      }
      final selected = container.read(bookingFlowProvider).selectedScentIds;
      expect(selected.length, 4);
      expect(selected, containsAll([1, 2, 3, 4]));
      expect(selected, isNot(contains(5)));
      // Deselect still works at the cap.
      notifier.toggleScent(1);
      expect(
        container.read(bookingFlowProvider).selectedScentIds,
        isNot(contains(1)),
      );
    });
  });

  group('c144 detail screen', () {
    testWidgets('header + static lists + shelf + counter render', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c144Container();
      addTearDown(container.dispose);
      final router = _detailRouter(onBook: (_) {});
      addTearDown(router.dispose);
      await _pumpDetail(tester, container, router);

      expect(find.byKey(const Key('detail_pax_header')), findsOneWidget);
      expect(find.text('70 Pax Choice'), findsOneWidget);
      expect(find.text('Essential 10ml Scent Bar'), findsOneWidget);
      expect(find.byKey(const Key('detail_pax_price')), findsOneWidget);
      expect(find.text('Inclusions'), findsOneWidget);
      expect(find.text('Freebies'), findsOneWidget);
      expect(find.text('Choose your Scents'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Men'), findsOneWidget);
      expect(find.byKey(const Key('scent_counter')), findsOneWidget);
      expect(find.text('0/4'), findsOneWidget);
      expect(find.text('Book with these Scents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a 5th scent is refused (counter stays 4/4)', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c144Container();
      addTearDown(container.dispose);
      final router = _detailRouter(onBook: (_) {});
      addTearDown(router.dispose);
      await _pumpDetail(tester, container, router);

      for (final id in [1, 2, 3, 4]) {
        await tester.ensureVisible(find.byKey(Key('scent_tile_$id')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('scent_tile_$id')));
        await tester.pumpAndSettle();
      }
      expect(find.text('4/4'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('scent_tile_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scent_tile_5')));
      await tester.pumpAndSettle();

      expect(find.text('4/4'), findsOneWidget);
      expect(
        container.read(bookingFlowProvider).selectedScentIds.length,
        4,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA pushes booking with pax prefilled', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c144Container();
      addTearDown(container.dispose);
      String? booked;
      final router = _detailRouter(onBook: (seen) => booked = seen);
      addTearDown(router.dispose);
      await _pumpDetail(tester, container, router);

      await tester.ensureVisible(find.byKey(const Key('detail_book_cta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_book_cta')));
      await tester.pumpAndSettle();

      expect(find.text('Booking Screen Page'), findsOneWidget);
      expect(booked, 'id=1&pax=70');
      expect(container.read(bookingFlowProvider).selectedPax, 70);
    });
  });

  group('c144 schedule read-only chips', () {
    testWidgets('mobile schedule shows chips with no shelf editing', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c144Container();
      addTearDown(container.dispose);
      // Preselect two scents (as the detail shelf would).
      container.read(bookingFlowProvider.notifier).toggleScent(1);
      container.read(bookingFlowProvider.notifier).toggleScent(5);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResponsiveAppShell(
              child: BookingScreen(packageId: 1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('selected_scents_chips')), findsOneWidget);
      expect(find.byKey(const Key('selected_scent_chip_1')), findsOneWidget);
      expect(find.byKey(const Key('selected_scent_chip_5')), findsOneWidget);
      // No shelf editing in Schedule.
      expect(find.byKey(const Key('scent_tile_1')), findsNothing);
      expect(find.byKey(const Key('scent_counter')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty selection keeps schedule geometry (no chips)', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = _c144Container();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(1200, 650);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResponsiveAppShell(
              child: BookingScreen(packageId: 1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('schedule_datetime_card')), findsOneWidget);
      expect(find.byKey(const Key('selected_scents_chips')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
