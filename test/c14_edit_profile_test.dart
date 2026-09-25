import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/api/models/user.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/auth_error_copy.dart';
import 'package:inea_scents_client/screens/edit_profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C14: Edit Profile wired to backend A6 — name saves inline, email flow
/// completes only with code, errors show phrasebook copy.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('authErrorCopy', () {
    DioException codeError(String code, [Map<String, Object?>? extra]) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/user'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/user'),
          statusCode: 422,
          data: {'message': 'server words', 'code': code, ...?extra},
        ),
      );
    }

    test('maps email codes to customer words, never server words', () {
      expect(authErrorCopy(codeError('EMAIL_TAKEN')),
          'That email is already in use. Try another.');
      expect(authErrorCopy(codeError('EMAIL_CODE_EXPIRED')),
          'That code expired. Request a new one.');
      expect(authErrorCopy(codeError('EMAIL_CODE_LOCKED')),
          'Too many wrong tries. Request a new code.');
      expect(authErrorCopy(codeError('EMAIL_CODE_RESEND_TOO_SOON')),
          'Please wait a minute, then resend the code.');
      expect(authErrorCopy(codeError('EMAIL_CHANGE_NONE')),
          'No code requested yet. Save your new email first.');
    });

    test('mismatch copy carries attempts left', () {
      expect(
        authErrorCopy(codeError('EMAIL_CODE_MISMATCH', {'attempts_left': 4})),
        "That code doesn't match. You have 4 tries left.",
      );
      expect(
        authErrorCopy(codeError('EMAIL_CODE_MISMATCH', {'attempts_left': 1})),
        "That code doesn't match. You have 1 try left.",
      );
    });

    test('unknown code and network shapes fall back generic', () {
      expect(authErrorCopy(codeError('SOMETHING_NEW')),
          'Something went wrong. Please try again.');
      final offline = DioException(
        requestOptions: RequestOptions(path: '/api/user'),
        type: DioExceptionType.connectionError,
      );
      expect(authErrorCopy(offline), contains('internet connection'));
    });
  });

  group('edit profile flows', () {
    Widget wiredApp(FakeApiBackend backend) {
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              buildFakeRestClient(backend),
              // ignore: invalid_use_of_visible_for_testing_member
              TokenStorage(),
            )..state = AuthState(
                isLoggedIn: true,
                user: const User(
                    id: 1, name: 'Maria Clara', email: 'maria@example.com'),
              ),
          ),
        ],
        child: const MaterialApp(home: EditProfileScreen()),
      );
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('edit_profile_submit')));
      await tester.pumpAndSettle();
    }

    testWidgets('name-only save updates profile', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('edit_profile_name')), 'Maria Santos');
      await save(tester);

      expect(backend.putUserCallCount, 1);
      expect(backend.profileName, 'Maria Santos');
      expect(find.text('Profile updated.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('new email requests code then verifies', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('edit_profile_email')), 'new@example.com');
      await save(tester);

      expect(backend.putUserCallCount, 1);
      expect(find.textContaining('Code sent to new@example.com'),
          findsOneWidget);
      expect(find.byKey(const Key('edit_profile_resend')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('edit_profile_code')), '482916');
      await save(tester);

      expect(backend.verifyCallCount, 1);
      expect(backend.profileEmail, 'new@example.com');
      expect(find.text('Email updated.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wrong code shows mapped copy, email unchanged',
        (tester) async {
      final backend = FakeApiBackend()..failVerifyWith = 'EMAIL_CODE_MISMATCH';
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('edit_profile_email')), 'new@example.com');
      await save(tester);
      await tester.enterText(
          find.byKey(const Key('edit_profile_code')), '000000');
      await save(tester);

      expect(find.textContaining("doesn't match"), findsOneWidget);
      expect(find.textContaining('4 tries left'), findsOneWidget);
      expect(backend.profileEmail, 'maria@example.com');
      expect(tester.takeException(), isNull);
    });

    testWidgets('taken email shows mapped copy', (tester) async {
      final backend = FakeApiBackend()..failProfileWith = 'EMAIL_TAKEN';
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('edit_profile_email')), 'taken@example.com');
      await save(tester);

      expect(find.text('That email is already in use. Try another.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('resend requests a fresh code', (tester) async {
      final backend = FakeApiBackend();
      await tester.pumpWidget(wiredApp(backend));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('edit_profile_email')), 'new@example.com');
      await save(tester);
      await tester.tap(find.byKey(const Key('edit_profile_resend')));
      await tester.pumpAndSettle();

      expect(backend.resendCallCount, 1);
      expect(find.text('Code re-sent.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
