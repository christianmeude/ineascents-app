import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/screens/forgot_password_screen.dart';
import 'package:inea_scents_client/screens/login_screen.dart';
import 'package:inea_scents_client/screens/register_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C45: auth light-mode blob tone-down to AAA.
///
/// Light blobs are translucent tints over the cream base; the test blends
/// each blob over its base (worst-case full coverage) and asserts the plum
/// foreground copy keeps >= 7:1 (AAA text) and >= 4.5:1 (UI) on the tinted
/// surface. Dark mode keeps its palette and must stay >= 7:1.
/// Palette constants below must mirror lib/screens/*_screen.dart (C45).
double _lum(Color c) {
  double f(int ch) {
    final v = ch / 255.0;
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = (c.r * 255.0).round().clamp(0, 255);
  final g = (c.g * 255.0).round().clamp(0, 255);
  final b = (c.b * 255.0).round().clamp(0, 255);
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
}

double _ratio(Color a, Color b) {
  final l1 = _lum(a);
  final l2 = _lum(b);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

/// Alpha-composite [fg] over opaque [bg] (both ARGB hex literals).
Color _over(Color fg, Color bg) {
  final a = fg.a;
  int ch(double f, double b) =>
      ((f * a + b * (1 - a)) * 255).round().clamp(0, 255);
  return Color.fromARGB(
    255,
    ch(fg.r, bg.r),
    ch(fg.g, bg.g),
    ch(fg.b, bg.b),
  );
}

// Light mode: cream base, plum copy, C45 translucent blobs.
const _lightBase = Color(0xFFFDF4F5);
const _lightFg = Color(0xFF6A4053);
const _lightBlobs = <Color>[
  Color(0x14DABDAC),
  Color(0x14C08D9E),
  Color(0x14988088),
  Color(0x14C4A5A8),
  Color(0x0D6E3C53),
];

// Dark mode: night base, cream copy, existing translucent blobs (untouched).
const _darkBase = Color(0xFF151012);
const _darkFg = Color(0xFFFDF4F5);
const _darkBlobs = <Color>[
  Color(0x664A1C28),
  Color(0x806A4053),
  Color(0x9936222C),
  Color(0xB33B1019),
  Color(0x996A4053),
];

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c45 auth blob contrast (WCAG math)', () {
    test('light base copy is AAA before blobs', () {
      expect(_ratio(_lightFg, _lightBase), greaterThanOrEqualTo(7.0));
    });

    test('light plum copy stays AAA on every blob-tinted surface', () {
      for (final blob in _lightBlobs) {
        final surface = _over(blob, _lightBase);
        expect(
          _ratio(_lightFg, surface),
          greaterThanOrEqualTo(7.0),
          reason: 'blob ${blob.toString()} tinted surface fails AAA text',
        );
        // UI components (borders, focus rings) share the plum hue.
        expect(
          _ratio(_lightFg, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'blob ${blob.toString()} tinted surface fails UI 4.5:1',
        );
      }
    });

    test('light button token unaffected (opaque plum fill)', () {
      expect(
        _ratio(AppTheme.primaryButtonBackground, AppTheme.onPrimaryButton),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('dark cream copy stays AAA on every blob-tinted surface', () {
      expect(_ratio(_darkFg, _darkBase), greaterThanOrEqualTo(7.0));
      for (final blob in _darkBlobs) {
        final surface = _over(blob, _darkBase);
        expect(
          _ratio(_darkFg, surface),
          greaterThanOrEqualTo(7.0),
          reason: 'dark blob ${blob.toString()} tinted surface fails AAA',
        );
      }
    });
  });

  group('c45 auth screens legible both modes @360px', () {
    ProviderScope scope({required ThemeData theme, required Widget child}) =>
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(
              buildFakeRestClient(FakeApiBackend()),
            ),
          ],
          child: MaterialApp(theme: theme, home: child),
        );

    const screens = <String, Widget>{
      'login': LoginScreen(),
      'register': RegisterScreen(),
      'forgot': ForgotPasswordScreen(),
    };
    const copy = <String, String>{
      'login': 'LOG IN',
      'register': 'REGISTER',
      'forgot': 'SEND RESET CODE',
    };

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
      for (final entry in screens.entries) {
        testWidgets('${entry.key} $mode renders copy @360px', (
          WidgetTester tester,
        ) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            scope(theme: theme, child: entry.value),
          );
          await tester.pumpAndSettle();

          expect(find.text(copy[entry.key]!), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
