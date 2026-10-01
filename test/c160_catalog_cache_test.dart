import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/packages_screen.dart';
import 'package:inea_scents_client/widgets/catalog_offline_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// C160: 5-min catalog cache + offline banner — airplane-mode packages
/// render from cache with a visible offline label.
Package _offering() => const Package(
  id: 1,
  name: 'Essential 10ml Perfume Bar',
  description: 'A signature scent experience for your celebration.',
  price: 4499,
  paxOptions: [50, 70],
  paxPrices: {50: 4499.0, 70: 6399.0},
  inclusions: ['2-hour perfume bar'],
  freebies: ['Keepsake atomizer'],
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({'first_launch': false});
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.lightTheme, home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => debugClearCatalogCache());
  tearDown(() => debugClearCatalogCache());

  group('isCatalogCacheFresh TTL', () {
    test('fresh within 5 minutes', () {
      final now = DateTime(2026, 10, 1, 12, 0, 0);
      expect(
        isCatalogCacheFresh(now.subtract(const Duration(minutes: 4, seconds: 59)), now: now),
        isTrue,
      );
    });

    test('stale at and beyond 5 minutes', () {
      final now = DateTime(2026, 10, 1, 12, 0, 0);
      expect(
        isCatalogCacheFresh(now.subtract(const Duration(minutes: 5)), now: now),
        isFalse,
      );
      expect(
        isCatalogCacheFresh(now.subtract(const Duration(minutes: 6)), now: now),
        isFalse,
      );
    });

    test('null timestamp is never fresh', () {
      expect(isCatalogCacheFresh(null), isFalse);
    });

    test('hasFreshCatalogCache needs seeded non-empty cache', () {
      expect(hasFreshCatalogCache(), isFalse);
      debugSeedCatalogCache([_offering()], DateTime.now());
      expect(hasFreshCatalogCache(), isTrue);
      debugSeedCatalogCache(
        [_offering()],
        DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(hasFreshCatalogCache(), isFalse);
    });
  });

  group('CatalogOfflineBanner', () {
    testWidgets('renders expected text with semantics label', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const Scaffold(body: CatalogOfflineBanner()));

      expect(
        find.text('Offline — showing cached packages'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('catalog_offline_banner')), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(CatalogOfflineBanner));
      expect(semantics.label, contains('Offline — showing cached packages'));
    });
  });

  group('PackagesScreen offline fallback', () {
    testWidgets('transient error + fresh cache renders cached list + banner', (
      WidgetTester tester,
    ) async {
      debugSeedCatalogCache([_offering()], DateTime.now());
      await _pump(
        tester,
        const PackagesScreen(),
        overrides: [
          packagesProvider.overrideWith(
            (ref) async => throw Exception(
              'Could not connect to the server. Please check your internet connection.',
            ),
          ),
        ],
      );

      expect(find.byKey(const Key('catalog_offline_banner')), findsOneWidget);
      expect(find.text('Offline — showing cached packages'), findsOneWidget);
      expect(find.text('Essential 10ml Perfume Bar'), findsOneWidget);
      // Error card stays hidden when the cache covers the outage.
      expect(find.text('Unable to load Offerings'), findsNothing);
    });

    testWidgets('stale cache falls through to the error card', (
      WidgetTester tester,
    ) async {
      debugSeedCatalogCache(
        [_offering()],
        DateTime.now().subtract(const Duration(minutes: 10)),
      );
      await _pump(
        tester,
        const PackagesScreen(),
        overrides: [
          packagesProvider.overrideWith(
            (ref) async => throw Exception(
              'Could not connect to the server. Please check your internet connection.',
            ),
          ),
        ],
      );

      expect(find.byKey(const Key('catalog_offline_banner')), findsNothing);
      expect(find.text('Unable to load Offerings'), findsOneWidget);
    });
  });
}
