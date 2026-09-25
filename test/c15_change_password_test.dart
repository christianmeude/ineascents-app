import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/auth_error_copy.dart';
import 'package:inea_scents_client/screens/change_password_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C15: /profile/password wired to backend A7 — first submit requests a
/// code, second submit changes with the code, errors show phrasebook copy.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('authErrorCopy password codes', () {
    DioException codeError(String code, [Map<String, Object?>? extra]) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/user/password/change'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/user/password/change'),
          statusCode: 422,
          data: {'message': 'server words', 'code': code, ...?extra},
        ),
      );
    }

    test('maps password codes to customer words, never server words', () {
      expect(authErrorCopy(codeError('CURRENT_PASSWORD_WRONG')),
          'Your current password is incorrect.');
      expect(authErrorCopy(codeError('EMAIL_CODE_EXPIRED')),
          'That code expired. Request a new one.');
      expect(authErrorCopy(codeError('PASSWORD_CHANGE_NONE')),
          'No code requested yet. Request a code first.');
      expect(
        authErrorCopy(codeError('EMAIL_CODE_MISMATCH', {'attempts_left': 4})),
        "That code doesn't match. You have 4 tries left.",
      );
    });
  });

  group('change password flows', () {
    Widget wiredApp(FakeApiBackend backend) {
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        ],
        child: const MaterialApp(home: ChangePasswordScreen()),
      );
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('change_password_submit')));
      await tester.pumpAndSettle();
    }

    Future<void> fillValid(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('change_password_current')),
        'current-pass-1',
      );
      await tester.enterText(
        find.byKey(const Key('change_password_new')),
        'brand-new-pass-2',
      );
      await tester.enterText(
        find.byKey(const Key('change_password_confirm')),
        'brand-new-pass-2',
      );
    }

    Future<void> requestCode(
      WidgetTester tester,
      FakeApiBackend backend,
    ) async {
      await fillValid(tester);
      await submit(tester);

      expect(backend.passwordRequestCallCount, 1);
      expect(backend.passwordChangeCallCount, 0);
      expect(
        find.text('Code sent to your email. Enter it below.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('change_password_resend')), findsOneWidget);
      // Let the request snack expire so it never covers the submit button.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    testWidgets('submit requests a code first, then changes with the code',
        (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);

      await tester.enterText(
        find.byKey(const Key('change_password_code')),
        '482916',
      );
      await submit(tester);

      expect(backend.passwordChangeCallCount, 1);
      expect(find.text('Password changed.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wrong current password shows mapped copy', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);

      await tester.enterText(
        find.byKey(const Key('change_password_current')),
        'wrong-pass-99',
      );
      await tester.enterText(
        find.byKey(const Key('change_password_code')),
        '482916',
      );
      await submit(tester);

      expect(backend.passwordChangeCallCount, 1);
      expect(find.text('Your current password is incorrect.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wrong code shows tries left', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);

      await tester.enterText(
        find.byKey(const Key('change_password_code')),
        '000000',
      );
      await submit(tester);

      expect(backend.passwordChangeCallCount, 1);
      expect(find.textContaining("doesn't match"), findsOneWidget);
      expect(find.textContaining('4 tries left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expired code shows mapped copy', (tester) async {
      final backend = FakeApiBackend()
        ..failPasswordChangeWith = 'EMAIL_CODE_EXPIRED';
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);

      await tester.enterText(
        find.byKey(const Key('change_password_code')),
        '482916',
      );
      await submit(tester);

      expect(find.text('That code expired. Request a new one.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('missing request shows mapped copy', (tester) async {
      final backend = FakeApiBackend()
        ..failPasswordChangeWith = 'PASSWORD_CHANGE_NONE';
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);

      await tester.enterText(
        find.byKey(const Key('change_password_code')),
        '482916',
      );
      await submit(tester);

      expect(find.text('No code requested yet. Request a code first.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend requests a fresh code', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await requestCode(tester, backend);
      await tester.tap(find.byKey(const Key('change_password_resend')));
      await tester.pumpAndSettle();

      expect(backend.passwordRequestCallCount, 2);
      expect(find.text('Code re-sent.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend cooldown shows mapped copy', (tester) async {
      final backend = FakeApiBackend()..failPasswordRequestCooldown = true;
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      // First submit hits the cooldown too: no code sent, no resend row.
      await fillValid(tester);
      await submit(tester);

      expect(backend.passwordRequestCallCount, 1);
      expect(find.text('Please wait a minute, then resend the code.'),
          findsOneWidget);
      expect(find.byKey(const Key('change_password_resend')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
