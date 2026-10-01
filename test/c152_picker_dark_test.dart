import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/config/theme.dart';

// C152: schedule time picker renders dark tokens — zero light fields.
void main() {
  group('C152 schedule time picker dark theme', () {
    test('darkTheme carries night time-picker tokens', () {
      final t = AppTheme.darkTheme.timePickerTheme;
      expect(t.backgroundColor, AppTheme.nightSurface);
      expect(t.dialBackgroundColor, AppTheme.night);
      expect(t.hourMinuteColor, AppTheme.night);
      // The framework wraps plain day-period fills: selected → fill,
      // unselected → transparent (dialog shows through).
      expect(
        (t.dayPeriodColor! as WidgetStateColor).resolve({
          WidgetState.selected,
        }),
        AppTheme.night,
      );
      expect(t.hourMinuteTextColor, const Color(0xFFFDF4F5));
      expect(t.dayPeriodTextColor, const Color(0xFFFDF4F5));
      expect(t.dialTextColor, const Color(0xFFFDF4F5));
      expect(t.entryModeIconColor, const Color(0xFFFDF4F5));
    });

    test('zero light fills in the picker path', () {
      const cream = Color(0xFFFDF4F5);
      final t = AppTheme.darkTimePickerTheme;
      for (final fill in [
        t.backgroundColor,
        t.dialBackgroundColor,
        t.hourMinuteColor,
        t.dayPeriodColor,
      ]) {
        expect(fill, isNot(equals(cream)));
      }
    });

    test('light theme untouched', () {
      expect(
        AppTheme.lightTheme.timePickerTheme,
        const TimePickerThemeData(),
      );
    });

    testWidgets('builder forces dark tokens in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => AppTheme.darkTimePickerBuilder(
              context,
              const Text('picker'),
            ),
          ),
        ),
      );
      await tester.pump();
      // Nearest Theme above the child is the builder's forced-dark one
      // (the app-level Theme sits further up).
      final pickerCtx = tester.element(find.text('picker'));
      final forced = Theme.of(pickerCtx);
      expect(forced.timePickerTheme.backgroundColor, AppTheme.nightSurface);
      expect(forced.colorScheme.brightness, Brightness.dark);
    });

    testWidgets('builder passes through in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => AppTheme.darkTimePickerBuilder(
              context,
              const Text('picker'),
            ),
          ),
        ),
      );
      await tester.pump();
      final pickerCtx = tester.element(find.text('picker'));
      expect(
        Theme.of(pickerCtx).timePickerTheme.backgroundColor,
        isNull,
      );
    });

    testWidgets('dark picker dialog inherits night tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 14, minute: 0),
                builder: AppTheme.darkTimePickerBuilder,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      final dialogCtx = tester.element(find.byType(TimePickerDialog));
      expect(
        Theme.of(dialogCtx).timePickerTheme.backgroundColor,
        AppTheme.nightSurface,
      );
    });
  });
}
