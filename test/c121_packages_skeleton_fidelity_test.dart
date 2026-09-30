import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/packages_screen.dart';
import 'package:inea_scents_client/widgets/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// C121: packages skeleton fidelity — the loading mirror must match the
/// loaded screen within 24px per component, or the crossfade jumps.
/// Regression: skeleton hardcoded 3 rows (real offering carries 4 Pax
/// tiers) and never mirrored the desktop 2-column grid.
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

  Future<void> pumpReal(WidgetTester tester, Size size) async {
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
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PackagesScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpMirror(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(child: SkeletonPackagesLoading()),
        ),
      ),
    );
    await tester.pump();
  }

  double componentHeight(
      WidgetTester tester, Finder finder, String label) {
    expect(finder, findsOneWidget, reason: label);
    return tester.getSize(finder).height;
  }

  group('packages skeleton fidelity (<=24px per component)', () {
    for (final size in [const Size(360, 800), const Size(1200, 800)]) {
      testWidgets('matches at ${size.width.toInt()}px', (
        WidgetTester tester,
      ) async {
        await pumpReal(tester, size);
        final heroH =
            componentHeight(tester, find.byKey(const Key('offering_hero')), 'hero');
        final rowH = componentHeight(
            tester, find.byKey(const Key('pax_choice_50')), 'row');
        final headerH = componentHeight(
            tester, find.byType(TabHeader).first, 'header');

        await pumpMirror(tester, size);
        final mirrorHeroH = componentHeight(
            tester, find.byKey(const Key('skeleton_offering_hero')), 'mirror hero');
        final mirrorRowH = componentHeight(
            tester, find.byKey(const Key('skeleton_pax_row_0')), 'mirror row');
        final mirrorHeaderH = componentHeight(
            tester, find.byType(TabHeader).first, 'mirror header');

        expect(mirrorHeroH, moreOrLessEquals(heroH, epsilon: 24),
            reason: 'hero $heroH vs $mirrorHeroH @${size.width}');
        expect(mirrorRowH, moreOrLessEquals(rowH, epsilon: 24),
            reason: 'row $rowH vs $mirrorRowH @${size.width}');
        expect(mirrorHeaderH, moreOrLessEquals(headerH, epsilon: 24),
            reason: 'header $headerH vs $mirrorHeaderH @${size.width}');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('mirror renders 4 rows in desktop grid', (
      WidgetTester tester,
    ) async {
      const size = Size(1200, 800);
      await pumpMirror(tester, size);

      expect(find.byType(GridView), findsOneWidget);
      for (int i = 0; i < 4; i++) {
        expect(find.byKey(Key('skeleton_pax_row_$i')), findsOneWidget,
            reason: 'row $i');
      }
      expect(tester.takeException(), isNull);
    });
  });
}
