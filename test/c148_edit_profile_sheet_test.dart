import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/edit_profile_screen.dart';
import 'package:inea_scents_client/screens/profile_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/profile_sheet.dart';

import 'helpers/fake_api.dart';

/// C148: Edit Profile mobile bottom sheet + uniform polish.
/// - Narrow (<768px): tile opens the shared sheet with the same form.
/// - Wide (≥768px): tile pushes the /profile/edit route.
/// - Helper: drag handle + title render, keyboard-safe scroll.
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
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
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

  testWidgets('wide tile pushes /profile/edit route', (tester) async {
    useViewport(tester, const Size(1024, 800));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_name')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet shows handle, title, and the shared form',
      (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const Key('profile_sheet_handle')), findsOneWidget);
    // Sheet title + the same form fields (route screen not pushed).
    expect(find.text('Update your name or switch to a new verified email.'),
        findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.byType(EditProfileForm), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_name')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_email')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_submit')), findsOneWidget);
    // Code section stays gated until requested (C94 parity in sheet).
    expect(find.byKey(const Key('edit_profile_code')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet preserves the gated code flow', (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(profileApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    // Logged-in name prefilled in a real session; the harness has no User.
    await tester.enterText(
        find.byKey(const Key('edit_profile_name')), 'Maria Clara');
    await tester.enterText(
        find.byKey(const Key('edit_profile_email')), 'new@example.com');
    await tester.tap(find.byKey(const Key('edit_profile_submit')));
    await tester.pumpAndSettle();

    // Code requested inside the sheet: gate opens, resend shows.
    expect(find.byKey(const Key('edit_profile_code')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_resend')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('edit_profile_code')), '482916');
    await tester.tap(find.byKey(const Key('edit_profile_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email updated.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('isNarrowSheet follows the 768px breakpoint', (tester) async {
    useViewport(tester, const Size(390, 844));
    var narrow = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            narrow = isNarrowSheet(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(narrow, isTrue);

    useViewport(tester, const Size(1024, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            narrow = isNarrowSheet(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(narrow, isFalse);

    // Boundary: 768 is wide (sheet only strictly below).
    useViewport(tester, const Size(768, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            narrow = isNarrowSheet(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(narrow, isFalse);
    expect(tester.takeException(), isNull);
  });
}
