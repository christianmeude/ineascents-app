import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/widgets/error_banner.dart';

/// C164: zero SnackBar on web — overlay banner carries copy + Retry.
void main() {
  testWidgets('c164 web shows overlay banner, never SnackBar', (tester) async {
    debugForceWebBanner = true;
    addTearDown(() => debugForceWebBanner = null);

    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppError(
                context,
                message: 'Connection failed',
                transient: true,
                onRetry: () => retried = true,
              ),
              child: const Text('boom'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('boom'));
    await tester.pump();

    expect(find.byKey(const Key('web_banner_message')), findsOneWidget);
    expect(find.text('Connection failed'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.byKey(const Key('web_banner_action')));
    await tester.pump();
    expect(retried, isTrue);
    expect(find.byKey(const Key('web_banner_message')), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('c164 web notice renders banner without action', (tester) async {
    debugForceWebBanner = true;
    addTearDown(() => debugForceWebBanner = null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showAppNotice(context, message: 'Saved successfully'),
              child: const Text('save'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('save'));
    await tester.pump();

    expect(find.text('Saved successfully'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byKey(const Key('web_banner_action')), findsNothing);

    await tester.tap(find.byKey(const Key('web_banner_dismiss')));
    await tester.pump();
    expect(find.text('Saved successfully'), findsNothing);

    expect(tester.takeException(), isNull);
  });
}
