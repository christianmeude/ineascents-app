import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inea_scents_client/config/theme.dart';
import 'package:inea_scents_client/models/index.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/screens/booking_screen.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/widgets/index.dart';

import 'helpers/fake_api.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testPackage = Package(
    id: 42,
    name: 'Dior Women Luxury Experience',
    description:
        'A luxurious custom perfume bar experience designed for weddings, birthdays, and celebrations.',
    price: 4500.0,
    rating: 4.9,
    reviewsCount: 184,
    inclusions: [
      'Featuring your logo',
      '4 Inspired scents',
      'Perfume Bar Setup',
      'Claim Stub',
      '2 staff members',
    ],
    freebies: ['Selfie Mirror', '1 Gift for Celebrant'],
    paxOptions: [20, 30, 50, 75, 100],
    images: ['https://example.com/luxury_package.jpg'],
  );

  Widget createBookingScreenWidget({
    required Size screenSize,
    int packageId = 42,
    Package? package,
    FakeApiBackend? backend,
    ProviderContainer? container,
  }) {
    final child = MaterialApp(
      theme: AppTheme.lightTheme,
      home: ResponsiveAppShell(child: BookingScreen(packageId: packageId)),
    );
    // C169: tests that drive the UI proceed gates pass a seeded
    // container (one Scent chosen); otherwise a plain ProviderScope.
    if (container != null) {
      return UncontrolledProviderScope(container: container, child: child);
    }
    return ProviderScope(
      overrides: [
        packageDetailsProvider(
          packageId,
        ).overrideWith((ref) => package ?? testPackage),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(backend ?? FakeApiBackend()),
        ),
      ],
      child: child,
    );
  }

  /// C169: seeded flow container — one Scent chosen (as the Package
  /// detail shelf would) so the UI proceed gates pass. Tests that
  /// assert POSTs pass their own [backend] to inspect it.
  ProviderContainer c169SeededContainer({
    Package? package,
    FakeApiBackend? backend,
    int packageId = 42,
  }) {
    final container = ProviderContainer(
      overrides: [
        packageDetailsProvider(
          packageId,
        ).overrideWith((ref) => package ?? testPackage),
        apiClientProvider.overrideWithValue(
          buildFakeRestClient(backend ?? FakeApiBackend()),
        ),
      ],
    );
    container.read(bookingFlowProvider.notifier).toggleScent(1);
    return container;
  }

  /// Fills the contact fields on the mobile Step 3 (Details) view.
  Future<void> fillMobileContacts(WidgetTester tester) async {
    const fields = {
      'mobile_customer_name': 'Maria Clara',
      'mobile_customer_email': 'maria@example.com',
      'mobile_customer_phone': '+639171234567',
      'mobile_venue_address': 'The Peninsula Manila',
    };
    for (final entry in fields.entries) {
      final finder = find.byKey(Key(entry.key));
      await tester.ensureVisible(finder);
      await tester.enterText(finder, entry.value);
      await tester.pump();
    }
  }

  /// Fills the C74 web Details form (desktop/tablet step 3) fields.
  Future<void> fillWebDetailsContacts(
    WidgetTester tester,
    String prefix,
  ) async {
    final fields = {
      '${prefix}_customer_name': 'Maria Clara',
      '${prefix}_customer_email': 'maria@example.com',
      '${prefix}_customer_phone': '+639171234567',
      '${prefix}_venue_address': 'The Peninsula Manila',
    };
    for (final entry in fields.entries) {
      final finder = find.byKey(Key(entry.key));
      await tester.ensureVisible(finder);
      await tester.enterText(finder, entry.value);
      await tester.pump();
    }
  }

  /// C74: drives a desktop/tablet flow from Schedule (2) through
  /// Details (3) to Payment (4). Schedule-proceed must land on 3
  /// (never 4): asserts the details view, fills it, then proceeds
  /// to the payment panel.
  Future<void> driveWebToPayment(
    WidgetTester tester, {
    required String detailsViewKey,
    required String prefix,
    required String paymentViewKey,
  }) async {
    final first = find.text('Proceed to Payment');
    await tester.ensureVisible(first);
    await tester.pumpAndSettle();
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(find.byKey(Key(detailsViewKey)), findsOneWidget);
    expect(find.byKey(Key(paymentViewKey)), findsNothing);
    await fillWebDetailsContacts(tester, prefix);
    final second = find.text('Proceed to Payment');
    await tester.ensureVisible(second);
    await tester.pumpAndSettle();
    await tester.tap(second);
    await tester.pumpAndSettle();
    expect(find.byKey(Key(paymentViewKey)), findsOneWidget);
  }

  group('Issue #44: 3-Column Reservation Flow Layout Tests', () {
    testWidgets(
      // C92: desktop schedule is one "Select Date & Time" card (calendar
      // inner col 1 + time inner col 2) + sticky summary rail (col 3);
      // no Pax UI, no event recap — the rail owns that line.
      'R1: Desktop Split View renders 2-column layout on 1200x800 viewport (>1024px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Verify flow column + summary column are rendered
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('event_time_picker_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );

        // Verify desktop header shows the unified timeline (C27)

        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);

        // Layout coordinate verification:
        // Calendar left of time inside the card; both left of the rail.
        final calendarRect = tester.getRect(
          find.byKey(const Key('reservation_calendar_panel')),
        );
        final timeRect = tester.getRect(
          find.byKey(const Key('event_time_picker_button')),
        );
        final summaryPos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );

        expect(calendarRect.left, lessThan(timeRect.left));
        expect(timeRect.right, lessThanOrEqualTo(summaryPos.dx));

        // Verify contents inside the flow column (Calendar + time)
        expect(find.text('Select Date & Time'), findsOneWidget);
        expect(find.text('Available'), findsNothing);
        expect(find.text('Booked'), findsNothing);

        // C92: no Pax UI, no event recap in Schedule (rail owns it).
        expect(find.byKey(const Key('schedule_pax_header')), findsNothing);
        expect(find.byKey(const Key('schedule_event_summary')), findsNothing);
        expect(find.byKey(const Key('pax_readonly_row')), findsNothing);
        expect(find.text('Dior Women Luxury Experience'), findsWidgets);
        expect(find.text('Choose Event Time'), findsOneWidget);
        // C18 pay-once: schedule step carries no payment picker.
        expect(find.text('Payment Method'), findsNothing);

        // Verify contents inside Right column (Sticky Order Summary) — C75 distilled
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.textContaining('PAX'), findsWidgets);
        expect(find.text('7 inclusions'), findsOneWidget);
        expect(find.text('Proceed to Payment'), findsOneWidget);
        expect(find.text('₱4,500.00'), findsOneWidget);
      },
    );

    testWidgets(
      // C92: desktop Schedule is fixed — no page-level scroll. The rail
      // holds position trivially (nothing scrolls) and the CTA is
      // reachable without scrolling.
      'R1: Sticky summary rail holds position with no page scroll on desktop',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // C92: desktop Schedule carries no page-level scroll.
        final pageScrollFinder = find.byKey(const Key('app_shell_scroll_view'));
        expect(pageScrollFinder, findsNothing);

        // Check initial position of Order Summary panel
        final initialSummaryPos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );

        // A drag on the rail goes nowhere — the layout is fixed.
        final summaryCenter = tester.getCenter(
          find.byKey(const Key('order_summary_side_panel')),
        );
        await tester.dragFrom(summaryCenter, const Offset(0, -300));
        await tester.pumpAndSettle();

        // Rail holds position; CTA stays reachable with no scroll.
        final scrolledSummaryPos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );
        expect(scrolledSummaryPos.dy, equals(initialSummaryPos.dy));
        expect(scrolledSummaryPos.dx, equals(initialSummaryPos.dx));
        expect(find.text('Proceed to Payment'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'R2: Tablet View renders 2-column layout on 800x800 viewport (768px - 1024px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(800, 800)),
        );
        await tester.pumpAndSettle();

        // On tablet: Tablet specific panels are rendered
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(find.byKey(const Key('tablet_details_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );

        // Desktop 3-column specific keys are not rendered
        expect(find.byKey(const Key('order_summary_side_panel')), findsNothing);

        // Verify 2-column horizontal coordinate ordering: Left column < Right column
        final leftPos = tester.getTopLeft(
          find.byKey(const Key('tablet_calendar_panel')),
        );
        final rightPos = tester.getTopLeft(
          find.byKey(const Key('tablet_order_summary_panel')),
        );
        expect(leftPos.dx, lessThan(rightPos.dx));
      },
    );

    testWidgets(
      'R2: Mobile View renders 1-column vertical step flow on 375x667 viewport (<768px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(375, 667)),
        );
        await tester.pumpAndSettle();

        // On mobile: Timeline and mobile scroll view are rendered
        expect(find.byKey(const Key('app_shell_scroll_view')), findsOneWidget);
        expect(find.text('Schedule'), findsWidgets);
        // C48: conversion lives in the sticky bottom bar (h50 pill),
        // outside the scroll — the in-column CTA is retired.
        expect(find.text('Proceed'), findsOneWidget);

        // Desktop/tablet 3-column & 2-column keys are not rendered
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsNothing,
        );
        expect(find.byKey(const Key('order_summary_side_panel')), findsNothing);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsNothing,
        );
      },
    );

    testWidgets(
      // C92: headcount is chosen on the packages grid and travels via
      // `?pax=`; the Schedule step carries no Pax UI at all — the rail
      // owns the locked headcount echo.
      'Pax preselection renders locked with no Change link on desktop',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // No Pax UI left in Schedule (silent first-option fallback: no
        // `?pax=` was passed, so the rail echoes 20).
        expect(find.text('Dior Women Luxury Experience'), findsWidgets);
        expect(find.byKey(const Key('schedule_pax_header')), findsNothing);
        expect(find.byKey(const Key('pax_readonly_row')), findsNothing);
        expect(find.byKey(const Key('pax_change_link')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('order_summary_side_panel')),
            matching: find.text('20 PAX'),
          ),
          findsOneWidget,
        );

        // No in-flow pax selectors remain (the summary echo of the
        // locked step is expected).
        expect(find.text('2. Choose Available Pax'), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('schedule_datetime_card')),
            matching: find.textContaining('Guests'),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Freeform time picker updates Order Summary in real-time on desktop',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Picker shows the current time with the duration hint
        expect(find.text('Choose Event Time'), findsOneWidget);
        expect(find.text('One booking lasts 3–4 hrs.'), findsOneWidget);
        expect(find.text('2:00 PM'), findsWidgets);

        // Opening the picker surfaces the clock dialog; cancelling keeps time
        // (P6: details sit lower in the merged flow column — reveal first).
        await tester.ensureVisible(
          find.byKey(const Key('event_time_picker_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('event_time_picker_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('event_time_picker_button')));
        await tester.pumpAndSettle();
        expect(find.byType(TimePickerDialog), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(TimePickerDialog), findsNothing);
        expect(find.text('2:00 PM'), findsWidgets);
      },
    );

    testWidgets(
      'Interactive Payment Method toggle updates Order Summary in real-time on desktop',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Retired method is gone from every picker (owner Q14-B).
        expect(find.text('Bank Transfer'), findsNothing);

        // C92: schedule step carries no picker and no Pax UI — pick
        // once at the payment step instead.
        expect(
          find.descendant(
            of: find.byKey(const Key('schedule_datetime_card')),
            matching: find.text('Cash'),
          ),
          findsNothing,
        );

        // C74: Schedule → Details → Payment (no direct jump).
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Select 'Cash' in the payment panel (scoped: the summary
        // column renders the method label too).
        final cashFinder = find.descendant(
          of: find.byKey(const Key('desktop_payment_panel_view')),
          matching: find.text('Cash'),
        );
        await tester.ensureVisible(cashFinder);
        await tester.pumpAndSettle();
        expect(cashFinder, findsOneWidget);
        await tester.tap(cashFinder);
        await tester.pumpAndSettle();

        // Verify Order Summary still renders the distilled Pax row (payment chip removed per C)
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);
      },
    );

    testWidgets(
      'Proceed to Payment and Confirm & Pay completes desktop flow and renders Payment Successful view',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Schedule → Details → Payment (no direct jump).
        // Tap 'Proceed to Payment' in sticky Order Summary panel
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // C77: contact details already filled at step 3 (driveWebToPayment).

        // Tap 'Confirm & Pay' on payment step
        final confirmButtonFinder = find.textContaining('Confirm & Pay');
        expect(confirmButtonFinder, findsOneWidget);
        await tester.tap(confirmButtonFinder);
        await tester.pumpAndSettle();

        // Verify Payment Successful screen appears
        expect(find.text('Payment Successful'), findsOneWidget);
        expect(find.text('Thank you for your booking.'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'Dynamic resize smoothly transitions 2-column -> 2-column -> 1-column without errors',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // 1. Desktop mode (1200px) -> 3 columns
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );

        // 2. Resize to Tablet (900px) -> 2 columns
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('order_summary_side_panel')), findsNothing);

        // 3. Resize to Mobile (375px) -> 1 column
        tester.view.physicalSize = const Size(375, 667);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('app_shell_scroll_view')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsNothing,
        );

        // 4. Resize back to Ultra-wide Desktop (1600px) -> 3 columns
        tester.view.physicalSize = const Size(1600, 900);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Interactive Date selection in calendar updates Order Summary date',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Find calendar panel
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );

        // Tap on a day cell in the TableCalendar (e.g. day 15)
        final day15Finder = find.descendant(
          of: find.byKey(const Key('reservation_calendar_panel')),
          matching: find.text('15'),
        );
        if (day15Finder.evaluate().isNotEmpty) {
          await tester.tap(day15Finder.first);
          await tester.pumpAndSettle();

          // Verify Order Summary Pax row updated (C75 distilled, label-value rows)
          expect(find.text('Your Booking'), findsOneWidget);
          expect(find.byKey(const Key('summary_value_pax')), findsWidgets);
        }
      },
    );

    testWidgets('Handles loading and error retry states cleanly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packageDetailsProvider(
              99,
            ).overrideWith((ref) => throw Exception('Network timeout')),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResponsiveAppShell(child: BookingScreen(packageId: 99)),
          ),
        ),
      );
      await tester.pump();

      // P6 (Q6/Q8): shared friendly card — plain copy plus a
      // single Try Again action, raw errors never rendered.
      expect(find.text("We couldn't open this booking"), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.textContaining('Network timeout'), findsNothing);
    });

    testWidgets(
      // P6: desktop is 2-column (flow + summary).
      '2-Column Desktop view renders robustly under 2.0x accessibility text scale',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              packageDetailsProvider(42).overrideWith((ref) => testPackage),
              apiClientProvider.overrideWithValue(
                buildFakeRestClient(FakeApiBackend()),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: child!,
                );
              },
              home: const ResponsiveAppShell(
                child: BookingScreen(packageId: 42),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify no crashes occur and layout renders
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('event_time_picker_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Exact breakpoint boundary threshold verification (1025px vs 1024px, 769px vs 768px vs 767px)',
      (WidgetTester tester) async {
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // 1. 1025px (>1024px) -> Desktop fixed schedule card (C92)
        tester.view.physicalSize = const Size(1025, 800);
        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(1025, 800)),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('event_time_picker_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('app_shell_scroll_view')), findsNothing);

        // 2. 1024px (== tabletBreakpoint) -> Tablet 2-Column
        tester.view.physicalSize = const Size(1024, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(find.byKey(const Key('tablet_details_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('order_summary_side_panel')), findsNothing);

        // 3. 769px (Tablet range) -> Tablet 2-Column
        tester.view.physicalSize = const Size(769, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );

        // 4. 768px (== mobileBreakpoint) -> Tablet 2-Column
        tester.view.physicalSize = const Size(768, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );

        // 5. 767px (<768px) -> Mobile 1-Column
        tester.view.physicalSize = const Size(767, 800);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('app_shell_scroll_view')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsNothing,
        );
        expect(find.byKey(const Key('order_summary_side_panel')), findsNothing);
      },
    );

    testWidgets(
      'Rapid boundary oscillation retains selection state across 1023px <-> 1025px & 767px <-> 769px',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C92: no Pax UI in Schedule — the rail echoes the locked step.
        // C18 pay-once: the schedule step carries no payment picker.
        expect(find.byKey(const Key('pax_readonly_row')), findsNothing);
        expect(find.byKey(const Key('pax_change_link')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('order_summary_side_panel')),
            matching: find.text('20 PAX'),
          ),
          findsOneWidget,
        );

        // Freeform time keeps its default through selection changes
        expect(find.text('2:00 PM'), findsWidgets);

        expect(
          find.descendant(
            of: find.byKey(const Key('schedule_datetime_card')),
            matching: find.text('Cash'),
          ),
          findsNothing,
        );

        // C74: Pick Cash once at the payment step (via Details),
        // then continue below.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );
        final cashFinder = find.descendant(
          of: find.byKey(const Key('desktop_payment_panel_view')),
          matching: find.text('Cash'),
        );
        await tester.ensureVisible(cashFinder);
        await tester.pumpAndSettle();
        await tester.tap(cashFinder);
        await tester.pumpAndSettle();

        // Stepwise back to Schedule (4→3 Details, then 3→2; mobile
        // parity) for the oscillation below.
        final backToDetailsFirst = find.text('Back');
        await tester.ensureVisible(backToDetailsFirst);
        await tester.pumpAndSettle();
        await tester.tap(backToDetailsFirst);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );

        final backToSchedule = find.text('Back');
        await tester.ensureVisible(backToSchedule);
        await tester.pumpAndSettle();
        await tester.tap(backToSchedule);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );

        expect(find.byKey(const Key('summary_value_pax')), findsWidgets);
        expect(find.text('20 PAX'), findsWidgets);

        // Oscillate across desktop/tablet boundary multiple times (P7 C: payment chip removed, verify distilled summary persists)
        for (int i = 0; i < 3; i++) {
          tester.view.physicalSize = const Size(1023, 800); // Tablet
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('tablet_order_summary_panel')),
            findsOneWidget,
          );
          expect(find.text('Your Booking'), findsOneWidget);
          expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);

          tester.view.physicalSize = const Size(1025, 800); // Desktop
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('order_summary_side_panel')),
            findsOneWidget,
          );
          expect(find.text('Your Booking'), findsOneWidget);
          expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);
        }

        // Oscillate across tablet/mobile boundary multiple times
        for (int i = 0; i < 3; i++) {
          tester.view.physicalSize = const Size(767, 800); // Mobile
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('app_shell_scroll_view')),
            findsOneWidget,
          );

          tester.view.physicalSize = const Size(769, 800); // Tablet
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('tablet_order_summary_panel')),
            findsOneWidget,
          );
          expect(find.text('Your Booking'), findsOneWidget);
          expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Calendar range safety and navigation without assertion crashes',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(
                buildFakeRestClient(FakeApiBackend()),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: SizedBox(
                  width: 380,
                  child: ReservationCalendarPanel(
                    selectedDate: DateTime.utc(2026, 9, 15),
                    onDateSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Select Date'), findsOneWidget);

        // Navigate calendar month using next chevron
        final nextChevronFinder = find.byIcon(Icons.chevron_right_rounded);
        expect(nextChevronFinder, findsOneWidget);
        await tester.tap(nextChevronFinder);
        await tester.pumpAndSettle();

        // Navigate calendar month back using previous chevron
        final prevChevronFinder = find.byIcon(Icons.chevron_left_rounded);
        expect(prevChevronFinder, findsOneWidget);
        await tester.tap(prevChevronFinder);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'OrderSummaryPanel and ReservationDetailsPanel handle bare/null package data gracefully',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const minimalPackage = Package(
          id: 1,
          name: null,
          description: null,
          price: null,
          images: null,
          inclusions: null,
          freebies: null,
          paxOptions: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: ReservationDetailsPanel(
                      package: minimalPackage,
                      selectedPax: null,
                      onChangePax: () {},
                      selectedTime: null,
                      onTimeSelected: (_) {},
                    ),
                  ),
                  Expanded(
                    child: OrderSummaryPanel(
                      package: minimalPackage,
                      selectedDate: null,
                      selectedTime: null,
                      selectedPax: null,
                      paymentMethod: null,
                      isLoading: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify null fallbacks — C75 distilled (five label-value rows, count caption, `₱` only)
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.text('No inclusions listed'), findsOneWidget);
        expect(find.text('₱4,500.00'), findsOneWidget);
        expect(find.textContaining('Not selected'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      // P6: mobile Step 2 keeps date + time pickers; pax is read-only.
      'Mobile 1-column step flow allows date, details, payment selection and completes to success screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(375, 667),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Step 2: Schedule (C92: date + time pickers, no Pax UI)

        expect(find.text('Dior Women Luxury Experience'), findsWidgets);
        expect(find.byKey(const Key('pax_readonly_row')), findsNothing);
        expect(find.byKey(const Key('pax_change_link')), findsNothing);
        expect(find.text('30 PAX'), findsNothing);

        // Tap Proceed (sticky bottom bar, outside the scroll) for Step 3.
        await tester.tap(find.text('Proceed'));
        await tester.pumpAndSettle();

        // Step 3: Details

        expect(find.text('Proceed to Payment'), findsOneWidget);

        // Fill mobile contact & venue information required for submission
        await fillMobileContacts(tester);

        // Tap Proceed to Payment (sticky bottom bar) to go to Step 4
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // Step 4: Payment
        expect(find.text('Price Details'), findsOneWidget);
        expect(find.text('Choose Payment Method'), findsOneWidget);
        final cardFinder = find.text('Online');
        await tester.scrollUntilVisible(
          cardFinder,
          100,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('app_shell_scroll_view')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(cardFinder, findsOneWidget);
        await tester.tap(cardFinder);
        await tester.pumpAndSettle();

        expect(find.textContaining('Confirm & Pay'), findsOneWidget);
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();

        // Step 5: Success screen
        expect(find.text('Payment Successful'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile step flow supports interactive time slot selection and back navigation without placeholder steps',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(375, 667),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Step 2: freeform time picker shows the default with duration hint
        expect(find.text('Choose Event Time'), findsOneWidget);
        expect(find.text('One booking lasts 3–4 hrs.'), findsOneWidget);
        final pickerFinder = find.byKey(const Key('event_time_picker_button'));
        await tester.scrollUntilVisible(
          pickerFinder,
          100,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('app_shell_scroll_view')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(pickerFinder, findsOneWidget);
        expect(find.text('2:00 PM'), findsWidgets);

        // Advance to Step 3 (Details) via the sticky bottom bar.
        await tester.tap(find.text('Proceed'));
        await tester.pumpAndSettle();

        // Verify selected time and pax are displayed in Details
        expect(find.text('Selected Time:'), findsOneWidget);
        expect(find.text('2:00 PM'), findsWidgets);
        expect(find.text('Selected Pax:'), findsOneWidget);

        await fillMobileContacts(tester);

        // Advance to Step 4 (Payment)
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        expect(find.text('Price Details'), findsOneWidget);

        // Test Back button from Step 4 -> returns to Step 3
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Test Back button from Step 3 -> returns to Step 2
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Verify no placeholder text "Step 1 details here" appears anywhere
        expect(find.textContaining('details here'), findsNothing);
      },
    );

    testWidgets(
      'OrderSummaryPanel and ReservationCalendarPanel handle future dates up to 2035 with clamping',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Future date in year 2034
        final futureDate = DateTime.utc(2034, 6, 15);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(
                buildFakeRestClient(FakeApiBackend()),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Row(
                  children: [
                    Expanded(
                      child: ReservationCalendarPanel(
                        selectedDate: futureDate,
                        onDateSelected: (_) {},
                      ),
                    ),
                    Expanded(
                      child: OrderSummaryPanel(
                        package: testPackage,
                        selectedDate: futureDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('summary_value_date')), findsOneWidget);
        expect(find.text('Thursday, June 15, 2034'), findsWidgets);
      },
    );

    testWidgets(
      'OrderSummaryPanel handles long inclusion strings and text scaling without overflows',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final extraLongPackage = testPackage.copyWith(
          inclusions: [
            'Extremely long bespoke custom luxury fragrance bar formulation with personalized crystal flacon engraving',
            'VIP Master perfumer consultations and custom ribbon packaging for all guests',
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1200, 800),
                textScaler: TextScaler.linear(1.5),
              ),
              child: Scaffold(
                body: SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    child: OrderSummaryPanel(package: extraLongPackage),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.text('4 inclusions'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('BookingScreen renders cleanly in Dark Theme', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packageDetailsProvider(42).overrideWith((ref) => testPackage),
            apiClientProvider.overrideWithValue(
              buildFakeRestClient(FakeApiBackend()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ResponsiveAppShell(child: BookingScreen(packageId: 42)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('reservation_calendar_panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('schedule_datetime_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('order_summary_side_panel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      // P7: one page scroll carries both tablet columns together.
      'Tablet View (2-Column): page scroll carries flow and summary together',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(900, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createBookingScreenWidget(screenSize: const Size(900, 800)),
        );
        await tester.pumpAndSettle();

        // Tablet header badge should reflect 2-Column flow

        final initialSummaryPos = tester.getTopLeft(
          find.byKey(const Key('tablet_order_summary_panel')),
        );
        final pageScrollFinder = find.byKey(const Key('app_shell_scroll_view'));
        expect(pageScrollFinder, findsOneWidget);

        final tabletSummaryCenter = tester.getCenter(
          find.byKey(const Key('tablet_order_summary_panel')),
        );
        await tester.dragFrom(tabletSummaryCenter, const Offset(0, -350));
        await tester.pumpAndSettle();

        final scrolledSummaryPos = tester.getTopLeft(
          find.byKey(const Key('tablet_order_summary_panel')),
        );
        expect(scrolledSummaryPos.dy, lessThan(initialSummaryPos.dy));
        expect(scrolledSummaryPos.dx, equals(initialSummaryPos.dx));
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Payment Successful screen renders robustly on constrained viewport heights without overflow',
      (WidgetTester tester) async {
        // Short mobile/desktop viewport height of 420px
        tester.view.physicalSize = const Size(800, 420);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(800, 420),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Proceed (Schedule → Details), fill, Proceed to Payment
        // (Details → Payment), then Confirm & Pay to trigger success view
        // (P7: single page scroll).
        final proceedBtn = find.text('Proceed to Payment');
        await tester.ensureVisible(proceedBtn);
        await tester.pumpAndSettle();
        expect(proceedBtn, findsOneWidget);
        await driveWebToPayment(
          tester,
          detailsViewKey: 'tablet_details_form_view',
          prefix: 'tablet',
          paymentViewKey: 'tablet_payment_panel_view',
        );

        final confirmBtn = find.textContaining('Confirm & Pay');
        await tester.ensureVisible(confirmBtn);
        await tester.pumpAndSettle();
        expect(confirmBtn, findsOneWidget);

        // C77: contact details already filled at step 3 (driveWebToPayment).

        await tester.ensureVisible(confirmBtn);
        await tester.pumpAndSettle();
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Extreme past dates (e.g. 2018) are safely clamped to calendar bounds',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final pastDate = DateTime.utc(2018, 3, 10);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(
                buildFakeRestClient(FakeApiBackend()),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Row(
                  children: [
                    Expanded(
                      child: ReservationCalendarPanel(
                        selectedDate: pastDate,
                        onDateSelected: (_) {},
                      ),
                    ),
                    Expanded(
                      child: OrderSummaryPanel(
                        package: testPackage,
                        selectedDate: pastDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('summary_value_date')), findsOneWidget);
        expect(find.text('Saturday, March 10, 2018'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Issue #45: In-place Payment Step Transition Tests', () {
    testWidgets(
      'R1: Desktop payment transition replaces Calendar and Details with DesktopPaymentPanel via in-place cross-fade on 1200x800 (>1024px)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Initially on Step 2 (Schedule card layout)
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('event_time_picker_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );
        expect(find.text('Proceed to Payment'), findsOneWidget);

        // C74: Tap Proceed — Schedule → Details (never Payment).
        await tester.tap(find.text('Proceed to Payment'));

        // Advance halfway through the 300ms cross-fade transition
        await tester.pump(const Duration(milliseconds: 150));

        // FadeTransition should be animating
        expect(find.byType(FadeTransition), findsWidgets);

        // Complete transition
        await tester.pumpAndSettle();

        // Schedule card is replaced by the Details form, not Payment.
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );

        // Fill Details, then Proceed to Payment → payment panel.
        await fillWebDetailsContacts(tester, 'desktop');
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(FadeTransition), findsWidgets);
        await tester.pumpAndSettle();

        // Columns 1 & 2 (Calendar & Details) are replaced by DesktopPaymentPanel
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsOneWidget,
        );
        // C8: header distilled — panel starts at payment method selection.
        expect(find.text('Payment & Checkout Details'), findsNothing);
        expect(find.text('Select Payment Method'), findsOneWidget);
      },
    );

    testWidgets(
      'C74: desktop schedule-proceed lands on Details (3), never Payment (4)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Schedule-proceed lands on Details (3), not Payment (4).
        final scheduleProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(scheduleProceed);
        await tester.pumpAndSettle();
        await tester.tap(scheduleProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );

        // Ungated Details-proceed is blocked inline (no jump to 4).
        final gatedProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(gatedProceed);
        await tester.pumpAndSettle();
        await tester.tap(gatedProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );
        expect(find.byKey(const Key('booking_form_error')), findsOneWidget);

        // Gated Details-proceed reaches Payment (4).
        await fillWebDetailsContacts(tester, 'desktop');
        final detailsProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(detailsProceed);
        await tester.pumpAndSettle();
        await tester.tap(detailsProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'C74: tablet schedule-proceed lands on Details (3), never Payment (4)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(900, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(900, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Schedule-proceed lands on Details (3), not Payment (4).
        final scheduleProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(scheduleProceed);
        await tester.pumpAndSettle();
        await tester.tap(scheduleProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tablet_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsNothing,
        );

        // Ungated Details-proceed is blocked inline (no jump to 4).
        final gatedProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(gatedProceed);
        await tester.pumpAndSettle();
        await tester.tap(gatedProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tablet_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsNothing,
        );
        expect(find.byKey(const Key('booking_form_error')), findsOneWidget);

        // Gated Details-proceed reaches Payment (4).
        await fillWebDetailsContacts(tester, 'tablet');
        final detailsProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(detailsProceed);
        await tester.pumpAndSettle();
        await tester.tap(detailsProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tablet_details_form_view')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'R2: Persistent Order Summary remains mounted at exact coordinates with identical live values during and after payment transition',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Record Order Summary position and values before transition (P7 C distilled)
        final summaryBeforePos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.text('7 inclusions'), findsOneWidget);
        expect(find.text('₱4,500.00'), findsOneWidget);

        // C74: Trigger details transition (Schedule → Details).
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pump(const Duration(milliseconds: 150));

        // Mid-transition: Order Summary is STILL mounted and at exact same position
        final summaryMidPos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );
        expect(summaryMidPos.dx, equals(summaryBeforePos.dx));
        expect(summaryMidPos.dy, equals(summaryBeforePos.dy));

        await tester.pumpAndSettle();

        // Post-transition: Order Summary remains persistently visible at exact coordinates
        final summaryAfterPos = tester.getTopLeft(
          find.byKey(const Key('order_summary_side_panel')),
        );
        expect(summaryAfterPos.dx, equals(summaryBeforePos.dx));
        expect(summaryAfterPos.dy, equals(summaryBeforePos.dy));
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );

        // Fill Details, then trigger payment transition (Details → Payment).
        await fillWebDetailsContacts(tester, 'desktop');
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsOneWidget,
        );

        // Summary button has updated to 'Confirm & Pay'
        expect(find.textContaining('Confirm & Pay'), findsOneWidget);
        expect(find.text('₱4,500.00'), findsOneWidget);
      },
    );

    testWidgets(
      'Desktop payment header keeps the unified timeline on payment step',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Initial reservation header (C27: unified Schedule/Details/Payment)
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);

        // C74: Proceed through Details to Payment — header keeps
        // the same unified timeline on every stage.
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);

        await fillWebDetailsContacts(tester, 'desktop');
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsOneWidget,
        );

        // Payment header keeps the same unified timeline
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);

        expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
      },
    );

    testWidgets(
      'Header Back button steps back from DesktopPaymentPanel to Details, then to 2-column reservation layout',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Go to payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Tap Header Back button (stepwise: 4→3, mobile parity)
        await tester.tap(find.text('Back'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(FadeTransition), findsWidgets);

        await tester.pumpAndSettle();

        // Back on the Details form (step 3), not the schedule layout.
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );

        // Back again: 3→2 returns to the schedule card (C92)
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(find.text('Proceed to Payment'), findsOneWidget);
      },
    );

    testWidgets(
      'C8: Edit Selection chip distilled; header Back steps back to Details, then to 2-column reservation layout',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Go to payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // C8: in-panel Edit Selection chip distilled; C6 Back affordance preserved.
        expect(find.text('Edit Selection'), findsNothing);
        expect(find.text('Payment & Checkout Details'), findsNothing);
        // Stepwise back (mobile parity): 4→3 lands on the Details form.
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );

        // 3→2 returns to the schedule card.
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('schedule_datetime_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Interactive payment method switching in DesktopPaymentPanel (Online, Cash) updates Order Summary live preview',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Proceed to Payment via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // 1. Initial method is Online: C77 headers distilled — the PayMongo
        // reminder sits directly below the options, no card capture, no
        // retired methods — order summary distilled (label-value rows, no
        // payment chip)
        expect(find.text('Online Checkout'), findsNothing);
        expect(find.text('Offline Payment Instructions'), findsNothing);
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);
        expect(
          find.byKey(const Key('online_checkout_explainer')),
          findsOneWidget,
        );
        expect(find.text('Cardholder Full Name'), findsNothing);
        expect(find.text('Card Number'), findsNothing);
        expect(find.text('Bank Transfer'), findsNothing);

        // 2. Select Cash
        final cashMethodFinder = find.text('Cash');
        expect(cashMethodFinder, findsWidgets);
        await tester.tap(cashMethodFinder.first);
        await tester.pumpAndSettle();

        // C77: no header — cash reminder shows directly, same brand box.
        expect(find.text('Offline Payment Instructions'), findsNothing);
        expect(
          find.text(
            'You will pay in cash on the event day. Our team will confirm your booking shortly.',
          ),
          findsOneWidget,
        );
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.byKey(const Key('summary_value_pax')), findsOneWidget);
      },
    );

    testWidgets(
      'DesktopPaymentPanel carries no contact fields (editing lives in step 3)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Proceed to Payment via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Online is the default: explainer on, no card capture anywhere
        await tester.tap(find.text('Online'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('online_checkout_explainer')),
          findsOneWidget,
        );
        expect(find.text('Card Number'), findsNothing);

        // C77: contact editing lives in step 3 — the panel owns no fields.
        expect(find.byKey(const Key('payment_customer_name')), findsNothing);
        expect(find.byKey(const Key('payment_customer_email')), findsNothing);
        expect(find.byKey(const Key('payment_customer_phone')), findsNothing);
        expect(find.byKey(const Key('payment_venue_address')), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Confirm & Pay on Desktop completes payment flow and renders Payment Successful view',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Step 1: Schedule → Details → Payment (no direct jump).
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Step 2: Confirm & Pay in persistent Order Summary
        final confirmBtn = find.textContaining('Confirm & Pay');
        expect(confirmBtn, findsOneWidget);

        // C77: contact details already filled at step 3.

        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Step 3: Payment Successful screen
        expect(find.text('Payment Successful'), findsOneWidget);
        expect(find.text('Thank you for your booking.'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'R3: Mobile payment flow behavior is 100% preserved (Schedule -> Details -> Payment -> Success)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(375, 667),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Step 2: Schedule (C92: no Pax UI; rail owns the echo)

        expect(find.text('Proceed'), findsOneWidget);

        // Advance to Step 3: Details via the sticky bottom bar.
        await tester.tap(find.text('Proceed'));
        await tester.pumpAndSettle();

        expect(find.text('Proceed to Payment'), findsOneWidget);

        // Fill mobile contact & venue information required for submission
        await fillMobileContacts(tester);

        // Advance to Step 4: Mobile Payment via the sticky bottom bar.
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        expect(find.text('Price Details'), findsOneWidget);
        expect(find.text('Choose Payment Method'), findsOneWidget);
        expect(find.textContaining('Confirm & Pay'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Back'),
          -200,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('app_shell_scroll_view')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Advance back to mobile payment and complete (sticky bar).
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Confirm & Pay'));
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet 2-column view triggers in-place cross-fade on left column to DesktopPaymentPanel while keeping Order Summary persistent',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(900, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(900, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Initial tablet 2-column layout
        expect(find.byKey(const Key('tablet_calendar_panel')), findsOneWidget);
        expect(find.byKey(const Key('tablet_details_panel')), findsOneWidget);
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(find.text('Proceed to Payment'), findsOneWidget);

        // C74: Tap Proceed in tablet Order Summary (P7: page scroll) —
        // Schedule → Details first (never Payment).
        final proceedBtn = find.text('Proceed to Payment');
        await tester.ensureVisible(proceedBtn);
        await tester.pumpAndSettle();
        await tester.tap(proceedBtn);
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(FadeTransition), findsWidgets);
        await tester.pumpAndSettle();

        // Left column is now the Details form on tablet
        expect(
          find.byKey(const Key('tablet_details_form_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsNothing,
        );

        // Fill Details, then Proceed to Payment → payment panel.
        await fillWebDetailsContacts(tester, 'tablet');
        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // Left column is now DesktopPaymentPanel on tablet
        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(find.textContaining('Confirm & Pay'), findsOneWidget);

        // C77: contact details already filled at step 3 (Details).

        // Confirm & Pay completes tablet flow
        final confirmBtn = find.textContaining('Confirm & Pay');
        await tester.ensureVisible(confirmBtn);
        await tester.pumpAndSettle();
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful'), findsOneWidget);
      },
    );

    testWidgets('DesktopPaymentPanel renders cleanly in Dark Theme', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = c169SeededContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ResponsiveAppShell(child: BookingScreen(packageId: 42)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // C74: reach the payment step via Details.
      await driveWebToPayment(
        tester,
        detailsViewKey: 'desktop_details_form_view',
        prefix: 'desktop',
        paymentViewKey: 'desktop_payment_panel_view',
      );
      expect(find.byKey(const Key('order_summary_side_panel')), findsOneWidget);
      // C8: header distilled.
      expect(find.text('Payment & Checkout Details'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Desktop payment transition renders cleanly under 2.0x text scaling without flex overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: child!,
                );
              },
              home: const ResponsiveAppShell(
                child: BookingScreen(packageId: 42),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final proceedBtn = find.text('Proceed to Payment');
        await tester.ensureVisible(proceedBtn);
        await tester.pumpAndSettle();
        expect(proceedBtn, findsOneWidget);
        // C74: reach the payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Dynamic resize between Desktop (1200px) and Tablet (900px) preserves active payment step state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: Proceed to payment on Desktop via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Resize to Tablet (900px) -> Still in Payment step
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('tablet_payment_panel_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(find.textContaining('Confirm & Pay'), findsOneWidget);

        // Resize back to Desktop (1400px) -> Still in Payment step
        tester.view.physicalSize = const Size(1400, 800);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('desktop_payment_panel_view')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('order_summary_side_panel')),
          findsOneWidget,
        );
        expect(find.textContaining('Confirm & Pay'), findsOneWidget);
      },
    );

    testWidgets(
      'DesktopPaymentPanel captures no card details: Online shows explainer, contact editing lives in step 3',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: reach the payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // Online method: explainer present, card capture absent
        await tester.tap(find.text('Online'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('online_checkout_explainer')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('payment_card_number')), findsNothing);
        expect(find.byKey(const Key('payment_card_cvv')), findsNothing);
        expect(find.byKey(const Key('payment_card_expiry')), findsNothing);

        // C77: contact editing lives in step 3 — the panel owns no fields.
        expect(find.byKey(const Key('payment_customer_email')), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DesktopPaymentPanel captures no text input (method + reminder only)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C74: reach the payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        // C77: step-3 contact fields persist; the payment panel itself
        // owns no TextFields.
        expect(find.byKey(const Key('payment_customer_name')), findsNothing);
        expect(find.byKey(const Key('payment_customer_email')), findsNothing);
        expect(find.byKey(const Key('payment_venue_address')), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DesktopPaymentPanel renders robustly on narrow tablet column under 3.0x extreme text scale without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(3.0)),
                  child: child!,
                );
              },
              home: const ResponsiveAppShell(
                child: BookingScreen(packageId: 42),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final proceedBtn = find.text('Proceed to Payment');
        await tester.ensureVisible(proceedBtn);
        await tester.pumpAndSettle();
        // C74: reach the payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'tablet_details_form_view',
          prefix: 'tablet',
          paymentViewKey: 'tablet_payment_panel_view',
        );
        expect(
          find.byKey(const Key('tablet_order_summary_panel')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Rapid step oscillation between reservation and payment views preserves selection state and transition animations cleanly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = c169SeededContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          createBookingScreenWidget(
            screenSize: const Size(1200, 800),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // C92: no Pax UI in Schedule (rail echoes the locked step).
        // C18 pay-once: no picker on the schedule step — pick Online
        // once at the payment step.
        expect(
          find.descendant(
            of: find.byKey(const Key('order_summary_side_panel')),
            matching: find.text('20 PAX'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('schedule_datetime_card')),
            matching: find.text('Online'),
          ),
          findsNothing,
        );

        // C74: reach the payment step via Details.
        await driveWebToPayment(
          tester,
          detailsViewKey: 'desktop_details_form_view',
          prefix: 'desktop',
          paymentViewKey: 'desktop_payment_panel_view',
        );

        final onlineOption = find.descendant(
          of: find.byKey(const Key('desktop_payment_panel_view')),
          matching: find.text('Online'),
        );
        await tester.ensureVisible(onlineOption);
        await tester.pumpAndSettle();
        await tester.tap(onlineOption);
        await tester.pumpAndSettle();

        // Stepwise back to Details (4→3, mobile parity) for the
        // oscillation below.
        final backToDetails = find.text('Back');
        await tester.ensureVisible(backToDetails);
        await tester.pumpAndSettle();
        await tester.tap(backToDetails);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );

        // And 3→2 back to the schedule step.
        final backToSchedule = find.text('Back');
        await tester.ensureVisible(backToSchedule);
        await tester.pumpAndSettle();
        await tester.tap(backToSchedule);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('reservation_calendar_panel')),
          findsOneWidget,
        );

        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.text('20 PAX'), findsWidgets);

        // Rapidly toggle forward and backward 3 times (C74: each
        // forward leg is Schedule → Details → Payment; Details stay
        // filled from the first pass, so both gates pass).
        for (int i = 0; i < 3; i++) {
          // Proceed to Details
          final proceed = find.text('Proceed to Payment');
          await tester.ensureVisible(proceed);
          await tester.pumpAndSettle();
          await tester.tap(proceed);
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(FadeTransition), findsWidgets);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('desktop_details_form_view')),
            findsOneWidget,
          );

          // Proceed to Payment
          final proceedAgain = find.text('Proceed to Payment');
          await tester.ensureVisible(proceedAgain);
          await tester.pumpAndSettle();
          await tester.tap(proceedAgain);
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(FadeTransition), findsWidgets);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('desktop_payment_panel_view')),
            findsOneWidget,
          );

          // C8: chip distilled — header Back steps back stepwise
          // (4→3 Details, then 3→2 Schedule; mobile parity).
          final editSel = find.text('Back');
          await tester.ensureVisible(editSel);
          await tester.pumpAndSettle();
          await tester.tap(editSel);
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(FadeTransition), findsWidgets);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('desktop_details_form_view')),
            findsOneWidget,
          );

          final editSelAgain = find.text('Back');
          await tester.ensureVisible(editSelAgain);
          await tester.pumpAndSettle();
          await tester.tap(editSelAgain);
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(FadeTransition), findsWidgets);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('reservation_calendar_panel')),
            findsOneWidget,
          );
        }

        // State is preserved (payment chip removed per C, but PAX one-liner persists)
        expect(find.text('Your Booking'), findsOneWidget);
        expect(find.text('20 PAX'), findsWidgets);

        // Final proceed to payment and confirm (C74: via Details —
        // still filled, so both gates pass).
        final finalProceed = find.text('Proceed to Payment');
        await tester.ensureVisible(finalProceed);
        await tester.pumpAndSettle();
        await tester.tap(finalProceed);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('desktop_details_form_view')),
          findsOneWidget,
        );
        final finalProceedAgain = find.text('Proceed to Payment');
        await tester.ensureVisible(finalProceedAgain);
        await tester.pumpAndSettle();
        await tester.tap(finalProceedAgain);
        await tester.pumpAndSettle();
        // C77: contact details already filled at step 3.
        final finalConfirm = find.textContaining('Confirm & Pay');
        await tester.ensureVisible(finalConfirm);
        await tester.pumpAndSettle();
        await tester.tap(finalConfirm);
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful'), findsOneWidget);
      },
    );

    testWidgets(
      'DesktopPaymentPanel handles bare/null package data gracefully with default fallbacks',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const minimalPackage = Package(
          id: 99,
          name: null,
          description: null,
          price: null,
          images: null,
          inclusions: null,
          freebies: null,
          paxOptions: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: DesktopPaymentPanel(
                package: minimalPackage,
                paymentMethod: 'online',
                onPaymentMethodSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // C8: header distilled — panel starts at payment method selection.
        // C77: method headers distilled too — reminder sits below options.
        expect(find.text('Payment & Checkout Details'), findsNothing);
        expect(find.text('Online Checkout'), findsNothing);
        expect(
          find.byKey(const Key('online_checkout_explainer')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Issue #47: booking-screen entry and success-leave reset', () {
    Future<ProviderContainer> driveToConfirmed(
      WidgetTester tester,
      FakeApiBackend backend,
    ) async {
      final container = ProviderContainer(
        overrides: [
          packageDetailsProvider(42).overrideWith((ref) => testPackage),
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        ],
      );
      // Dio needs real async: the widget fake-async zone would freeze it.
      await tester.runAsync(() async {
        final notifier = container.read(bookingFlowProvider.notifier);
        container.read(bookingFlowProvider.notifier)
          ..setSelectedPackage(testPackage)
          ..setSelectedDate(DateTime(2026, 9, 30))
          ..setSelectedTime('2:00 PM - 5:00 PM')
          ..setSelectedPax(50)
          ..setCustomerName('Maria Clara')
          ..setCustomerEmail('maria@example.com')
          ..setCustomerPhone('+639171234567')
          ..setVenueAddress('The Peninsula Manila')
          ..setPaymentMethod('online');
        await notifier.submitBooking();
        await notifier.startPolling();
        notifier.goToStep(5);
      });
      return container;
    }

    testWidgets(
      're-entering after a completed booking shows schedule, never old success',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = await driveToConfirmed(tester, FakeApiBackend());
        addTearDown(container.dispose);
        expect(
          container.read(bookingFlowProvider).checkoutStatus,
          BookingCheckoutStatus.confirmed,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ResponsiveAppShell(
                child: BookingScreen(packageId: 42),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful'), findsNothing);
        expect(find.text('Select Date & Time'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Done on the success screen resets the flow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final backend = FakeApiBackend();
      final container = ProviderContainer(
        overrides: [
          packageDetailsProvider(42).overrideWith((ref) => testPackage),
          apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ResponsiveAppShell(child: BookingScreen(packageId: 42)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final notifier = container.read(bookingFlowProvider.notifier);
        notifier
          ..setSelectedPackage(testPackage)
          ..setSelectedDate(DateTime(2026, 9, 30))
          ..setSelectedTime('2:00 PM - 5:00 PM')
          ..setSelectedPax(50)
          ..setCustomerName('Maria Clara')
          ..setCustomerEmail('maria@example.com')
          ..setCustomerPhone('+639171234567')
          ..setVenueAddress('The Peninsula Manila')
          ..setPaymentMethod('online');
        await notifier.submitBooking();
        await notifier.startPolling();
        notifier.goToStep(5);
      });
      await tester.pumpAndSettle();

      expect(find.text('Payment Successful'), findsOneWidget);
      // C51: in product the overlay is a pill on the booking route, so the
      // success screen's own Done stays tappable. This harness has no
      // router, so minimize explicitly before exercising Done.
      container.read(paymentOverlayMinimizedProvider.notifier).state = true;
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final state = container.read(bookingFlowProvider);
      expect(state.booking, isNull);
      expect(state.checkoutStatus, BookingCheckoutStatus.idle);
      expect(state.currentStep, 2);
      // No takeException: Done falls back to context.go('/home'), which
      // asserts without a GoRouter in this harness (caught in product).
    });
  });
}
