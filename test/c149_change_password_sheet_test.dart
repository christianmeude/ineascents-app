import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/change_password_screen.dart';
import 'package:inea_scents_client/screens/profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';

import 'helpers/fake_api.dart';

/// C149: Change Password mobile bottom sheet + uniform polish.
/// - Narrow (<768px): tile opens the shared sheet with the same form.
/// - Wide (≥768px): tile pushes the /profile/password route.
/// - Full code flow inside the sheet, including success.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void useViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget profileApp(FakeApiBackend backend) {
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
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('wide tile pushes /profile/password route', (tester) async {
    useViewport(tester, const Size(1024, 800));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(find.byKey(const Key('change_password_current')), findsOneWidget);
    expect(find.byKey(const Key('change_password_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet shows handle, title, and the shared form',
      (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const Key('profile_sheet_handle')), findsOneWidget);
    // Sheet title + the same form fields (route screen not pushed).
    expect(
        find.text(
          'Enter your current password, choose a new one, and confirm the 6-digit code.',
        ),
        findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
    expect(find.byType(ChangePasswordForm), findsOneWidget);
    expect(find.byKey(const Key('change_password_current')), findsOneWidget);
    expect(find.byKey(const Key('change_password_new')), findsOneWidget);
    expect(find.byKey(const Key('change_password_confirm')), findsOneWidget);
    expect(find.byKey(const Key('change_password_submit')), findsOneWidget);
    // Code section stays gated until requested (C94 parity in sheet).
    expect(find.byKey(const Key('change_password_code')), findsNothing);
    expect(find.byKey(const Key('change_password_resend')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet preserves the full code flow including success',
      (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('change_password_current')), 'current-pass-1');
    await tester.enterText(
        find.byKey(const Key('change_password_new')), 'brand-new-pass-2');
    await tester.enterText(
        find.byKey(const Key('change_password_confirm')), 'brand-new-pass-2');
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pumpAndSettle();

    // Code requested inside the sheet: gate opens, resend shows.
    expect(find.byKey(const Key('change_password_code')), findsOneWidget);
    expect(find.byKey(const Key('change_password_resend')), findsOneWidget);
    // Let the request snack expire so it never covers the submit button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('change_password_code')), '482916');
    await tester.tap(find.byKey(const Key('change_password_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Password changed.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
