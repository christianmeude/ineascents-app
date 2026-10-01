import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/auth_error_copy.dart';
import 'package:inea_scents_client/screens/register_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

/// C162: register mailer-down 500 shows short friendly copy + Retry,
/// zero raw `stream_socket`/exception text in card or toast.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const raw500 =
      'Exception: stream_socket_enable_crypto(): SSL operation failed '
      'with code 1 (Server error: 500)';
  const friendly =
      'Something went wrong sending the verification email. Please retry.';

  group('C162 phrasebook mapping', () {
    test('500 DioException maps to friendly register copy', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/api/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/register'),
          statusCode: 500,
          data: {'message': raw500},
        ),
      );
      expect(authErrorCopy(e), friendly);
    });

    test('friendlyRegisterMessage sanitizes raw, keeps validation', () {
      expect(friendlyRegisterMessage(raw500), friendly);
      expect(
        friendlyRegisterMessage('That email is already in use. Try another.'),
        'That email is already in use. Try another.',
      );
    });

    test('raw 500 shapes count as transient (Retry intact)', () {
      expect(isTransientErrorMessage(raw500), isTrue);
      expect(isTransientErrorMessage(friendly), isTrue);
    });
  });

  group('C162 register card', () {
    Widget cardApp() {
      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      final router = GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/verify-email',
            builder: (context, state) => const Text('VERIFY'),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Text('HOME'),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Text('LOGIN'),
          ),
          GoRoute(
            path: '/privacy',
            builder: (context, state) => const Text('PRIVACY'),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          authProvider.overrideWith(
            (ref) => _MailerDownAuthNotifier(
              buildFakeRestClient(backend),
              storage,
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('500 error shows friendly copy, no raw, Retry present',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(cardApp());
      await tester.pumpAndSettle();

      expect(find.text(friendly), findsOneWidget);
      expect(find.textContaining('stream_socket'), findsNothing);
      expect(find.textContaining('Exception:'), findsNothing);
      expect(find.byKey(const Key('form_error_retry')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('C162 toast', () {
    Future<BuildContext> pumpHarness(WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return ctx;
    }

    testWidgets('raw 500 toast sanitizes to friendly copy with Retry',
        (tester) async {
      final ctx = await pumpHarness(tester);
      var retried = 0;
      showAppError(
        ctx,
        message: raw500,
        transient: true,
        onRetry: () => retried++,
      );
      await tester.pumpAndSettle();

      expect(find.text(friendly), findsOneWidget);
      expect(find.textContaining('stream_socket'), findsNothing);
      expect(find.textContaining('Exception:'), findsNothing);
      await tester.tap(find.byKey(const Key('app_error_retry')));
      await tester.pumpAndSettle();
      expect(retried, 1);
      expect(tester.takeException(), isNull);
    });
  });
}

class _MemoryTokenStorage extends TokenStorage {
  String? token;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}

class _MailerDownAuthNotifier extends AuthNotifier {
  _MailerDownAuthNotifier(super.apiClient, super.tokenStorage) {
    state = AuthState(
      errorMessage:
          'Exception: stream_socket_enable_crypto(): SSL operation failed '
          'with code 1 (Server error: 500)',
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {}
}
