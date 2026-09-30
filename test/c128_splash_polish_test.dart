import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/splash_screen.dart';
import 'package:inea_scents_client/widgets/app_logo.dart';

/// C128: splash polish — brand + tagline render, decorative background
/// stays out of semantics, reduced motion jumps to the end state.
///
/// NOTE: never advance fake async past 3s here — the splash routes to
/// /login via GoRouter, which is out of scope for these widget pumps.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSplash(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(
          path: '/login',
          builder: (_, __) =>
              const Scaffold(body: Text('login stub')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(disableAnimations: disableAnimations),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  /// Drains the 3s auto-navigation timer so teardown sees no pending
  /// timers; lands on the login stub.
  Future<void> drainNavigation(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('login stub'), findsOneWidget);
  }

  testWidgets('brand wordmark and tagline render', (
    WidgetTester tester,
  ) async {
    await pumpSplash(tester);

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Bespoke scent experiences'), findsOneWidget);
    await drainNavigation(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('background gradient is excluded from semantics', (
    WidgetTester tester,
  ) async {
    await pumpSplash(tester);

    expect(
      find.ancestor(
        of: find.byType(DecoratedBox),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    await drainNavigation(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion jumps to the end state', (
    WidgetTester tester,
  ) async {
    await pumpSplash(tester, disableAnimations: true);

    // Tagline fade completes instantly instead of playing 2.2s.
    // (Innermost FadeTransition: the tagline sits inside the brand fade.)
    final taglineFade = find
        .ancestor(
          of: find.text('Bespoke scent experiences'),
          matching: find.byType(FadeTransition),
        )
        .evaluate()
        .last
        .widget as FadeTransition;
    expect(taglineFade.opacity.value, 1.0);
    await drainNavigation(tester);
    expect(tester.takeException(), isNull);
  });
}
