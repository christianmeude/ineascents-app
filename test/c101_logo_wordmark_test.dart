import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/screens/login_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

/// C101: shared logo wordmark — auth screens route through [AppLogo] and the
/// Scents script carries the Great Vibes fallback stack.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  ProviderScope scope({required Widget child}) => ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(buildFakeRestClient(FakeApiBackend())),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );

  group('c101 logo wordmark', () {
    testWidgets('login screen renders shared AppLogo', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(scope(child: const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('INEA'), findsWidgets);
      expect(find.text('Scents'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppLogo Scents carries Great Vibes fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const AppLogo()),
      );
      await tester.pumpAndSettle();

      final scents = tester.widgetList<Text>(find.text('Scents'));
      expect(scents, isNotEmpty);
      for (final t in scents) {
        expect(t.style?.fontFamily, contains('GreatVibes'));
        expect(t.style?.fontFamilyFallback, TabHeader.titleFallback);
        expect(t.style?.fontFamilyFallback!.first, 'Great Vibes');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppLogo renders spec wordmark in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.darkTheme, home: const AppLogo()),
      );
      await tester.pumpAndSettle();

      expect(find.text('INEA'), findsWidgets);
      final scents = tester.widgetList<Text>(find.text('Scents'));
      expect(scents, isNotEmpty);
      for (final t in scents) {
        expect(t.style?.fontFamily, contains('GreatVibes'));
        expect(t.style?.fontFamilyFallback!.first, 'Great Vibes');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('TopNavBar Scents carries Great Vibes fallback', (
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

      final style = tester.widget<Text>(find.text('Scents')).style!;
      expect(style.fontFamily, contains('GreatVibes'));
      expect(style.fontFamilyFallback, TabHeader.titleFallback);
      expect(style.fontFamilyFallback!.first, 'Great Vibes');
      expect(tester.takeException(), isNull);
    });
  });
}
