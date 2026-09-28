import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/home_screen.dart';
import 'package:inea_scents_client/widgets/index.dart';

/// C26: Home spacing polish — One Booking subtitle gone, 16px card rhythm,
/// 20px screen edge padding at 360/768/1200px.
/// C42: mobile logo row retired (brand lives in TopNavBar); unified
/// TabHeader (`Home` + count) tops the stack, trailing slot empty.
GoRouter _router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  );
}

Future<void> _pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = _router();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bookingsProvider.overrideWith((ref) async => [])],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('c26 home spacing polish', () {
    for (final width in [360.0, 768.0, 1200.0]) {
      testWidgets('w${width.toInt()}: header, no logo, 16px rhythm, 20px edges',
          (WidgetTester tester) async {
        await _pumpAt(tester, width);
        expect(tester.takeException(), isNull);

        // C26: subtitle gone.
        expect(find.byKey(const Key('home_trust_copy')), findsNothing);
        expect(find.textContaining('One Booking'), findsNothing);

        // C42: unified header on top, mobile logo row retired.
        expect(find.byType(TabHeader), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(AppLogo), findsNothing);

        // C91: 16px card rhythm — mobile stacks Upcoming/NextStep/
        // teaser (2 gaps) plus the strip gap (1) = 3; wide pairs
        // NextStep/teaser in col 2 (1 gap) plus the strip gap (1) = 2.
        final gaps = tester
            .widgetList<SizedBox>(find.byWidgetPredicate(
              (w) => w is SizedBox && w.height == 16 && w.width == null,
            ))
            .length;
        expect(gaps, width < 768 ? 3 : 2);

        // C26/C72: 20px screen edges — header carries the shared token
        // (fromLTRB 20,18,20,0: 20px edges, 18 top), cards keep
        // symmetric horizontal 20.
        final headerPaddings = tester
            .widgetList<Padding>(find.byWidgetPredicate(
              (w) =>
                  w is Padding &&
                  w.padding ==
                      ResponsiveAppShell.screenHeaderPadding
                          .copyWith(bottom: 0),
            ))
            .toList();
        expect(headerPaddings.length, 1);
        final headerInsets = headerPaddings.single.padding as EdgeInsets;
        expect(headerInsets.left, 20);
        expect(headerInsets.right, 20);
        expect(headerInsets.top, 18);
        expect(headerInsets.bottom, 0);

        // C91: body + How-it-works strip keep symmetric horizontal 20.
        // C99: strip folded into the body pad (rail on wide, stack on
        // mobile) — one padded block, edges still 20px.
        final edges = tester
            .widgetList<Padding>(find.byWidgetPredicate(
              (w) =>
                  w is Padding &&
                  w.padding == const EdgeInsets.symmetric(horizontal: 20),
            ))
            .length;
        expect(edges, 1);
      });
    }
  });
}
