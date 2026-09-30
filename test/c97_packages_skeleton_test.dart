import 'dart:async';

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
import 'package:shimmer/shimmer.dart';

/// C97: packages skeleton hero rounding (C124: skeleton-exclusive — the
/// loading state renders shimmer bars only, zero header texts).
/// The hero thumb must be clipped to the left edge inside a both-edges
/// rounded shell (mirroring PackageOfferingHero).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSkeleton(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: SkeletonPackagesLoading()),
      ),
    );
    await tester.pump();
  }

  testWidgets('hero shell rounded both edges, thumb clipped left only', (
    WidgetTester tester,
  ) async {
    await pumpSkeleton(tester);

    final hero = find.byKey(const Key('skeleton_offering_hero'));
    expect(hero, findsOneWidget);

    // Outer shell: circular(20) on both edges, like the real hero.
    final shellBox =
        tester.widget<Container>(hero).decoration! as BoxDecoration;
    expect(shellBox.borderRadius, BorderRadius.circular(20));

    // Thumb: clipped topLeft + bottomLeft 20, mirroring the real hero —
    // square image corners never poke past the shell rounding.
    final thumbClip = find.descendant(
      of: hero,
      matching: find.byWidgetPredicate(
        (w) =>
            w is ClipRRect &&
            w.borderRadius ==
                const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
      ),
    );
    expect(thumbClip, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading shows skeleton-only, zero header texts', (
    WidgetTester tester,
  ) async {
    await pumpSkeleton(tester);

    expect(
      find.byKey(const Key('skeleton_collections_header')),
      findsOneWidget,
    );
    // C124: skeleton-exclusive — no texts while loading.
    expect(find.text('Our Collections'), findsNothing);
    expect(find.text('Discover your perfect scent.'), findsNothing);

    // Placeholder bars sit above the hero mirror.
    expect(
      tester
              .getCenter(find.byKey(const Key('skeleton_collections_header')))
              .dy <
          tester.getCenter(find.byKey(const Key('skeleton_offering_hero'))).dy,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('single-parent Shimmer invariant holds', (
    WidgetTester tester,
  ) async {
    await pumpSkeleton(tester);

    expect(find.byType(Shimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PackagesScreen hides header texts while initial loading', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'first_launch': false});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packagesProvider.overrideWith(
            (ref) => Completer<List<Package>>().future,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PackagesScreen(),
        ),
      ),
    );
    await tester.pump();

    // C124: skeleton-exclusive — shimmer only, zero texts.
    expect(find.text('Our Collections'), findsNothing);
    expect(find.text('Discover your perfect scent.'), findsNothing);
    expect(find.byKey(const Key('skeleton_packages_loading')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
