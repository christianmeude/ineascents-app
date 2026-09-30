import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/screens/change_password_screen.dart';
import 'package:inea_scents_client/screens/profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C39: /profile/password scaffold — route resolves, four C15-mirror
/// fields render, inline validation fires. C15 wires submit to A7;
/// full request/code/change flows live in c15_change_password_test.dart.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget screenApp() {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(FakeApiBackend()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ChangePasswordScreen(),
      ),
    );
  }

  group('ChangePasswordValidators', () {
    test('current requires value with min length', () {
      expect(
        ChangePasswordValidators.validateCurrent(''),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateCurrent('short'),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateCurrent('current-pass-1'),
        isNull,
      );
    });

    test('new requires min length and must differ from current', () {
      expect(
        ChangePasswordValidators.validateNew('', 'current-pass-1'),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateNew('short', 'current-pass-1'),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateNew(
          'current-pass-1',
          'current-pass-1',
        ),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateNew('brand-new-pass-2', 'current-pass-1'),
        isNull,
      );
    });

    test('confirm must match new', () {
      expect(
        ChangePasswordValidators.validateConfirm('', 'brand-new-pass-2'),
        isNotNull,
      );
      expect(
        ChangePasswordValidators.validateConfirm(
          'other-pass-3',
          'brand-new-pass-2',
        ),
        'Passwords do not match.',
      );
      expect(
        ChangePasswordValidators.validateConfirm(
          'brand-new-pass-2',
          'brand-new-pass-2',
        ),
        isNull,
      );
    });

    test('code must be 6 digits', () {
      expect(ChangePasswordValidators.validateCode(''), isNotNull);
      expect(ChangePasswordValidators.validateCode('12345'), isNotNull);
      expect(ChangePasswordValidators.validateCode('1234567'), isNotNull);
      expect(ChangePasswordValidators.validateCode('abc123'), isNotNull);
      expect(ChangePasswordValidators.validateCode('123456'), isNull);
    });
  });

  testWidgets('wired screen renders four fields with enabled submit', (
    tester,
  ) async {
    await tester.pumpWidget(screenApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('change_password_current')), findsOneWidget);
    expect(find.byKey(const Key('change_password_new')), findsOneWidget);
    expect(find.byKey(const Key('change_password_confirm')), findsOneWidget);
    // C94: code section stays hidden until a code is requested.
    expect(find.byKey(const Key('change_password_code')), findsNothing);
    expect(find.byKey(const Key('change_password_resend')), findsNothing);

    final submit = tester.widget<ElevatedButton>(
      find.byKey(const Key('change_password_submit')),
    );
    expect(submit.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline validation flags mismatch and bad code', (
    tester,
  ) async {
    await tester.pumpWidget(screenApp());
    await tester.pumpAndSettle();

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
      'other-pass-3',
    );
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('change_password_confirm')),
      'brand-new-pass-2',
    );
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pumpAndSettle();

    // C94: code section appears only after the request succeeds.
    expect(find.byKey(const Key('change_password_code')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('change_password_code')),
      '12ab',
    );
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Code must be 6 digits.'), findsOneWidget);

    final submit = tester.widget<ElevatedButton>(
      find.byKey(const Key('change_password_submit')),
    );
    expect(submit.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile Change Password tile opens bottom sheet on narrow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(
            buildFakeRestClient(FakeApiBackend()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // C39: no deferred note on the tile anymore.
    expect(find.text('Deferred — available in C15'), findsNothing);
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    // C149: narrow (<768px) presents the shared sheet with the same form —
    // the route is not pushed.
    expect(find.byType(ChangePasswordScreen), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const Key('change_password_current')), findsOneWidget);
    expect(find.byKey(const Key('change_password_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
