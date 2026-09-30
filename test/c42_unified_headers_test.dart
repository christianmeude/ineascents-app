import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/calendar_screen.dart';
import 'package:inea_scents_client/screens/home_screen.dart';
import 'package:inea_scents_client/screens/my_bookings_screen.dart';
import 'package:inea_scents_client/screens/packages_screen.dart';
import 'package:inea_scents_client/screens/profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_api.dart';

/// C42: unified headers on the 5 tab screens (C41 spec, pairing B).
Booking _sampleBooking() => Booking(
  id: 1,
  bookingReference: 'IN-2026-000001',
  status: 'confirmed',
  pax: 50,
  eventDate: DateTime(2026, 10, 1),
  venueAddress: 'The Peninsula Manila',
);

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  List<Override> overrides, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.lightTheme, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c42 header order/slots per screen', () {
    final cases = <String, Widget Function()>{
      'Home': () => const HomeScreen(),
      'Packages': () => const PackagesScreen(),
      'Bookings': () => const MyBookingsScreen(),
      'Calendar': () => const CalendarScreen(),
      'Profile': () => const ProfileScreen(),
    };
    const titles = {
      'Home': 'Home',
      'Packages': 'Our Collections',
      'Bookings': 'My Bookings',
      'Calendar': 'Availability',
      'Profile': 'My Profile',
    };
    const counts = {
      'Home': 'Plan your scent experience.',
      'Packages': 'Discover your perfect scent.',
      'Bookings': '1 booking',
      'Calendar': 'Choose a date for your scent experience.',
      'Profile': 'Manage your account and preferences.',
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key}: title+count left, trailing empty', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({'first_launch': false});
        await _pump(tester, entry.value(), [
          apiClientProvider.overrideWithValue(
            buildFakeRestClient(FakeApiBackend()),
          ),
          bookingsProvider.overrideWith(
            (ref) => Future.value([_sampleBooking()]),
          ),
          packagesProvider.overrideWith((ref) async => []),
        ]);
        expect(tester.takeException(), isNull);

        // One shared header, no per-screen AppBar resurrection.
        expect(find.byType(TabHeader), findsOneWidget);
        expect(find.byType(AppBar), findsNothing);

        // Identical order: title above count.
        final title = titles[entry.key]!;
        final count = counts[entry.key]!;
        expect(find.text(title), findsOneWidget);
        expect(find.text(count), findsOneWidget);
        final titleDy = tester.getTopLeft(find.text(title)).dy;
        final countDy = tester.getTopLeft(find.text(count)).dy;
        expect(titleDy, lessThan(countDy));

        // Trailing slot empty: zero actions wired inside the header.
        final header = find.byType(TabHeader);
        expect(
          find.descendant(
            of: header,
            matching: find.byType(ButtonStyleButton),
          ),
          findsNothing,
        );
        expect(
          find.descendant(of: header, matching: find.byType(IconButton)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Bookings empty keeps header over the empty state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});
      await _pump(tester, const MyBookingsScreen(), [
        bookingsProvider.overrideWith((ref) => Future.value(<Booking>[])),
      ]);
      expect(find.byType(TabHeader), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('0 bookings'), findsOneWidget);
      expect(find.text('No bookings yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('c42 title scale <768px', () {
    Future<TextStyle> pumpTitleStyle(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TabHeader(title: 'T', count: 'C'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      return tester.widget<Text>(find.text('T')).style!;
    }

    testWidgets('360px -> 28px title, 13px count', (tester) async {
      final title = await pumpTitleStyle(tester, 360);
      expect(title.fontSize, TabHeader.titleSizeNarrow);
      expect(title.fontSize, 28);
      final count = tester.widget<Text>(find.text('C')).style!;
      expect(count.fontSize, 13);
    });

    testWidgets('768px boundary -> 32px title, 13px count', (tester) async {
      final title = await pumpTitleStyle(tester, 768);
      expect(title.fontSize, TabHeader.titleSizeWide);
      expect(title.fontSize, 32);
      final count = tester.widget<Text>(find.text('C')).style!;
      expect(count.fontSize, 13);
    });

    test('titleSizeFor steps without FittedBox scaling', () {
      expect(TabHeader.titleSizeFor(767), 28);
      expect(TabHeader.titleSizeFor(768), 32);
      expect(TabHeader.titleSizeFor(1200), 32);
    });
  });

  group('c42 pairing B fallback smoke (fetch disabled)', () {
    testWidgets('renders on fallback stacks, single-line ellipsis', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TabHeader(title: 'My Bookings', count: '1 booking'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final title = tester.widget<Text>(find.text('My Bookings'));
      // C127: owner-directed bolden (was w400, script ships 400 only).
      expect(title.style?.fontWeight, FontWeight.w700);
      expect(title.style?.letterSpacing, 0);
      expect(title.style?.fontFamilyFallback, TabHeader.titleFallback);
      expect(title.style?.fontFamilyFallback, contains('Great Vibes'));
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(
        find.ancestor(of: find.text('My Bookings'), matching: find.byType(FittedBox)),
        findsNothing,
      );

      final count = tester.widget<Text>(find.text('1 booking'));
      expect(count.style?.fontSize, 13);
      expect(count.style?.fontFamilyFallback, TabHeader.bodyFallback);
      expect(count.style?.fontFamilyFallback, contains('Roboto'));
      expect(count.maxLines, 1);
      expect(count.overflow, TextOverflow.ellipsis);
    });
  });

  group('c42 header ratios (title 7.0 text, count 4.5 UI)', () {
    double lum(Color c) {
      double f(int ch) {
        final v = ch / 255.0;
        return v <= 0.03928
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
      }

      final r = (c.r * 255.0).round().clamp(0, 255);
      final g = (c.g * 255.0).round().clamp(0, 255);
      final b = (c.b * 255.0).round().clamp(0, 255);
      return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
    }

    double ratio(Color a, Color b) {
      final l1 = lum(a);
      final l2 = lum(b);
      final hi = l1 > l2 ? l1 : l2;
      final lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    // CardSurfaces.title/body tokens vs the scaffold surfaces the
    // headers sit on (light cream / dark night) — no new colors in C42.
    const titleLight = Color(0xFF633E50);
    const bodyLight = Color(0xFF765867);
    const scaffoldLight = Color(0xFFFDF4F5);
    const titleDark = Color(0xFFFDF4F5);
    const bodyDark = Color(0xFFC4ACAC);
    const scaffoldDark = Color(0xFF151012);

    test('title hits the 7:1 text bar both modes', () {
      expect(ratio(titleLight, scaffoldLight), greaterThanOrEqualTo(7.0));
      expect(ratio(titleDark, scaffoldDark), greaterThanOrEqualTo(7.0));
    });

    test('count hits the 4.5:1 UI bar both modes', () {
      expect(ratio(bodyLight, scaffoldLight), greaterThanOrEqualTo(4.5));
      expect(ratio(bodyDark, scaffoldDark), greaterThanOrEqualTo(4.5));
    });
  });
}
