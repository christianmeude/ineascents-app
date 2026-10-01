import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/widgets/index.dart';

/// C158: mobile swipe between the 5 tab roots; wizard stays buttons-only.
GoRouter _c158Router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ResponsiveAppShell(
          navigationShell: shell,
          child: const SizedBox.shrink(),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Text('Home root'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/packages',
                builder: (context, state) => const Text('Packages root'),
              ),
              GoRoute(
                path: '/booking/1',
                builder: (context, state) => const Text('Booking wizard'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const Text('Bookings root'),
              ),
              GoRoute(
                path: '/bookings/1',
                builder: (context, state) => const Text('Booking detail'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const Text('Calendar root'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const Text('Profile root'),
              ),
              GoRoute(
                path: '/profile/password',
                builder: (context, state) => const Text('Password sub-route'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpMobile(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('C158 tab swipe', () {
    testWidgets('swipe left on root changes branch + bar syncs', (
      WidgetTester tester,
    ) async {
      final router = _c158Router();
      addTearDown(router.dispose);
      await _pumpMobile(tester, router);
      expect(find.text('Home root'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);

      // Swipe left (content drags left) -> next tab (packages).
      await tester.fling(
        find.byType(PageView),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Packages root'), findsOneWidget);
      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bar tap syncs PageView back (both directions)', (
      WidgetTester tester,
    ) async {
      final router = _c158Router();
      addTearDown(router.dispose);
      await _pumpMobile(tester, router);

      await tester.tap(find.text('CALENDAR'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar root'), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        3,
      );

      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller;
      expect(controller?.page?.round(), 3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('detail/sub-routes have no PageView (wizard buttons-only)', (
      WidgetTester tester,
    ) async {
      final router = _c158Router();
      addTearDown(router.dispose);
      await _pumpMobile(tester, router);

      router.go('/booking/1');
      await tester.pumpAndSettle();
      expect(find.text('Booking wizard'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      router.go('/bookings/1');
      await tester.pumpAndSettle();
      expect(find.text('Booking detail'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      router.go('/profile/password');
      await tester.pumpAndSettle();
      expect(find.text('Password sub-route'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop keeps indexedStack, no swipe PageView', (
      WidgetTester tester,
    ) async {
      final router = _c158Router();
      addTearDown(router.dispose);
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home root'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
