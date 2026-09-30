import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/screens/forgot_password_screen.dart';
import 'package:inea_scents_client/screens/login_screen.dart';
import 'package:inea_scents_client/screens/reset_password_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/profile_sheet.dart';

import 'helpers/fake_api.dart';

/// C150: Forgot Password mobile bottom sheet.
/// - Narrow (<768px): link opens the shared sheet with the same form.
/// - Wide (≥768px): link pushes the /forgot-password route.
/// - Sheet submit flow requests a code then opens reset with the email.
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

  Widget loginApp(FakeApiBackend backend) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
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
      ],
    );
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('wide link pushes /forgot-password route', (tester) async {
    useViewport(tester, const Size(1024, 800));
    await tester.pumpWidget(loginApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.byType(ForgotPasswordForm), findsOneWidget);
    expect(find.byKey(const Key('forgot_password_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet shows handle, title, and the shared form',
      (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(loginApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const Key('profile_sheet_handle')), findsOneWidget);
    // Sheet title unique; the description lives once in the shared form
    // (no sheet subtitle — it would repeat in-sheet).
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(
      find.text(
          'Enter your email address to receive a 6-digit reset code.'),
      findsOneWidget,
    );
    expect(find.byType(ForgotPasswordScreen), findsNothing);
    expect(find.byType(ForgotPasswordForm), findsOneWidget);
    expect(find.byKey(const Key('forgot_password_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet submit flow opens reset with the email', (tester) async {
    useViewport(tester, const Size(390, 844));
    final backend = FakeApiBackend();
    await tester.pumpWidget(loginApp(backend));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    // Sheet field renders above the login fields (last in tree).
    await tester.enterText(find.byType(TextField).last, 'maria@example.com');
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

  testWidgets('sheet BACK TO LOGIN closes the sheet', (tester) async {
    useViewport(tester, const Size(390, 844));
    await tester.pumpWidget(loginApp(FakeApiBackend()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    // C150: pop-or-go — closes the sheet onto login, never orphans it.
    await tester.tap(find.text('BACK TO LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Forgot password?'), findsOneWidget);
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
