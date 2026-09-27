import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/auth_error_copy.dart';
import 'package:inea_scents_client/screens/login_screen.dart';
import 'package:inea_scents_client/screens/register_screen.dart';
import 'package:inea_scents_client/screens/verify_email_screen.dart';
import 'package:inea_scents_client/src/network/dio_client.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C95: /verify-email screen + register routing + verified notice, wired to
/// backend A11 — register creates a pending user with zero token, the code
/// verifies, and login follows with a verified notice. No token is stored
/// until login.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('authErrorCopy registration codes', () {
    DioException codeError(String code, [Map<String, Object?>? extra]) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/register/verify'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/register/verify'),
          statusCode: 422,
          data: {'message': 'server words', 'code': code, ...?extra},
        ),
      );
    }

    test('maps registration codes to customer words, never server words', () {
      expect(authErrorCopy(codeError('REGISTER_NONE')),
          'No pending verification. Register again.');
      expect(authErrorCopy(codeError('EMAIL_NOT_VERIFIED')),
          'Verify your email first. Check your inbox for the code.');
      expect(
        authErrorCopy(codeError('EMAIL_CODE_MISMATCH', {'attempts_left': 4})),
        "That code doesn't match. You have 4 tries left.",
      );
    });
  });

  group('register pending state', () {
    test('pending registration stays logged out with zero token stored',
        () async {
      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      final notifier = AuthNotifier(
        buildFakeRestClient(backend),
        storage,
      );

      await notifier.register(
        name: 'Maria Clara',
        email: 'maria@example.com',
        password: 'secret-pass-1',
      );

      expect(backend.registerCallCount, 1);
      expect(notifier.state.isLoggedIn, isFalse);
      expect(notifier.state.user?.email, 'maria@example.com');
      expect(notifier.state.errorMessage, isNull);
      expect(storage.saveCalls, 0);
      expect(await storage.readToken(), isNull);
    });

    test('unverified login is blocked', () async {
      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      final notifier = AuthNotifier(
        buildFakeRestClient(backend),
        storage,
      );

      await notifier.register(
        name: 'Maria Clara',
        email: 'maria@example.com',
        password: 'secret-pass-1',
      );
      await notifier.login(
        email: 'maria@example.com',
        password: 'secret-pass-1',
      );

      expect(backend.loginCallCount, 1);
      expect(notifier.state.isLoggedIn, isFalse);
      expect(notifier.state.errorMessage, contains('Verify'));
      expect(await storage.readToken(), isNull);
    });

    test('login after verify issues a token', () async {
      final backend = FakeApiBackend()
        ..registeredEmail = 'maria@example.com'
        ..registerCodeRequested = true;
      final storage = _MemoryTokenStorage();
      final notifier = AuthNotifier(
        buildFakeRestClient(backend),
        storage,
      );
      // Simulate the verify step through the code gate.
      backend.verifiedEmails.add('maria@example.com');
      backend.registerCodeRequested = false;

      await notifier.login(
        email: 'maria@example.com',
        password: 'secret-pass-1',
      );

      expect(notifier.state.isLoggedIn, isTrue);
      expect(await storage.readToken(), 'fake-token');
    });
  });

  group('register to verify routing', () {
    Widget registerApp(FakeApiBackend backend, _MemoryTokenStorage storage) {
      final router = GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
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
          GoRoute(
            path: '/login',
            builder: (context, state) => const Text('LOGIN'),
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

    testWidgets('register routes to verify with the email, zero token',
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
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pumpAndSettle();

      expect(backend.registerCallCount, 1);
      expect(storage.saveCalls, 0);
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('verify email flows', () {
    Widget verifyApp(FakeApiBackend backend, _MemoryTokenStorage storage) {
      final router = GoRouter(
        initialLocation: '/verify-email?email=maria@example.com',
        routes: [
          GoRoute(
            path: '/verify-email',
            builder: (context, state) => VerifyEmailScreen(
              initialEmail: state.queryParameters['email'] ?? '',
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(
              verified: state.queryParameters['verified'] == '1',
            ),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          dioClientProvider.overrideWithValue(
            _fakeDioClient(backend, storage),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    FakeApiBackend seededBackend() => FakeApiBackend()
      ..registeredEmail = 'maria@example.com'
      ..registerCodeRequested = true;

    testWidgets('email arrives prefilled from the register step',
        (tester) async {
      final backend = seededBackend();
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      expect(find.text('maria@example.com'), findsOneWidget);
      // Code gate is open: register already sent the code.
      expect(find.byKey(const Key('verify_email_code')), findsOneWidget);
      expect(find.byKey(const Key('verify_email_resend')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('code verifies then lands on login with notice',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = seededBackend();
      final storage = _MemoryTokenStorage();
      await tester.pumpWidget(verifyApp(backend, storage));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('verify_email_code')),
        '482916',
      );
      await tester.tap(find.byKey(const Key('verify_email_submit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Email verified. Log in.'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(backend.registerVerifyCallCount, 1);
      expect(storage.saveCalls, 0);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('Email verified. Log in to continue.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('wrong code shows tries left', (tester) async {
      final backend = seededBackend();
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('verify_email_code')),
        '000000',
      );
      await tester.tap(find.byKey(const Key('verify_email_submit')));
      await tester.pumpAndSettle();

      expect(backend.registerVerifyCallCount, 1);
      expect(find.textContaining("doesn't match"), findsOneWidget);
      expect(find.textContaining('4 tries left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('verify without a pending registration shows mapped copy',
        (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('verify_email_code')),
        '482916',
      );
      await tester.tap(find.byKey(const Key('verify_email_submit')));
      await tester.pumpAndSettle();

      expect(backend.registerVerifyCallCount, 1);
      expect(
        find.text('No pending verification. Register again.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('already-verified address verifies idempotently',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = seededBackend()
        ..verifiedEmails.add('maria@example.com')
        ..registerCodeRequested = false;
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('verify_email_code')),
        '482916',
      );
      await tester.tap(find.byKey(const Key('verify_email_submit')));
      await tester.pumpAndSettle();

      expect(backend.registerVerifyCallCount, 1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('Email verified. Log in to continue.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend requests a fresh code', (tester) async {
      final backend = seededBackend();
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('verify_email_resend')));
      await tester.pumpAndSettle();

      expect(backend.registerResendCallCount, 1);
      expect(find.text('Code re-sent.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend without a pending registration shows mapped copy',
        (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('verify_email_resend')));
      await tester.pumpAndSettle();

      expect(backend.registerResendCallCount, 1);
      expect(
        find.text('No pending verification. Register again.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend cooldown shows mapped copy', (tester) async {
      final backend = seededBackend()..failRegisterResendCooldown = true;
      await tester.pumpWidget(verifyApp(backend, _MemoryTokenStorage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('verify_email_resend')));
      await tester.pumpAndSettle();

      expect(
        find.text('Please wait a minute, then resend the code.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('verified notice', () {
    testWidgets('login shows the notice only when verified', (tester) async {
      final backend = FakeApiBackend();
      Widget loginApp({required bool verified}) {
        return ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          ],
          child: MaterialApp(
            home: LoginScreen(verified: verified),
          ),
        );
      }

      await tester.pumpWidget(loginApp(verified: true));
      await tester.pumpAndSettle();
      expect(
        find.text('Email verified. Log in to continue.'),
        findsOneWidget,
      );

      await tester.pumpWidget(loginApp(verified: false));
      await tester.pumpAndSettle();
      expect(
        find.text('Email verified. Log in to continue.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
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
