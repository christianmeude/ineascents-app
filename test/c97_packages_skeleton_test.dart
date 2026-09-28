import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/widgets/index.dart';
import 'package:shimmer/shimmer.dart';

/// C97: packages skeleton hero rounding + Collections header to script —
/// the hero thumb must be clipped to the left edge inside a both-edges
/// rounded shell (mirroring PackageOfferingHero), and the loading state
/// must tease the Collections header in Great Vibes like the real TabHeader.
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

  testWidgets('hero shell rounded both edges, thumb clipped left only',
      (WidgetTester tester) async {
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

  testWidgets('loading teases Collections header in Great Vibes script',
      (WidgetTester tester) async {
    await pumpSkeleton(tester);

    expect(
        find.byKey(const Key('skeleton_collections_header')), findsOneWidget);
    final title = find.descendant(
      of: find.byKey(const Key('skeleton_collections_header')),
      matching: find.text('Our Collections'),
    );
    expect(title, findsOneWidget);

    final style = tester.widget<Text>(title).style!;
    expect(style.fontFamilyFallback, contains('Great Vibes'));
    expect(style.fontWeight, FontWeight.w400);

    // Header tease sits above the hero mirror.
    expect(
      tester.getCenter(title).dy <
          tester.getCenter(find.byKey(const Key('skeleton_offering_hero'))).dy,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('single-parent Shimmer invariant holds',
      (WidgetTester tester) async {
    await pumpSkeleton(tester);

    expect(find.byType(Shimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
