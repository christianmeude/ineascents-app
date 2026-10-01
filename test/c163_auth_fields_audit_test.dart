import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/login_screen.dart';
import 'package:inea_scents_client/screens/register_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C163: auth fields audit — every auth field stays editable on every open,
/// the visibility toggle never drops text, and focus survives provider
/// rebuilds (e.g. an in-card error appearing above the fields).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('C163 login fields', () {
    testWidgets('email+password editable, toggle intact, focus survives churn',
        (tester) async {
      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          authProvider.overrideWith(
            (ref) => AuthNotifier(buildFakeRestClient(backend), storage),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final emailField = find.byKey(const Key('login_email'));
      final passwordField = find.byKey(const Key('login_password'));
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      // Every open: both fields accept input.
      await tester.enterText(fields.at(0), 'maria@example.com');
      await tester.enterText(fields.at(1), 'secret-pass-1');
      await tester.pump();
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(find.text('secret-pass-1'), findsOneWidget);

      // Visibility toggle twice: text intact, still editable.
      final toggle = find.byType(IconButton);
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(find.text('secret-pass-1'), findsOneWidget);
      await tester.enterText(fields.at(1), 'secret-pass-2');
      await tester.pump();
      expect(find.text('secret-pass-2'), findsOneWidget);

      // Focus the password field, then churn provider state (in-card error
      // appears above the fields) — text persists, input still accepted,
      // and focus stays in the field.
      await tester.enterText(fields.at(1), 'secret-pass-1');
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText).at(1))
            .focusNode.hasFocus,
        isTrue,
      );
      container.read(authProvider.notifier).state = container
          .read(authProvider)
          .copyWith(errorMessage: "That didn't work. Check your details.");
      await tester.pumpAndSettle();

      expect(find.text('maria@example.com'), findsOneWidget);
      expect(find.text('secret-pass-1'), findsOneWidget);
      await tester.enterText(fields.at(1), 'secret-pass-3');
      await tester.pump();
      expect(find.text('secret-pass-3'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText).at(1))
            .focusNode.hasFocus,
        isTrue,
        reason: 'password field must keep focus across provider rebuilds',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('C163 register fields', () {
    testWidgets('name+email+password editable, toggle intact, focus survives',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend();
      final storage = _MemoryTokenStorage();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
          authProvider.overrideWith(
            (ref) => AuthNotifier(buildFakeRestClient(backend), storage),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final name = find.byKey(const Key('register_name'));
      final email = find.byKey(const Key('register_email'));
      final password = find.byKey(const Key('register_password'));
      expect(name, findsOneWidget);
      expect(email, findsOneWidget);
      expect(password, findsOneWidget);

      await tester.enterText(name, 'Maria Clara');
      await tester.enterText(email, 'maria@example.com');
      await tester.enterText(password, 'secret-pass-1');
      await tester.pump();
      expect(find.text('Maria Clara'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(find.text('secret-pass-1'), findsOneWidget);

      final toggle = find.byType(IconButton);
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(find.text('secret-pass-1'), findsOneWidget);
      await tester.enterText(password, 'secret-pass-2');
      await tester.pump();
      expect(find.text('secret-pass-2'), findsOneWidget);

      await tester.enterText(password, 'secret-pass-1');
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.descendant(
          of: password,
          matching: find.byType(EditableText),
        )).focusNode.hasFocus,
        isTrue,
      );
      container.read(authProvider.notifier).state = container
          .read(authProvider)
          .copyWith(errorMessage: "That didn't work. Check your details.");
      await tester.pumpAndSettle();

      expect(find.text('Maria Clara'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(find.text('secret-pass-1'), findsOneWidget);
      await tester.enterText(password, 'secret-pass-3');
      await tester.pump();
      expect(find.text('secret-pass-3'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.descendant(
          of: password,
          matching: find.byType(EditableText),
        )).focusNode.hasFocus,
        isTrue,
        reason: 'password field must keep focus across provider rebuilds',
      );
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
