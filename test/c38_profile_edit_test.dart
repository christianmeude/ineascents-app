import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/api/models/user.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/edit_profile_screen.dart';
import 'package:inea_scents_client/screens/profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C38 scaffold superseded by C14 wiring: route resolves, fields validate
/// inline, submit enabled. Validators live in the screen file.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('validators', () {
    test('name requires 2+ chars', () {
      expect(validateProfileName(''), 'Enter your name');
      expect(validateProfileName('A'), 'Name must be at least 2 characters');
      expect(validateProfileName('Maria'), isNull);
    });

    test('email optional but must be valid when filled', () {
      expect(validateProfileEmail(''), isNull);
      expect(validateProfileEmail('nope'), 'Enter a valid email address');
      expect(validateProfileEmail('a@b.co'), isNull);
    });

    test('code required once requested, 6 digits when filled', () {
      expect(validateProfileCode('', true), 'Enter the 6-digit code');
      expect(validateProfileCode('', false), isNull);
      expect(validateProfileCode('123', false), 'Code must be 6 digits');
      expect(validateProfileCode('123456', true), isNull);
    });
  });

  Widget editApp() {
    final backend = FakeApiBackend();
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
      ],
      child: const MaterialApp(home: EditProfileScreen()),
    );
  }

  testWidgets('edit screen renders fields, submit enabled', (tester) async {
    await tester.pumpWidget(editApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit_profile_name')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_email')), findsOneWidget);
    // C94: code section stays hidden until a code is requested.
    expect(find.byKey(const Key('edit_profile_code')), findsNothing);
    expect(find.byKey(const Key('edit_profile_resend')), findsNothing);

    final submit =
        tester.widget<ElevatedButton>(find.byKey(const Key('edit_profile_submit')));
    expect(submit.onPressed, isNotNull);

    expect(find.textContaining('C14'), findsNothing);
    expect(find.textContaining('C15'), findsNothing);
    expect(find.textContaining('Deferred'), findsNothing);
    expect(find.textContaining('TODO'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid input shows inline errors', (tester) async {
    await tester.pumpWidget(editApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('edit_profile_name')), 'A');
    await tester.enterText(
        find.byKey(const Key('edit_profile_email')), 'not-an-email');
    await tester.pumpAndSettle();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('edit_profile_email')), 'new@example.com');
    await tester.pumpAndSettle();
    // C94: no code field before a request, so no code error either.
    expect(find.byKey(const Key('edit_profile_code')), findsNothing);
    expect(find.text('Code must be 6 digits'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('name prefills from current user', (tester) async {
    final backend = FakeApiBackend();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              buildFakeRestClient(backend),
              // ignore: invalid_use_of_visible_for_testing_member
              TokenStorage(),
            )..state = AuthState(
                isLoggedIn: true,
                user: const User(name: 'Maria Clara', email: 'maria@x.co'),
              ),
          ),
        ],
        child: const MaterialApp(home: EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maria Clara'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile Edit tile opens bottom sheet on narrow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final backend = FakeApiBackend();
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    // C148: narrow (<768px) presents the shared sheet with the same form —
    // the route is not pushed.
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_name')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
