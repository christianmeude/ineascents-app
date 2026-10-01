import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/privacy_policy_screen.dart';
import 'package:inea_scents_client/screens/register_screen.dart';
import 'package:inea_scents_client/screens/verify_email_screen.dart';
import 'package:inea_scents_client/src/network/dio_client.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C159: in-app privacy policy + register consent gate + server logout.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget registerApp(FakeApiBackend backend, _MemoryTokenStorage storage) {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) => VerifyEmailScreen(
            initialEmail: state.queryParameters['email'] ?? '',
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Text('HOME'),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            buildFakeRestClient(backend),
            storage,
          ),
        ),
        dioClientProvider.overrideWithValue(
          _fakeDioClient(backend, storage),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('privacy policy screen', () {
    testWidgets('renders versioned policy text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Version 2026-10-01'), findsOneWidget);
      expect(find.textContaining('ineascents.app@gmail.com'), findsWidgets);
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('register consent gate', () {
    testWidgets('submit blocked until privacy accepted, then registers',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      await tester.pumpWidget(registerApp(backend, storage));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_name')),
        'Maria Clara',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'maria@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'secret-pass-1',
      );

      // Blocked before consent.
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pumpAndSettle();
      expect(backend.registerCallCount, 0);

      await tester.tap(find.byKey(const Key('register_consent')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pumpAndSettle();

      expect(backend.registerCallCount, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('privacy link is present and row toggles consent', (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      await tester.pumpWidget(registerApp(backend, storage));
      await tester.pumpAndSettle();

      // Link to the offline policy exists next to the checkbox.
      expect(
        find.textContaining('privacy policy', findRichText: true),
        findsOneWidget,
      );
      expect(find.byKey(const Key('register_consent')), findsOneWidget);

      // Tapping the row toggles consent (submit enables afterwards).
      await tester.tap(find.byKey(const Key('register_consent')));
      await tester.pumpAndSettle();

      final ElevatedButton button = tester.widget(
        find.byKey(const Key('register_submit')),
      );
      expect(button.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('server logout', () {
    test('logout revokes server session and clears local token', () async {
      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage()..token = 'live-token';
      final notifier = AuthNotifier(buildFakeRestClient(backend), storage);

      await notifier.logout();

      expect(backend.logoutCallCount, 1);
      expect(await storage.readToken(), isNull);
    });

    test('logout still clears local token when server is down', () async {
      final backend = FakeApiBackend()..failLogout = true;
      final storage = _MemoryTokenStorage()..token = 'live-token';
      final notifier = AuthNotifier(buildFakeRestClient(backend), storage);

      await notifier.logout();

      expect(backend.logoutCallCount, 1);
      expect(await storage.readToken(), isNull);
    });
  });
}

class _MemoryTokenStorage extends TokenStorage {
  String? token;
  int saveCalls = 0;

  @override
  Future<void> saveToken(String value) async {
    saveCalls++;
    token = value;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}

DioClient _fakeDioClient(FakeApiBackend backend, _MemoryTokenStorage storage) {
  final client = DioClient(baseUrl: 'http://fake.test', tokenStorage: storage);
  client.dio.httpClientAdapter = FakeHttpClientAdapter(backend);
  return client;
}
