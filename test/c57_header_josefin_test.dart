import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/widgets/index.dart';

/// C57: brand/logo text renders Josefin Sans (web + mobile) with the
/// single-source offline-safe fallback stack (C73: tab titles moved
/// to Great Vibes with their own script-first stack).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c57 header Josefin Sans', () {
    testWidgets('TabHeader title renders Great Vibes family', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TabHeader(title: 'My Bookings', count: 'C')),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final style = tester.widget<Text>(find.text('My Bookings')).style!;
      // google_fonts names the family 'GreatVibes' at runtime;
      // the human-readable 'Great Vibes' leads the fallback stack.
      expect(style.fontFamily, contains('GreatVibes'));
      expect(style.fontFamilyFallback, TabHeader.titleFallback);
      expect(style.fontFamilyFallback!.first, 'Great Vibes');
      // C127: owner-directed bolden — w700 faux-bold on the script
      // (was w400; the family ships Regular 400 only).
      expect(style.fontWeight, FontWeight.w700);
    });

    testWidgets('TopNavBar brand INEA renders Josefin Sans family', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const TopNavBar()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final style = tester.widget<Text>(find.text('INEA')).style!;
      expect(style.fontFamily, contains('JosefinSans'));
      expect(style.fontFamilyFallback, AppTheme.brandFontFallback);
      expect(style.fontWeight, FontWeight.w700);
      // Light mode: white brand on plum nav.
      expect(style.color, Colors.white);
    });

    testWidgets('TopNavBar brand holds Josefin Sans in dark mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.darkTheme, home: const TopNavBar()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final style = tester.widget<Text>(find.text('INEA')).style!;
      expect(style.fontFamily, contains('JosefinSans'));
      expect(style.color, Colors.white);
    });

    testWidgets('AppLogo INEA renders Josefin Sans family', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const AppLogo()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final inea = tester.widgetList<Text>(find.text('INEA'));
      expect(inea, isNotEmpty);
      for (final t in inea) {
        expect(t.style?.fontFamily, contains('JosefinSans'));
        expect(t.style?.fontFamilyFallback, AppTheme.brandFontFallback);
      }
    });

    test('brand fallback stack is Josefin-first, offline-safe', () {
      expect(AppTheme.brandFontFallback.first, 'Josefin Sans');
      expect(AppTheme.brandFontFallback, contains('sans-serif'));
      // C73: tab titles split off to a Great-Vibes-first stack;
      // the brand stack stays Josefin-first for the INEA logo.
      expect(TabHeader.titleFallback.first, 'Great Vibes');
    });
  });
}
