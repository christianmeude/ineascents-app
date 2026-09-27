import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/widgets/gated_code_section.dart';

/// C94: shared gate hides the code field until a code is requested.
void main() {
  Widget sectionApp({
    required bool codeSent,
    required bool sending,
    required void Function() onResend,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GatedCodeSection(
          codeSent: codeSent,
          field: const TextField(key: Key('probe_code')),
          sending: sending,
          onResend: onResend,
          resendKey: const Key('probe_resend'),
        ),
      ),
    );
  }

  testWidgets('hides field and resend before a code is sent', (tester) async {
    await tester.pumpWidget(
      sectionApp(codeSent: false, sending: false, onResend: () {}),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('probe_code')), findsNothing);
    expect(find.byKey(const Key('probe_resend')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows field and working resend after a code is sent',
      (tester) async {
    var resends = 0;
    await tester.pumpWidget(
      sectionApp(
        codeSent: true,
        sending: false,
        onResend: () => resends++,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('probe_code')), findsOneWidget);
    await tester.tap(find.byKey(const Key('probe_resend')));
    expect(resends, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disables resend while sending', (tester) async {
    await tester.pumpWidget(
      sectionApp(codeSent: true, sending: true, onResend: () {}),
    );
    await tester.pumpAndSettle();

    final resend = tester.widget<TextButton>(
      find.byKey(const Key('probe_resend')),
    );
    expect(resend.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
