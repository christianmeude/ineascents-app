import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/packages_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// C17: Packages shows one Offering hero + 4 Pax Choice rows; tapping a
/// row pushes the C144 Pax Choice detail (`/packages/:id?pax=&date=`).
Package _offering() => const Package(
  id: 1,
  name: 'Essential 10ml Perfume Bar',
  description: 'A signature scent experience for your celebration.',
  price: 4499,
  paxOptions: [50, 70, 100, 150],
  paxPrices: {50: 4499.0, 70: 6399.0, 100: 8799.0, 150: 13119.0},
  inclusions: ['2-hour perfume bar', 'On-site scent concierge'],
  freebies: ['Keepsake atomizer'],
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  GoRouter buildRouter(StringBuffer seen, {DateTime? initialDate}) {
    return GoRouter(
      initialLocation: '/packages',
      routes: [
        GoRoute(
          path: '/packages',
          builder: (context, state) =>
              PackagesScreen(initialDate: initialDate),
        ),
        GoRoute(
          path: '/packages/:id',
          builder: (context, state) {
            seen.write(
              "id=${state.pathParameters['id']}"
              "&pax=${state.queryParameters['pax']}"
              "&date=${state.queryParameters['date']}",
            );
            return const Text('Pax Choice Detail Page');
          },
        ),
      ],
    );
  }

  Future<void> pumpPackages(
    WidgetTester tester,
    GoRouter router, {
    Size size = const Size(390, 844),
  }) async {
    SharedPreferences.setMockInitialValues({'first_launch': false});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packagesProvider.overrideWith((ref) async => [_offering()]),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exactly 1 hero plus 4 Pax Choice rows', (
    WidgetTester tester,
  ) async {
    await pumpPackages(tester, buildRouter(StringBuffer()));

    expect(find.byKey(const Key('offering_hero')), findsOneWidget);
    expect(find.text('Essential 10ml Perfume Bar'), findsOneWidget);
    expect(find.text('Starting at ₱4,499.00'), findsOneWidget);
    expect(find.textContaining('2-hour perfume bar'), findsOneWidget);
    expect(find.text('Choose your Pax Choice'), findsOneWidget);
    for (final pax in [50, 70, 100, 150]) {
      expect(find.byKey(Key('pax_choice_$pax')), findsOneWidget);
      expect(find.text('$pax Pax Choice'), findsOneWidget);
    }
  });

  testWidgets('tap Pax row pushes /packages/:id with pax prefilled', (
    WidgetTester tester,
  ) async {
    final seen = StringBuffer();
    await pumpPackages(
      tester,
      buildRouter(seen, initialDate: DateTime(2026, 10, 3)),
    );

    await tester.tap(find.text('70 Pax Choice'));
    await tester.pumpAndSettle();

    expect(find.text('Pax Choice Detail Page'), findsOneWidget);
    expect(seen.toString(), 'id=1&pax=70&date=2026-10-03');
  });
}
