import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/auth_error_copy.dart';
import 'package:inea_scents_client/screens/forgot_password_screen.dart';
import 'package:inea_scents_client/screens/reset_password_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C93: forgot/reset wired to backend A8 — email requests a code, the code
/// plus a new password resets, errors show phrasebook copy. The backend
/// never reveals address existence, so request always succeeds.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('authErrorCopy reset codes', () {
    DioException codeError(String code, [Map<String, Object?>? extra]) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/reset-password'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/reset-password'),
          statusCode: 422,
          data: {'message': 'server words', 'code': code, ...?extra},
        ),
      );
    }

    test('maps reset codes to customer words, never server words', () {
      expect(authErrorCopy(codeError('PASSWORD_RESET_NONE')),
          'No code requested yet. Request a code first.');
      expect(authErrorCopy(codeError('EMAIL_CODE_EXPIRED')),
          'That code expired. Request a new one.');
      expect(
        authErrorCopy(codeError('EMAIL_CODE_MISMATCH', {'attempts_left': 4})),
        "That code doesn't match. You have 4 tries left.",
      );
    });
  });

  group('forgot password flows', () {
    Widget forgotApp(FakeApiBackend backend) {
      final router = GoRouter(
        initialLocation: '/forgot-password',
        routes: [
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/reset-password',
            builder: (context, state) => ResetPasswordScreen(
              initialEmail: state.queryParameters['email'] ?? '',
            ),
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
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('submit requests a code then opens reset with the email',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend();
      await tester.pumpWidget(forgotApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'maria@example.com',
      );
      await tester.tap(find.byKey(const Key('forgot_password_submit')));
      await tester.pumpAndSettle();

      expect(backend.forgotPasswordCallCount, 1);
      expect(
        find.text('If that email exists, a code was sent.'),
        findsOneWidget,
      );
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid email never hits the network', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(forgotApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.tap(find.byKey(const Key('forgot_password_submit')));
      await tester.pumpAndSettle();

      expect(backend.forgotPasswordCallCount, 0);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('reset password flows', () {
    Widget resetApp(FakeApiBackend backend) {
      final router = GoRouter(
        initialLocation: '/reset-password?email=maria@example.com',
        routes: [
          GoRoute(
            path: '/reset-password',
            builder: (context, state) => ResetPasswordScreen(
              initialEmail: state.queryParameters['email'] ?? '',
            ),
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
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    Future<void> fillValid(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('reset_password_code')),
        '482916',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_new')),
        'brand-new-pass-2',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm')),
        'brand-new-pass-2',
      );
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('reset_password_submit')));
      await tester.pumpAndSettle();
    }

    testWidgets('email arrives prefilled from the forgot step',
        (tester) async {
      final backend = FakeApiBackend()..resetCodeRequested = true;
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      expect(find.text('maria@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('code plus new password resets then lands on login',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend()..resetCodeRequested = true;
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await fillValid(tester);
      await tester.tap(find.byKey(const Key('reset_password_submit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Password reset.'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(backend.resetPasswordCallCount, 1);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wrong code shows tries left', (tester) async {
      final backend = FakeApiBackend()..resetCodeRequested = true;
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_code')),
        '000000',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_new')),
        'brand-new-pass-2',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm')),
        'brand-new-pass-2',
      );
      await submit(tester);

      expect(backend.resetPasswordCallCount, 1);
      expect(find.textContaining("doesn't match"), findsOneWidget);
      expect(find.textContaining('4 tries left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expired code shows mapped copy', (tester) async {
      final backend = FakeApiBackend()
        ..resetCodeRequested = true
        ..failResetPasswordWith = 'EMAIL_CODE_EXPIRED';
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await fillValid(tester);
      await submit(tester);

      expect(find.text('That code expired. Request a new one.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('locked code shows mapped copy', (tester) async {
      final backend = FakeApiBackend()
        ..resetCodeRequested = true
        ..failResetPasswordWith = 'EMAIL_CODE_LOCKED';
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await fillValid(tester);
      await submit(tester);

      expect(find.text('Too many wrong tries. Request a new code.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reset without a request shows mapped copy', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await fillValid(tester);
      await submit(tester);

      expect(backend.resetPasswordCallCount, 1);
      expect(find.text('No code requested yet. Request a code first.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mismatched confirmation stays client-side', (tester) async {
      final backend = FakeApiBackend()..resetCodeRequested = true;
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_code')),
        '482916',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_new')),
        'brand-new-pass-2',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm')),
        'other-pass-3',
      );
      await submit(tester);

      expect(backend.resetPasswordCallCount, 0);
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend requests a fresh code', (tester) async {
      final backend = FakeApiBackend()..resetCodeRequested = true;
      await tester.pumpWidget(resetApp(backend));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_password_resend')));
      await tester.pumpAndSettle();

      expect(backend.forgotPasswordCallCount, 1);
      expect(find.text('Code re-sent.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
