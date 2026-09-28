import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/home_screen.dart';
import 'package:inea_scents_client/widgets/index.dart';

/// C99: Home asymmetric Upcoming hero + How-it-works rail — 3/4 hero +
/// 1/4 rail at equal height on wide, stacked concierge order on mobile.
GoRouter _homeRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/packages',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );
}

Widget _harness(GoRouter router) {
  return ProviderScope(
    overrides: [bookingsProvider.overrideWith((ref) async => [])],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pumpAtSize(
  WidgetTester tester,
  GoRouter router,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(_harness(router));
  await tester.pumpAndSettle();
}

void main() {
  group('c99 home hero rail', () {
    testWidgets('wide (1280): 3/4 hero + 1/4 rail, equal height',
        (WidgetTester tester) async {
      final router = _homeRouter();
      addTearDown(router.dispose);
      await _pumpAtSize(tester, router, const Size(1280, 800));

      expect(find.byKey(const Key('home_two_col')), findsOneWidget);
      final row = find.byKey(const Key('home_two_col'));
      // 3:1 split reads off the Row's direct children (step rows carry
      // their own flex-1 Expandeds deeper in the tree).
      final rowWidget = tester.widget<Row>(row);
      expect(
        rowWidget.children.whereType<Expanded>().map((e) => e.flex).toList(),
        [3, 1],
      );
      final hero = find.descendant(
        of: row,
        matching: find.byWidgetPredicate(
          (w) => w is Expanded && w.flex == 3,
        ),
      );
      final strip = find.byKey(const Key('home_how_it_works'));
      final rail = find.ancestor(
        of: strip,
        matching: find.byWidgetPredicate(
          (w) => w is Expanded && w.flex == 1,
        ),
      );
      expect(hero, findsOneWidget);
      expect(rail, findsOneWidget);

      // Hero left of rail, widths at the 3:1 ratio.
      expect(tester.getCenter(hero).dx < tester.getCenter(rail).dx, isTrue);
      final heroWidth = tester.getSize(hero).width;
      final railWidth = tester.getSize(rail).width;
      expect(railWidth / heroWidth, closeTo(1 / 3, 0.02));

      // Equal height: the hero card and the strip card share the row
      // height (stretch + slot fill), not just their slots.
      final heroCard = find.descendant(
        of: hero,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.key == null &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).borderRadius ==
                  BorderRadius.circular(24),
        ),
      );
      expect(heroCard, findsOneWidget);
      expect(
        tester.getSize(heroCard).height,
        tester.getSize(strip).height,
      );

      // Rail carries the How-it-works strip; next step + teaser sit
      // full-width below the row.
      expect(
        find.descendant(
          of: rail,
          matching: find.byKey(const Key('home_how_it_works')),
        ),
        findsOneWidget,
      );
      final rowBottom =
          tester.getBottomLeft(find.byKey(const Key('home_two_col'))).dy;
      expect(find.byKey(const Key('home_next_step_card')), findsOneWidget);
      expect(
        tester.getCenter(find.byKey(const Key('home_next_step_card'))).dy >
            rowBottom,
        isTrue,
      );
      expect(
        tester.getCenter(find.byKey(const Key('home_offering_teaser'))).dy >
            rowBottom,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile (390): stacked order, no hero-rail split',
        (WidgetTester tester) async {
      final router = _homeRouter();
      addTearDown(router.dispose);
      await _pumpAtSize(tester, router, const Size(390, 844));

      expect(find.byKey(const Key('home_stacked')), findsOneWidget);
      expect(find.byKey(const Key('home_two_col')), findsNothing);
      // No 3/4 hero anywhere at mobile width.
      expect(
        find.byWidgetPredicate((w) => w is Expanded && w.flex == 3),
        findsNothing,
      );

      // Concierge order: upcoming, next step, teaser, strip.
      double dy(Finder f) => tester.getCenter(f).dy;
      expect(
        dy(find.byType(UpcomingBookingSection)) <
            dy(find.byKey(const Key('home_next_step_card'))),
        isTrue,
      );
      expect(
        dy(find.byKey(const Key('home_next_step_card'))) <
            dy(find.byKey(const Key('home_offering_teaser'))),
        isTrue,
      );
      expect(
        dy(find.byKey(const Key('home_offering_teaser'))) <
            dy(find.byKey(const Key('home_how_it_works'))),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
