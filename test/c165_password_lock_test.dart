import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inea_scents_client/screens/register_screen.dart';

/// C165: register password field stays editable — correct autofill
/// semantics (`newPassword`, never login `password`) so the browser
/// password manager cannot fight typing with autofill UI.
void main() {
  testWidgets('c165 register password uses newPassword hint', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('register_password')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.autofillHints, contains(AutofillHints.newPassword));
    expect(field.autofillHints, isNot(contains(AutofillHints.password)));

    // Editable across visibility toggles.
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('register_password')),
        matching: find.byType(TextField),
      ),
      'C0ncierge-Str0ng-77',
    );
    await tester.pump();
    expect(find.text('C0ncierge-Str0ng-77'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('register_password')),
        matching: find.byType(TextField),
      ),
      'C0ncierge-Str0ng-78',
    );
    await tester.pump();
    expect(find.text('C0ncierge-Str0ng-78'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
