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
import 'package:inea_scents_client/widgets/auth_background.dart';

import 'helpers/fake_api.dart';

/// C89: auth uses the admin solid base (light #FDF4F5 / dark #151012) +
/// opaque/translucent mesh blobs — C88's restored e130957 diagonal
/// gradient is superseded (GuestLayout.vue paints a solid base, never a
/// gradient). Contrast below pins the C89 reality instead.
///
/// Budgets (C32-C36 precedent): light text/UI pairs hold >= 5.7 on the
/// solid base; opaque blob cores miss and are reported, never restyled.
/// Button token and dark mesh stay AAA (>= 7). Blob geometry scales down
/// below 640px so no mobile-width render overflows.
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

const _plum = Color(0xFF6A4053);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('c59 light solid-base contrast (WCAG math)', () {
    test('C89 admin solid base passes the 5.7 budget', () {
      // C89: solid #FDF4F5 base reads 7.87 vs plum — passes.
      expect(AuthBackground.lightBase, equals(const Color(0xFFFDF4F5)));
      expect(
        _ratio(_plum, AuthBackground.lightBase),
        greaterThanOrEqualTo(5.7),
        reason: 'solid base must hold light text budget',
      );
    });

    test('C89 opaque blob cores miss budget (reported, never restyled)', () {
      // C89: opaque admin fills (4.80 / 3.05 / 2.34 / 3.76 / 1.02) all
      // miss 5.7 — reported per ticket, never restyled.
      for (final blob in AuthBackground.lightBlobs) {
        expect(
          _ratio(_plum, blob),
          lessThan(5.7),
          reason: 'blob $blob over base unexpectedly meets budget',
        );
      }
    });

    test('button token + dark mesh untouched (AAA >= 7)', () {
      expect(
        _ratio(
          AppTheme.primaryButtonBackground,
          AppTheme.onPrimaryButton,
        ),
        greaterThanOrEqualTo(7.0),
      );
      expect(
        _ratio(const Color(0xFFFDF4F5), AuthBackground.darkBase),
        greaterThanOrEqualTo(7.0),
      );
    });
  });

  group('c59 blob scale seam', () {
    test('360px shrinks blobs, 768/1280 stay full-size', () {
      expect(AuthBackground.blobScaleForWidth(360), lessThan(1.0));
      expect(AuthBackground.blobScaleForWidth(360), greaterThanOrEqualTo(0.5));
      expect(AuthBackground.blobScaleForWidth(768), equals(1.0));
      expect(AuthBackground.blobScaleForWidth(1280), equals(1.0));
    });
  });

  group('c59 auth screens no overflow @360px + @1280px', () {
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

    for (final width in [360.0, 1280.0]) {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        final mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
        for (final entry in screens.entries) {
          testWidgets(
            '${entry.key} $mode renders copy @${width.toInt()}px, no overflow',
            (WidgetTester tester) async {
              tester.view.physicalSize = Size(width, 800);
              tester.view.devicePixelRatio = 1.0;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);

              await tester.pumpWidget(
                scope(theme: theme, child: entry.value),
              );
              await tester.pumpAndSettle();

              expect(find.text(copy[entry.key]!), findsOneWidget);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }

    testWidgets('light mode paints the C89 solid base backdrop', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        scope(theme: AppTheme.lightTheme, child: const LoginScreen()),
      );
      await tester.pumpAndSettle();

      // C89: solid admin base — no LinearGradient in the backdrop.
      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .where((c) {
            final d = c.decoration;
            return d is BoxDecoration && d.gradient is LinearGradient;
          });
      expect(containers, isEmpty);
      final bases = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .where((c) {
            final d = c.decoration;
            return d is BoxDecoration && d.color == AuthBackground.lightBase;
          });
      expect(bases, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('c59 narrow inward bounds + dark geometry freeze', () {
    testWidgets('light narrow anchors stay within [0,1]-ish bounds (no outward spill)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthBackground(isDark: false, child: SizedBox()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const sw = 360.0;
      final blobs = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .where((p) => (p.left == null) != (p.right == null))
          .toList();
      expect(blobs, hasLength(8));
      for (final p in blobs) {
        if (p.left != null) {
          // [0,1]-ish: allow the pre-existing slight off-screen anchor
          // (-0.05) but never an outward spill like -0.15/-0.10.
          expect(p.left!, greaterThanOrEqualTo(-0.05 * sw - 1.0),
              reason: 'left $p spills outward past the viewport edge');
          expect(p.left!, lessThanOrEqualTo(sw));
        }
        if (p.right != null) {
          expect(p.right!, greaterThanOrEqualTo(-0.05 * sw - 1.0),
              reason: 'right $p spills outward past the viewport edge');
          expect(p.right!, lessThanOrEqualTo(sw));
        }
      }
      // The two C59 narrowRight overrides must be genuinely inward
      // (non-negative, never past the right edge).
      final rights =
          blobs.where((p) => p.right != null).map((p) => p.right!).toList();
      expect(rights.where((r) => r < 0).length, lessThanOrEqualTo(1),
          reason: 'only the untouched -0.05 anchor may sit off-screen');
      expect(tester.takeException(), isNull);
    });

    testWidgets('every narrow override moves inward vs its base frac',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<List<Positioned>> offsetsFor(bool isDark) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthBackground(isDark: isDark, child: const SizedBox()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester
            .widgetList<Positioned>(find.byType(Positioned))
            .where((p) => (p.left == null) != (p.right == null))
            .toList();
      }

      // Narrow light (overrides active) vs dark (frozen base geometry):
      // same 360px width, so any delta is purely the narrow override.
      final narrow = await offsetsFor(false);
      final base = await offsetsFor(true);
      expect(narrow, hasLength(8));
      expect(base, hasLength(8));
      // Indices with a narrow override (must move strictly inward);
      // the rest share the base frac (must be equal).
      const overridden = {0, 2, 4, 5, 7};
      for (var i = 0; i < 8; i++) {
        final n = narrow[i].left ?? narrow[i].right!;
        final b = base[i].left ?? base[i].right!;
        if (overridden.contains(i)) {
          expect(n, greaterThan(b + 1.0),
              reason: 'blob $i narrow $n must sit inward of base $b');
        } else {
          expect(n, closeTo(b, 1.0),
              reason: 'blob $i has no override, must equal base $b');
        }
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark layout at 360px equals pre-C59 desktop geometry',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthBackground(isDark: true, child: SizedBox()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const sw = 360.0;
      const sh = 800.0;
      // Pre-C59 desktop geometry: base fracs at full scale.
      const expectedTops = [-0.10, 0.10, 0.30, 0.65, -0.15, 0.20, 0.50, 0.75];
      const expectedLefts = [-0.05, 0.05, -0.10, -0.05];
      const expectedRights = [0.05, 0.20, -0.05, 0.05];
      const expectedSizes = [
        Size(300, 600),
        Size(600, 300),
        Size(800, 250),
        Size(500, 400),
        Size(800, 600),
        Size(500, 400),
        Size(300, 500),
        Size(600, 250),
      ];

      final blobs = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .where((p) => (p.left == null) != (p.right == null))
          .toList();
      expect(blobs, hasLength(8));
      for (var i = 0; i < 8; i++) {
        expect(blobs[i].top, closeTo(sh * expectedTops[i], 1.0));
        if (i < 4) {
          expect(blobs[i].left, closeTo(sw * expectedLefts[i], 1.0));
        } else {
          expect(blobs[i].right,
              closeTo(sw * expectedRights[i - 4], 1.0));
        }
      }

      final blobFinder = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius != null,
      );
      expect(blobFinder, findsNWidgets(8));
      for (var i = 0; i < 8; i++) {
        // Full scale in dark mode: no blobScaleForWidth shrink at 360px
        // (360/768 would be ~0.5 if applied).
        final size = tester.getSize(blobFinder.at(i));
        expect(size.width, closeTo(expectedSizes[i].width, 1.0));
        expect(size.height, closeTo(expectedSizes[i].height, 1.0));
      }
      expect(tester.takeException(), isNull);
    });
  });
}
