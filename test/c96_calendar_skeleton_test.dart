import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/widgets/index.dart';

/// C96: calendar skeleton fidelity — the skeleton must mirror the real
/// month-grid card + details-pane at 360px (stacked) and desktop (7:4 Row).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSkeleton(
    WidgetTester tester, {
    required double width,
    required double height,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(child: SkeletonCalendar()),
        ),
      ),
    );
    await tester.pump();
  }

  double topCenter(WidgetTester tester, Finder finder) =>
      tester.getCenter(finder).dy;

  testWidgets('360px stacks month-grid card above details-pane',
      (WidgetTester tester) async {
    await pumpSkeleton(tester, width: 360, height: 800);

    final card = find.descendant(
      of: find.byKey(const Key('skeleton_calendar')),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(24),
      ),
    );
    expect(card, findsOneWidget);
    expect(find.byKey(const Key('skeleton_agenda')), findsOneWidget);

    // Stacked: card fully above agenda, no side-by-side 7:4 Row.
    final cardBox = topCenter(tester, card);
    final agendaBox = topCenter(tester, find.byKey(const Key('skeleton_agenda')));
    expect(cardBox < agendaBox, isTrue);
    expect(
      tester.getBottomLeft(card).dy <=
          tester.getTopLeft(find.byKey(const Key('skeleton_agenda'))).dy,
      isTrue,
    );
    // No desktop 7:4 split at mobile width (the month-nav's own flex-1
    // Expanded is chrome, not the split).
    expect(
      find.byWidgetPredicate((w) => w is Expanded && w.flex == 7),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate((w) => w is Expanded && w.flex == 4),
      findsNothing,
    );
    // Month-grid chrome present at mobile width too.
    expect(find.byKey(const Key('skeleton_month_nav')), findsOneWidget);
    expect(find.byKey(const Key('skeleton_weekday_header')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop lays month-grid and details-pane 7:4 side by side',
      (WidgetTester tester) async {
    await pumpSkeleton(tester, width: 1200, height: 800);

    // 7:4 Row mirror of the real screen (flex 7 card, gap 24, flex 4 agenda).
    final flex7 = find.byWidgetPredicate(
      (w) => w is Expanded && w.flex == 7,
    );
    final flex4 = find.byWidgetPredicate(
      (w) => w is Expanded && w.flex == 4,
    );
    expect(flex7, findsOneWidget);
    expect(flex4, findsOneWidget);

    // Side by side in one Row band: agenda right of the card with the
    // production 24px gap, widths at the 7:4 ratio.
    final cardLeft = tester.getTopLeft(flex7).dx;
    final cardRight = tester.getTopRight(flex7).dx;
    final agendaLeft = tester.getTopLeft(flex4).dx;
    expect(agendaLeft > cardLeft, isTrue);
    expect(agendaLeft - cardRight, 24);
    final cardWidth = tester.getSize(flex7).width;
    final agendaWidth = tester.getSize(flex4).width;
    expect(agendaWidth / cardWidth, closeTo(4 / 7, 0.01));
    // Same Row band: vertical centers overlap.
    final cardCenter = tester.getCenter(flex7).dy;
    final agendaCenter = tester.getCenter(flex4).dy;
    expect(
      (agendaCenter - cardCenter).abs() < tester.getSize(flex7).height / 2,
      isTrue,
    );

    // Grid + agenda chrome still present at desktop width.
    expect(find.byKey(const Key('skeleton_month_nav')), findsOneWidget);
    expect(find.byKey(const Key('skeleton_weekday_header')), findsOneWidget);
    expect(find.byKey(const Key('skeleton_agenda')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
