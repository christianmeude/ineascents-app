import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/calendar_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_api.dart';

/// C122: calendar skeleton fidelity — the grid pitch must equal
/// TableCalendar's 52px rows, or every month boundary jumps on load.
/// Regression: skeleton drew 36px cells + 10px gaps (46px pitch),
/// drifting 6px per row against the real 52px grid.
///
/// NOTE: real-vs-mirror comparison runs at 390px because the REAL
/// IneaCalendar overflows at 360px (fixed 44px today/selected rings in
/// 42px columns — filed as C123). The skeleton itself is clean at 360.
class _CannedAvailability extends AvailabilityNotifier {
  _CannedAvailability(this.canned);

  final AvailabilityState canned;

  @override
  Future<AvailabilityState> build() async => canned;
}

AvailabilityState _cannedCurrentMonth() {
  final now = DateTime.now();
  return AvailabilityState(
    month: now.month,
    year: now.year,
    data: [
      for (int d = 1; d <= 10; d++)
        GetApiAvailabilityResponse(
          date: DateTime(now.year, now.month, d),
          status: 'Available',
        ),
    ],
  );
}

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
          apiClientProvider.overrideWithValue(
            buildFakeRestClient(FakeApiBackend()),
          ),
          availabilityProvider
              .overrideWith(() => _CannedAvailability(_cannedCurrentMonth())),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
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
          body: SingleChildScrollView(child: SkeletonCalendar()),
        ),
      ),
    );
    await tester.pump();
  }

  group('calendar skeleton fidelity', () {
    testWidgets('grid pitch is 52px like TableCalendar rowHeight', (
      WidgetTester tester,
    ) async {
      await pumpMirror(tester, const Size(360, 800));

      // Same weekday, adjacent rows: day 1 vs day 8 (when both exist).
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      if (daysInMonth < 8) {
        markTestSkipped('short month');
        return;
      }
      final a =
          tester.getTopLeft(find.byKey(const Key('skeleton_day_cell_1')));
      final b =
          tester.getTopLeft(find.byKey(const Key('skeleton_day_cell_8')));
      expect(b.dy - a.dy, moreOrLessEquals(52, epsilon: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('weekday header fits 22px like daysOfWeekHeight', (
      WidgetTester tester,
    ) async {
      await pumpMirror(tester, const Size(360, 800));

      final h =
          tester.getSize(find.byKey(const Key('skeleton_weekday_header')));
      expect(h.height, lessThanOrEqualTo(22),
          reason: 'weekday row height ${h.height}');
      expect(tester.takeException(), isNull);
    });

    // Real-vs-mirror at 390px+: the real IneaCalendar overflows at 360px
    // (fixed 44px rings in 42px columns — C123), so 360 would measure
    // the bug, not the mirror.
    for (final size in [const Size(390, 844), const Size(1200, 800)]) {
      testWidgets('card vs IneaCalendar within 40px at ${size.width.toInt()}px',
          (WidgetTester tester) async {
        await pumpReal(tester, size);
        final realH =
            tester.getSize(find.byType(IneaCalendar).first).height;

        await pumpMirror(tester, size);
        final mirrorH = tester
            .getSize(find.byKey(const Key('skeleton_calendar_card')))
            .height;

        // Skeleton card carries its own 28px pads; grid areas must agree.
        expect((mirrorH - realH).abs(), lessThanOrEqualTo(40),
            reason: 'card $mirrorH vs grid $realH @${size.width}');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('agenda mirror matches empty text height', (
      WidgetTester tester,
    ) async {
      await pumpReal(tester, const Size(390, 844));
      final realH =
          tester.getSize(find.text('Select a date to see details.')).height;

      await pumpMirror(tester, const Size(360, 800));
      final mirrorH =
          tester.getSize(find.byKey(const Key('skeleton_agenda'))).height;

      expect((mirrorH - realH).abs(), lessThanOrEqualTo(24),
          reason: 'agenda $mirrorH vs $realH');
      expect(tester.takeException(), isNull);
    });
  });
}
