import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/calendar_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_api.dart';

/// C123: 360px grid overflow guard — today + selected rings (44px per
/// C28) must render clean at the smallest supported width. Fails on
/// any overflow exception.
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
      for (int d = 1; d <= 31; d++)
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

  Future<void> pumpScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'first_launch': false});
    tester.view.physicalSize = const Size(360, 800);
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

  testWidgets('no overflow at 360px with today ring visible', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    // Today (current month canned) renders the today ring.
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 360px with selected ring visible', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    // Past days are disabled by design — select today (always enabled).
    await tester.tap(find.text('${DateTime.now().day}').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inea_selected_day')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
