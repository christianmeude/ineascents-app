import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/widgets/index.dart';
import 'package:shimmer/shimmer.dart';

/// C126: uniform muted skeleton tone — every loading skeleton resolves
/// base/highlight through SkeletonShimmer, so no screen drifts loud or
/// divergent again (regression: 5 call sites duplicated 4 hexes, upcoming
/// diverged on both tokens).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('muted tokens are fixed per brightness', () {
    expect(SkeletonShimmer.baseFor(Brightness.light), const Color(0xFFC2B3B9));
    expect(
      SkeletonShimmer.highlightFor(Brightness.light),
      const Color(0xFFE4D9DE),
    );
    expect(SkeletonShimmer.baseFor(Brightness.dark), const Color(0xFF2B2126));
    expect(
      SkeletonShimmer.highlightFor(Brightness.dark),
      const Color(0xFF453540),
    );
  });

  Future<void> pumpSkeleton(
    WidgetTester tester,
    Widget skeleton,
    ThemeData theme,
  ) async {
    // Tall surface: the booking-flow mirror (~2000px) must fit without
    // overflow, and Expanded children demand finite constraints.
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: theme, home: Scaffold(body: skeleton)),
    );
    await tester.pump();
  }

  Color resolvedBase(WidgetTester tester) =>
      SkeletonShimmer.baseOf(tester.element(find.byType(SkeletonShimmer)));
  Color resolvedHighlight(WidgetTester tester) =>
      SkeletonShimmer.highlightOf(tester.element(find.byType(SkeletonShimmer)));

  // Shared-wrapper skeletons (upcoming-loading + calendar-header bars are
  // plain Containers inside the same SkeletonShimmer — covered by
  // construction, not pumpable: both widgets are private/inline).
  group('shared-wrapper skeletons use one muted tone', () {
    final skeletons = <String, Widget>{
      'package-card': const SkeletonPackageCard(),
      'packages': const SkeletonPackagesLoading(),
      'calendar': const SkeletonCalendar(),
      'bookings': const SkeletonBookingsList(),
      'flow': const SkeletonBookingFlow(),
    };
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final theme = brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
      for (final entry in skeletons.entries) {
        testWidgets('${entry.key} uses muted uniform tone ($brightness)', (
          WidgetTester tester,
        ) async {
          await pumpSkeleton(tester, entry.value, theme);
          // One shared wrapper, one parent Shimmer (C84 invariant).
          expect(find.byType(SkeletonShimmer), findsOneWidget);
          expect(find.byType(Shimmer), findsOneWidget);
          expect(resolvedBase(tester), SkeletonShimmer.baseFor(brightness));
          expect(
            resolvedHighlight(tester),
            SkeletonShimmer.highlightFor(brightness),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
