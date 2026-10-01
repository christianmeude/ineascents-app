import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/index.dart';
import '../providers/index.dart';
import '../config/theme.dart';
import '../src/utils/checkout_window.dart';
import '../utils/peso.dart';
import '../widgets/index.dart';

/// Day-precision past check (C13): [date] counts as past only when its
/// calendar day is before today's. Today itself is always allowed.
bool _isPastDay(DateTime date, DateTime now) {
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  return day.isBefore(today);
}

/// Reservation and Booking Screen for INEA Scents.
///
/// Features:
/// - Desktop Split View (>1024px): 2-column layout (Left: in-place flow
///   Calendar → Details → Payment, Right: Sticky Order Summary).
/// - Tablet View (768px - 1024px): 2-column layout (Left: Calendar & Customization, Right: Order Summary).
/// - Mobile View (<768px): 1-column vertical step flow with timeline.
/// - Integrated seamlessly with [ResponsiveAppShell].
class BookingScreen extends ConsumerStatefulWidget {
  final int packageId;

  /// Preselected headcount option carried from a package card (`?pax=`).
  /// Honored when it matches the package's options; otherwise the first
  /// available option wins as before.
  final int? initialPax;

  /// Date carried from the calendar (`?date=`); preferred over the default
  /// when it is not in the past.
  final DateTime? initialDate;

  const BookingScreen({
    super.key,
    required this.packageId,
    this.initialPax,
    this.initialDate,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  bool _isInitialized = false;
  // C31: single-sourced via AppTheme (never per-screen hex).
  static const Color plum = AppTheme.primaryButtonBackground;

  // P7: dark-aware surfaces through the shared helper.
  Color get _surface => CardSurfaces.cardBg(context);
  Color get _surfaceBorder => CardSurfaces.cardBorder(context);
  Color get _title => CardSurfaces.title(context);
  Color get _body => CardSurfaces.body(context);

  /// P4 state shape: selections are owned by [bookingFlowProvider].
  /// The screen watches (see build) and dispatches — no local mirror.
  /// Text controllers stay local per Flutter requirements and commit
  /// through to the notifier on change (see panel callbacks below).
  DateTime? get _selectedDate => ref.read(bookingFlowProvider).selectedDate;
  int? get _selectedPax => ref.read(bookingFlowProvider).selectedPax;
  String? get _selectedTime => ref.read(bookingFlowProvider).selectedTime;
  String get _paymentMethod =>
      ref.read(bookingFlowProvider).paymentMethod ?? 'online';
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController =
      TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();

  /// Gesture-held checkout tab (web only). Opened synchronously in the
  /// Confirm tap so the browser grants the popup; navigated once the
  /// booking POST returns a checkout URL. Nulled after navigate/close —
  /// dispose only closes a tab we still own (never the PayMongo page).
  CheckoutWindow? _heldCheckoutTab;

  /// Re-entrancy guard: the provider's `isLoading` flips a frame after the
  /// tap, so a fast double-tap could otherwise POST two bookings.
  bool _submitting = false;

  /// C52: form-level failure for the booking flow. Validation gates
  /// (date/time, details, stale date) render here inline via
  /// [FormErrorSummary] — never as a nav banner or toast. Only a
  /// transient submit failure additionally surfaces a toast with Retry
  /// (see [_handleConfirmAndPay]); [_formRetry] is non-null exactly
  /// in that case.
  String? _formError;
  VoidCallback? _formRetry;

  void _setFormError(String message, {VoidCallback? retry}) {
    if (!mounted) return;
    setState(() {
      _formError = message;
      _formRetry = retry;
    });
  }

  void _clearFormError() {
    if (_formError == null && _formRetry == null) return;
    if (!mounted) return;
    setState(() {
      _formError = null;
      _formRetry = null;
    });
  }

  /// C52: in-card slot for [_formError]; shrink-wrapped when clear.
  /// Rendered at the top of every flow layout (desktop/tablet/mobile)
  /// plus the checkout screen, so gate failures always read in place.
  Widget _formErrorSlot() {
    final error = _formError;
    if (error == null || error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormErrorSummary(
        key: const Key('booking_form_error'),
        message: error,
        onRetry: _formRetry,
      ),
    );
  }

  /// C48: collapsed-schedule disclosure (mobile step 2). The full
  /// summary renders only on demand; the collapsed card carries no CTA.
  bool _scheduleSummaryExpanded = false;

  /// C65: last rendered wizard stage — drives the direction-aware
  /// stage transition (forward slides from the right, back from left).
  int _lastSeenStep = 2;

  /// C65: reduced-motion gate — [MediaQuery.disableAnimations] forces
  /// every stage/timeline animation to settle instantly.
  bool _isReducedMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// C65: shared stage transition — slide + fade on step change,
  /// direction-aware (cheap `_lastSeenStep` compare), ≤250ms ease-out,
  /// Flutter built-ins only. Instant child swap when reduced motion.
  Widget _stageSwitcher({
    required int step,
    required Widget child,
  }) {
    final reduce = _isReducedMotion(context);
    final forward = step >= _lastSeenStep;
    _lastSeenStep = step;
    final begin = forward
        ? const Offset(0.12, 0)
        : const Offset(-0.12, 0);
    return AnimatedSwitcher(
      duration: reduce
          ? Duration.zero
          : const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        if (reduce) return child;
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            animation,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('booking_stage_$step'),
        child: child,
      ),
    );
  }

  /// Short date matching the summary rail one-liner (`Sep 18, 2026`).
  static String _shortDate(DateTime? date) {
    if (date == null) return 'Not selected';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int get _currentStep => ref.read(bookingFlowProvider).currentStep;

  @override
  void initState() {
    super.initState();
    // Fresh flow per package entry: drops a previous success/cancelled
    // screen or another package's state. In-flight same-package checkout
    // polling is preserved. Deferred post-frame: Riverpod forbids provider
    // writes inside initState; registered before _loadPackage's callback
    // so the reset lands before the new package is set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(bookingFlowProvider.notifier);
      notifier.ensureFreshForPackage(widget.packageId);
      // Notifier-owned defaults (provider writes are forbidden in initState).
      // A carried `?date=` wins over the default when not in the past.
      // C13: an already-chosen date always survives re-entry — this branch
      // only runs when the flow has no date yet, never overwriting one.
      final flow = ref.read(bookingFlowProvider);
      if (flow.selectedDate == null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final carried = widget.initialDate;
        final carriedDay = carried == null
            ? null
            : DateTime(carried.year, carried.month, carried.day);
        notifier.setSelectedDate(
          carriedDay != null && !carriedDay.isBefore(today)
              ? carriedDay
              : now.add(const Duration(days: 3)),
        );
      }
      // Freeform clock time, prefilled like the old default slot so the
      // schedule step is submittable before the user opens the picker.
      if (flow.selectedTime == null) {
        notifier.setSelectedTime('14:00:00');
      }
      if (flow.paymentMethod == null) {
        notifier.setPaymentMethod('online');
      }
      // C60: exact-stage resume — a same-package draft reopens at its
      // stored stage with date + Pax + details intact; an empty flow
      // normalizes to stage 1 (Schedule). No-op in every live path.
      final target = notifier.resumeStage;
      if (target != ref.read(bookingFlowProvider).currentStep) {
        notifier.goToStep(target);
      }
    });
    _loadPackage();
    setState(() {
      _isInitialized = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prefillFromUser();
    });
  }

  @override
  void dispose() {
    _heldCheckoutTab?.close();
    _heldCheckoutTab = null;
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _venueAddressController.dispose();
    super.dispose();
  }

  void _prefillFromUser() {
    // C60: exact-stage resume — a reopened draft reseeds the fields from
    // the flow first, so date + Pax + details render intact. Fill-only:
    // anything already typed always wins.
    final flow = ref.read(bookingFlowProvider);
    if (_customerNameController.text.isEmpty &&
        (flow.customerName ?? '').isNotEmpty) {
      _customerNameController.text = flow.customerName!;
    }
    if (_customerEmailController.text.isEmpty &&
        (flow.customerEmail ?? '').isNotEmpty) {
      _customerEmailController.text = flow.customerEmail!;
    }
    if (_customerPhoneController.text.isEmpty &&
        (flow.customerPhone ?? '').isNotEmpty) {
      _customerPhoneController.text = flow.customerPhone!;
    }
    if (_venueAddressController.text.isEmpty &&
        (flow.venueAddress ?? '').isNotEmpty) {
      _venueAddressController.text = flow.venueAddress!;
    }
    // C53: Profile is the prefill source of truth. Fill-only, every time:
    // an empty field takes the profile value, but anything already in the
    // flow (an inline edit, a restored draft) always wins — and nothing
    // here ever writes back to the profile.
    final user = ref.read(authProvider).user;
    if (user == null) return;
    if (_customerNameController.text.isEmpty &&
        (flow.customerName ?? '').isEmpty) {
      _customerNameController.text = user.name ?? '';
    }
    if (_customerEmailController.text.isEmpty &&
        (flow.customerEmail ?? '').isEmpty) {
      _customerEmailController.text = user.email ?? '';
    }
    ref.read(bookingFlowProvider.notifier).prefillFromUser(user);
  }

  Future<void> _handleConfirmAndPay() async {
    if (_submitting) return;
    _submitting = true;
    // C52: drop any stale error surface before a fresh attempt.
    _clearFormError();
    if (mounted) hideAppError(context);
    try {
      // C13: submit-time past-date guard (day precision — today is allowed).
      // The calendar only offers free days, but a chosen date can age past
      // midnight while the flow sits open. Reject here so a stale date never
      // reaches POST; the provider stays untouched.
      final selectedDate = _selectedDate;
      if (selectedDate != null && _isPastDay(selectedDate, DateTime.now())) {
        if (mounted) {
          // C52: validation gate renders inline, never as banner/toast.
          _setFormError(
            'The selected date has passed. Please choose a new date.',
          );
        }
        return;
      }
      final notifier = ref.read(bookingFlowProvider.notifier);
      // Web popup rule: window.open only survives inside the tap gesture.
      // The booking POST resolves seconds later, so hold a branded
      // placeholder tab now (online methods only) and navigate it below.
      // Null on mobile (url_launcher path) or when the open was blocked —
      // both fall back to _launchCheckoutUrl plus the recovery button.
      final online = isOnlinePaymentString(
        ref.read(bookingFlowProvider).paymentMethod,
      );
      _heldCheckoutTab?.close();
      _heldCheckoutTab = (kIsWeb && online) ? openCheckoutWindow() : null;
      final booking = await notifier.submitBooking();
      if (booking == null) {
        _heldCheckoutTab?.close();
        _heldCheckoutTab = null;
        final state = ref.read(bookingFlowProvider);
        if (state.errorMessage != null && mounted) {
          // C52: submit failure always renders in-card; only a
          // transient failure additionally toasts with Retry.
          final msg = state.errorMessage!;
          final transient = isTransientErrorMessage(msg);
          _setFormError(
            msg,
            retry: transient ? () => _handleConfirmAndPay() : null,
          );
          if (transient) {
            showAppError(
              context,
              message: msg,
              transient: true,
              onRetry: () => _handleConfirmAndPay(),
            );
          }
        }
        return;
      }
      final status = ref.read(bookingFlowProvider).checkoutStatus;
      notifier.goToStep(5);
      if (status == BookingCheckoutStatus.awaitingPayment) {
        final checkoutUrl = booking.checkoutUrl;
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          final held = _heldCheckoutTab;
          _heldCheckoutTab = null;
          if (held != null) {
            held.navigateTo(checkoutUrl);
          } else {
            unawaited(_launchCheckoutUrl(checkoutUrl));
          }
        } else {
          _heldCheckoutTab?.close();
          _heldCheckoutTab = null;
        }
        unawaited(notifier.startPolling());
      } else {
        // Offline methods never need the held tab.
        _heldCheckoutTab?.close();
        _heldCheckoutTab = null;
      }
    } finally {
      _submitting = false;
    }
  }

  /// Opens [checkoutUrl] in a new browser tab (external application), so
  /// the app — and its payment polling — stays alive underneath.
  /// Returns true when the platform accepted the launch. Never throws:
  /// a failure surfaces as a toast with a copy-link action
  /// instead of stranding the user on the processing screen.
  Future<bool> _launchCheckoutUrl(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      _showCheckoutLaunchFailure(checkoutUrl);
      return false;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showCheckoutLaunchFailure(checkoutUrl);
      return launched;
    } catch (_) {
      _showCheckoutLaunchFailure(checkoutUrl);
      return false;
    }
  }

  void _showCheckoutLaunchFailure(String checkoutUrl) {
    if (!mounted) return;
    // C52: copy-link action preserved on the toast (no banner anywhere).
    showAppError(
      context,
      message: 'Checkout did not open automatically. Use the button below.',
      actionLabel: 'Copy link',
      onAction: () => Clipboard.setData(ClipboardData(text: checkoutUrl)),
    );
  }

  /// Re-opens the stored checkout link for the in-flight booking, if any.
  Future<void> _openCheckoutFromState() async {
    final checkoutUrl = ref.read(bookingFlowProvider).booking?.checkoutUrl;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      if (!mounted) return;
      // C52: form-level failure renders inline on the checkout screen.
      _setFormError('Checkout link is unavailable. Please rebook.');
      return;
    }
    await _launchCheckoutUrl(checkoutUrl);
  }

  void _loadPackage() async {
    final packageAsync = ref.read(packageDetailsProvider(widget.packageId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      packageAsync.whenData((package) {
        final flow = ref.read(bookingFlowProvider);
        final notifier = ref.read(bookingFlowProvider.notifier);
        // C24: never blind-reset on load — setSelectedPackage drops pax to
        // the lowest option. A same-package flow that already holds a valid
        // pax (e.g. a carried ?pax=) keeps it.
        final candidates = package.options.isNotEmpty
            ? package.options.map((t) => t.pax).toList()
            : (package.paxOptions ?? const <int>[]);
        if (flow.selectedPackage?.id == package.id &&
            flow.selectedPax != null &&
            (candidates.isEmpty || candidates.contains(flow.selectedPax))) {
          return;
        }
        final prevPax = flow.selectedPax;
        notifier.setSelectedPackage(package);
        _syncNotifierDefaults();
        if (candidates.isNotEmpty) {
          // Honor a package option preselected from a package card; a
          // still-valid previous choice wins over the default; otherwise
          // the first available option wins as before.
          if (prevPax != null && candidates.contains(prevPax)) {
            notifier.setSelectedPax(prevPax);
          } else {
            final preselected = widget.initialPax;
            final chosen =
                (preselected != null && candidates.contains(preselected))
                ? preselected
                : candidates.first;
            notifier.setSelectedPax(chosen);
          }
        }
      });
    });
  }

  /// Ensures the notifier carries a payment default so submission has a
  /// complete state even when the user never touched a control.
  /// (Selections now live in the notifier; nothing to mirror back.)
  void _syncNotifierDefaults() {
    final state = ref.read(bookingFlowProvider);
    final notifier = ref.read(bookingFlowProvider.notifier);
    if (state.paymentMethod == null) {
      notifier.setPaymentMethod('online');
    }
  }

  void _goToStep(int step) {
    _clearFormError();
    ref.read(bookingFlowProvider.notifier).goToStep(step);
  }

  // C6: single in-flow edit path — pax "Change" stays on the schedule
  // step via _goToStep(2). Backward nav is stepwise (mobile parity):
  // header Back uses previousStep() (4→3→2), never a direct jump.
  // The /package-details router jump is dropped (router.dart untouched).

  /// Freeform clock-time picker. Stores `H:i:s` directly (no slot labels);
  /// the provider passes it to the API, which accepts any valid time.
  Future<void> _pickEventTime() async {
    TimeOfDay initial = const TimeOfDay(hour: 14, minute: 0);
    final current = TimeSlot.toEventTime(_selectedTime);
    if (current != null) {
      final parts = current.split(':');
      initial = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      // C152: force dark picker tokens in dark mode.
      builder: AppTheme.darkTimePickerBuilder,
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    ref.read(bookingFlowProvider.notifier).setSelectedTime(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const SizedBox.shrink();
    ref.watch(bookingFlowProvider);
    // C53: the profile can arrive after this route (late login/session
    // restore) — prefill then too, so the one booking route prefills
    // details every time. Fill-only; inline edits always win.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!mounted) return;
      if (prev?.user == next.user) return;
      if (next.user != null) _prefillFromUser();
    });
    ref.listen<AsyncValue<Package>>(packageDetailsProvider(widget.packageId), (
      prev,
      next,
    ) {
      next.whenData((package) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final flow = ref.read(bookingFlowProvider);
          final flowNotifier = ref.read(bookingFlowProvider.notifier);
          // C24: candidates mirror _loadPackage (sorted options first) so
          // repair and seeding agree on which option is "first".
          final candidates = package.options.isNotEmpty
              ? package.options.map((t) => t.pax).toList()
              : (package.paxOptions ?? const <int>[]);
          // C24: a same-package refresh (loading→data, invalidate) must
          // never reset a valid higher pax — only repair a pax the
          // freshly loaded package no longer offers, honoring ?pax= there.
          if (flow.selectedPackage?.id == package.id) {
            final currentPax = flow.selectedPax;
            if (currentPax == null ||
                (candidates.isNotEmpty && !candidates.contains(currentPax))) {
              if (candidates.isNotEmpty) {
                final preselected = widget.initialPax;
                final chosen =
                    (preselected != null && candidates.contains(preselected))
                    ? preselected
                    : candidates.first;
                flowNotifier.setSelectedPax(chosen);
              }
            }
            _syncNotifierDefaults();
            return;
          }
          final prevPax = flow.selectedPax;
          flowNotifier.setSelectedPackage(package);
          _syncNotifierDefaults();
          // Selections live in the notifier; seed the pax from the
          // still-valid previous choice or the carried ?pax=, else first.
          if (candidates.isNotEmpty) {
            if (prevPax != null && candidates.contains(prevPax)) {
              flowNotifier.setSelectedPax(prevPax);
            } else {
              final preselected = widget.initialPax;
              final chosen =
                  (preselected != null && candidates.contains(preselected))
                  ? preselected
                  : candidates.first;
              flowNotifier.setSelectedPax(chosen);
            }
          }
        });
      });
    });

    final packageAsync = ref.watch(packageDetailsProvider(widget.packageId));

    // C48: mobile sticky bar lives outside the page scroll as the
    // Scaffold's bottomNavigationBar. MediaQuery <768px matches the
    // LayoutBuilder mobile branch (the 1200 cap never binds below 768).
    final isMobileWidth =
        MediaQuery.of(context).size.width <
        ResponsiveAppShell.mobileBreakpoint;
    final barPackage = packageAsync.maybeWhen(
      data: (package) => package,
      orElse: () => null,
    );

    // C92: desktop Schedule (step 2) is fixed — the 3-col card + rail
    // fit the viewport with no page-level scroll. Details/Payment keep
    // the single page scroll (taller forms, 2x-scale safe), as do the
    // loading/error states (the skeleton mimics the old tall stack).
    // Extreme text scaling (>1.5x) also keeps the scroll: fixed columns
    // cannot grow, so scrolling stays the overflow-safe fallback there.
    // Tablet + mobile always keep the scroll (unchanged tree below).
    final isDesktopSchedule =
        MediaQuery.of(context).size.width >
            ResponsiveAppShell.tabletBreakpoint &&
        _currentStep == 2 &&
        packageAsync.hasValue &&
        MediaQuery.textScalerOf(context).scale(1.0) <= 1.5;
    final Widget flowContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            packageAsync.when(
              data: (package) {
                if (_currentStep == 5) {
                  return _buildCheckoutScreen();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    if (width > ResponsiveAppShell.tabletBreakpoint) {
                      // Desktop 2-Column Split View (>1024px, P6)
                      return _buildDesktopThreeColumnLayout(package);
                    } else if (width >= ResponsiveAppShell.mobileBreakpoint) {
                      // Tablet 2-Column Layout (768px - 1024px)
                      return _buildTabletTwoColumnLayout(package);
                    } else {
                      // Mobile 1-Column Layout (<768px)
                      return _buildMobileLayout(package);
                    }
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: SkeletonBookingFlow(),
              ),
              // P6 (Q6/Q8): shared friendly card; raw errors stay
              // in logs, never on screen.
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ErrorStateCard(
                    title: "We couldn't open this booking",
                    message:
                        'Check your connection and try again. '
                        'Nothing has been charged.',
                    onRetry: () =>
                        ref.refresh(packageDetailsProvider(widget.packageId)),
                  ),
                ),
              ),
            ), // when
          ],
        ),
      ), // ConstrainedBox
    ); // Center

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: (isMobileWidth && barPackage != null)
          ? _buildMobileBottomBar(barPackage)
          : null,
      body: SafeArea(
        child: isDesktopSchedule
            ? flowContent
            : SingleChildScrollView(
                key: const Key(
                  'app_shell_scroll_view',
                ), // Keep this key so tests pass
                // C40: clamp overscroll on mobile (<768px); SDK default
                // (stretch Android / bounce iOS) displaced content past edge.
                // Desktop/web physics untouched (null = platform default).
                physics: MobileClampScroll.physicsOf(context),
                child: flowContent,
              ), // SingleChildScrollView
      ), // SafeArea
    ); // Scaffold
  }

  // ==========================================================================
  // DESKTOP 2-COLUMN SPLIT VIEW (>1024px, P6: single flow + summary)
  // ==========================================================================

  Widget _buildDesktopThreeColumnLayout(Package package) {
    final isPayment = _currentStep == 4;
    final isDetails = _currentStep == 3;

    return Column(
      children: [
        _buildDesktopHeader(package),
        // P7: ONE page-level scroll (flow + summary scroll together);
        // the summary stays pinned at the top of its column.
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FLOW COLUMN (LEFT): IN-PLACE SLIDE + FADE (C65)
              // ------------------------------------------------------
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formErrorSlot(),
                      _stageSwitcher(
                        step: _currentStep,
                        child: isPayment
                            ? DesktopPaymentPanel(
                                key: const ValueKey(
                                  'desktop_payment_panel_view',
                                ),
                                package: package,
                                paymentMethod: _paymentMethod,
                                onPaymentMethodSelected: (method) {
                                  ref
                                      .read(bookingFlowProvider.notifier)
                                      .setPaymentMethod(method);
                                },
                                onBackToReservation: () {
                                  _goToStep(3);
                                },
                              )
                            // C74: web/tablet follows Schedule(2) →
                            // Details(3) → Payment(4), no direct jump. The
                            // step-3 branch renders the Details form in the
                            // left column (same fields as mobile step 3).
                            : isDetails
                            ? _buildWebDetailsForm(
                                viewKey: 'desktop_details_form_view',
                                keyPrefix: 'desktop',
                              )
                            : Column(
                                key: const ValueKey(
                                  'desktop_schedule_stack_view',
                                ),
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // C92: one "Select Date & Time" card —
                                  // calendar (inner col 1) + time (inner
                                  // col 2); the rail (col 3) owns booking.
                                  _buildScheduleDateTimeCard(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------------
              // SUMMARY (RIGHT): STICKY RAIL — top-pinned; the panel caps
              // itself at viewport height with an internal scroll (isSticky)
              // so it stays usable while the page scrolls.
              // ------------------------------------------------------
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: OrderSummaryPanel(
                      key: const Key('order_summary_side_panel'),
                    package: package,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    selectedPax: _selectedPax,
                    paymentMethod: _paymentMethod,
                    actionButtonText: isPayment
                        ? 'Confirm & Pay'
                        : 'Proceed to Payment',
                    isLoading: ref.watch(bookingFlowProvider).isLoading,
                    isSticky: true,
                    onProceed: () {
                      final notifier = ref.read(bookingFlowProvider.notifier);
                      if (_currentStep == 4) {
                        _handleConfirmAndPay();
                      } else if (_currentStep == 3) {
                        // C74: Details → Payment gate (same authority as
                        // mobile `_handleMobileBarTap`).
                        if (!notifier.canProceedFromDetails()) {
                          // C52: validation gate renders inline, never toast.
                          _setFormError('Please fill name, email and venue');
                          return;
                        }
                        _goToStep(4);
                      } else {
                        // Selections live in the notifier; the gate below is
                        // the single authority — nothing to mirror back.
                        // C74: Schedule → Details (never Payment directly).
                        if (!notifier.canProceedFromSchedule()) {
                          // C52: validation gate renders inline, never toast.
                          _setFormError('Please select date and time');
                          return;
                        }
                        _goToStep(3);
                      }
                    },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TABLET 2-COLUMN LAYOUT (768px - 1024px)
  // ==========================================================================

  Widget _buildTabletTwoColumnLayout(Package package) {
    final isPayment = _currentStep == 4;
    final isDetails = _currentStep == 3;

    return Column(
      children: [
        _buildDesktopHeader(package),
        // P7: ONE page-level scroll; summary pinned at the top of
        // its column (no nested column scrolls).
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Calendar & Customization / Payment
              // (Slide + faded, C65)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formErrorSlot(),
                      _stageSwitcher(
                        step: _currentStep,
                        child: isPayment
                            ? DesktopPaymentPanel(
                                key: const ValueKey(
                                  'tablet_payment_panel_view',
                                ),
                                package: package,
                                paymentMethod: _paymentMethod,
                                onPaymentMethodSelected: (method) {
                                  ref
                                      .read(bookingFlowProvider.notifier)
                                      .setPaymentMethod(method);
                                },
                                onBackToReservation: () {
                                  _goToStep(3);
                                },
                              )
                            // C74: same 3-stage flow as desktop — the step-3
                            // branch renders the Details form in the left
                            // column (same fields as mobile step 3).
                            : isDetails
                            ? _buildWebDetailsForm(
                                viewKey: 'tablet_details_form_view',
                                keyPrefix: 'tablet',
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // C92: Pax header + event recap retired
                                  // (rail owns booking); calendar + time
                                  // only, page scroll retained on tablet.
                                  ReservationCalendarPanel(
                                    key: const Key('tablet_calendar_panel'),
                                    selectedDate: _selectedDate,
                                    onDateSelected: (date) {
                                      ref
                                          .read(bookingFlowProvider.notifier)
                                          .setSelectedDate(date);
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  ReservationDetailsPanel(
                                    key: const Key('tablet_details_panel'),
                                    package: package,
                                    selectedPax: _selectedPax,
                                    // C48: §1 package card retired from the
                                    // schedule step (rail owns that line).
                                    showPackageSummary: false,
                                    onChangePax: null,
                                    selectedTime: _selectedTime,
                                    onTimeSelected: (time) {
                                      ref
                                          .read(bookingFlowProvider.notifier)
                                          .setSelectedTime(time);
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Column: Order Summary (sticky rail — top-pinned; the
              // panel caps itself at viewport height with an internal
              // scroll via isSticky).
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: OrderSummaryPanel(
                      key: const Key('tablet_order_summary_panel'),
                    package: package,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    selectedPax: _selectedPax,
                    paymentMethod: _paymentMethod,
                    actionButtonText: isPayment
                        ? 'Confirm & Pay'
                        : 'Proceed to Payment',
                    isLoading: ref.watch(bookingFlowProvider).isLoading,
                    isSticky: true,
                    onProceed: () {
                      final notifier = ref.read(bookingFlowProvider.notifier);
                      if (_currentStep == 4) {
                        _handleConfirmAndPay();
                      } else if (_currentStep == 3) {
                        // C74: Details → Payment gate (same authority as
                        // mobile `_handleMobileBarTap`).
                        if (!notifier.canProceedFromDetails()) {
                          // C52: validation gate renders inline, never toast.
                          _setFormError('Please fill name, email and venue');
                          return;
                        }
                        _goToStep(4);
                      } else {
                        // Selections live in the notifier; the gate below is
                        // the single authority — nothing to mirror back.
                        // C74: Schedule → Details (never Payment directly).
                        if (!notifier.canProceedFromSchedule()) {
                          // C52: validation gate renders inline, never toast.
                          _setFormError('Please select date and time');
                          return;
                        }
                        _goToStep(3);
                      }
                    },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // C74 WEB DETAILS: step-3 form for desktop/tablet left columns
  // ==========================================================================

  /// C74: Details form rendered in the desktop/tablet left column at
  /// step 3. Reuses [_buildMobileContactField] — the same fields widget
  /// mobile step 3 uses — against the shared screen controllers, so the
  /// provider + payment-panel prefill stay in sync. [keyPrefix] namespaces
  /// the field keys per breakpoint (`desktop`/`tablet`).
  Widget _buildWebDetailsForm({
    required String viewKey,
    required String keyPrefix,
  }) {
    final notifier = ref.read(bookingFlowProvider.notifier);
    return Container(
      key: ValueKey(viewKey),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
          const SizedBox(height: 15),
          _buildMobileContactField(
            controller: _customerNameController,
            keyName: '${keyPrefix}_customer_name',
            label: 'Full Name',
            hint: 'Customer Name',
            icon: Icons.person_outline_rounded,
            textInputType: TextInputType.name,
            onChanged: (v) => notifier.setCustomerName(v),
          ),
          const SizedBox(height: 12),
          _buildMobileContactField(
            controller: _customerEmailController,
            keyName: '${keyPrefix}_customer_email',
            label: 'Email Address',
            hint: 'name@example.com',
            icon: Icons.email_outlined,
            textInputType: TextInputType.emailAddress,
            onChanged: (v) => notifier.setCustomerEmail(v),
          ),
          const SizedBox(height: 12),
          _buildMobileContactField(
            controller: _customerPhoneController,
            keyName: '${keyPrefix}_customer_phone',
            label: 'Contact Phone',
            hint: '+63 9XX XXX XXXX',
            icon: Icons.phone_outlined,
            textInputType: TextInputType.phone,
            onChanged: (v) => notifier.setCustomerPhone(v),
          ),
          const SizedBox(height: 12),
          _buildMobileContactField(
            controller: _venueAddressController,
            keyName: '${keyPrefix}_venue_address',
            label: 'Event Venue / Address',
            hint: 'e.g. Grand Ballroom, Makati',
            icon: Icons.location_on_outlined,
            textInputType: TextInputType.streetAddress,
            onChanged: (v) => notifier.setVenueAddress(v),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // C92 SCHEDULE: single "Select Date & Time" card (desktop)
  // ==========================================================================

  /// C92: one card holding the calendar (inner col 1) + the event-time
  /// picker (inner col 2). No Pax UI, no event recap — the `Your Booking`
  /// rail (col 3) owns that line. Desktop-only; tablet keeps its stacked
  /// calendar + details panel, mobile keeps its own step flow.
  Widget _buildScheduleDateTimeCard() {
    return Container(
      key: const Key('schedule_datetime_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date & Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _title,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inner col 1: calendar (grid only — the card owns the
              // "Select Date & Time" chrome, C92).
              Expanded(
                child: ReservationCalendarPanel(
                  key: const Key('reservation_calendar_panel'),
                  selectedDate: _selectedDate,
                  showChrome: false,
                  onDateSelected: (date) {
                    ref
                        .read(bookingFlowProvider.notifier)
                        .setSelectedDate(date);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Inner col 2: event time.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Event Time',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'One booking lasts 3–4 hrs.',
                      style: TextStyle(fontSize: 12, color: _body),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      key: const Key('event_time_picker_button'),
                      onTap: () => _pickEventTime(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          // C152: dark-aware fill (was hardcoded light cream).
                          color: CardSurfaces.chipBg(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: plum,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedTime == null
                                    ? 'Select time'
                                    : TimeSlot.display(_selectedTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedTime == null
                                      ? FontWeight.normal
                                      : FontWeight.w700,
                                  color: _title,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: plum,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // C48 MOBILE SCHEDULE: collapsed summary + sticky bottom bar
  // ==========================================================================

  /// Collapsed schedule summary (mobile step 2 only): the verbatim
  /// `{pax} PAX · {date} · {time}` one-liner + `Total ₱` row. The full
  /// summary renders only via the disclosure below — never inline, and
  /// never with a second CTA (the bar owns conversion).
  Widget _buildMobileScheduleCollapsedSummary(
    Package package,
    List<int> paxEntries,
  ) {
    final effectivePax =
        _selectedPax ?? (paxEntries.isNotEmpty ? paxEntries.first : 50);
    final oneLiner =
        '$effectivePax PAX · ${_shortDate(_selectedDate)} · ${TimeSlot.display(_selectedTime)}';
    final total = formatPeso(package.priceForPax(_selectedPax));
    // C75: row cuts apply here too — no venue row (venue lives in the
    // Details step), no full lists; a single count caption preserves the
    // signal without breaking scannability.
    final inclusionsCount =
        (package.inclusions ?? const <String>[]).length +
        (package.freebies ?? const <String>[]).length;
    final inclusionsCaption = inclusionsCount == 0
        ? 'No inclusions listed'
        : '$inclusionsCount inclusion${inclusionsCount == 1 ? '' : 's'}';

    return Container(
      key: const Key('mobile_schedule_collapsed_summary'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            oneLiner,
            key: const Key('mobile_schedule_collapsed_oneliner'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _title,
              height: 1.3,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _title,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  total,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _title,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            key: const Key('mobile_schedule_collapsed_toggle'),
            onTap: () => setState(
              () => _scheduleSummaryExpanded = !_scheduleSummaryExpanded,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _scheduleSummaryExpanded ? 'Hide details' : 'View details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _title,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          if (_scheduleSummaryExpanded) ...[
            Text(
              inclusionsCaption,
              style: TextStyle(fontSize: 12, color: _body, height: 1.3),
              softWrap: true,
            ),
          ],
        ],
      ),
    );
  }

  /// Sticky mobile conversion bar. Lives OUTSIDE the page scroll as the
  /// Scaffold's [bottomNavigationBar] so the C40 clamp never fights
  /// stickiness. Labels: `Proceed` (step 2), `Proceed to Payment`
  /// (step 3), `Confirm & Pay ₱` (step 4). Null off-flow (checkout).
  /// C63: the SafeArea (top:false) keeps the bar above the bottom
  /// system inset; the step column's 28px bottom padding (see
  /// _buildMobileLayout) keeps content clear of the bar.
  Widget? _buildMobileBottomBar(Package package) {
    if (_currentStep != 2 && _currentStep != 3 && _currentStep != 4) {
      return null;
    }
    final isLoading = ref.watch(bookingFlowProvider).isLoading;
    final total = formatPeso(package.priceForPax(_selectedPax));
    final label = _currentStep == 4
        ? 'Confirm & Pay $total'
        : _currentStep == 3
        ? 'Proceed to Payment'
        : 'Proceed';

    return SafeArea(
      top: false,
      child: Container(
        key: const Key('mobile_booking_bottom_bar'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        decoration: BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: _surfaceBorder)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(fontSize: 11, color: _body)),
                const SizedBox(height: 2),
                Text(
                  total,
                  key: const Key('mobile_bottom_bar_total'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _title,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                // C68: press-scale on the conversion CTA (no restyle).
                child: PressScale(
                  child: ElevatedButton(
                    key: const Key('mobile_bottom_bar_cta'),
                    onPressed: isLoading ? null : () => _handleMobileBarTap(),
                    // P7: theme ElevatedButton drives both modes.
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(label, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile bar tap: same per-step gates as the retired in-column CTA —
  /// [canProceedFromSchedule]/[canProceedFromDetails] stay the single
  /// authorities, failures render inline via C52 [_formError], the
  /// `14:00:00` prefill and `_submitting` guard unchanged.
  void _handleMobileBarTap() {
    final notifier = ref.read(bookingFlowProvider.notifier);
    if (_currentStep == 4) {
      _handleConfirmAndPay();
    } else if (_currentStep == 2) {
      if (!notifier.canProceedFromSchedule()) {
        // C52: validation gate renders inline, never toast.
        _setFormError('Please select date and time');
        return;
      }
      notifier.nextStep();
    } else if (_currentStep == 3) {
      if (!notifier.canProceedFromDetails()) {
        // C52: validation gate renders inline, never toast.
        _setFormError('Please fill name, email and venue');
        return;
      }
      notifier.nextStep();
    } else {
      notifier.nextStep();
    }
  }

  // ==========================================================================
  // MOBILE 1-COLUMN LAYOUT (<768px)
  // ==========================================================================

  Widget _buildMobileLayout(Package package) {
    // C48: the sticky bottom bar (Scaffold.bottomNavigationBar) owns
    // conversion — one CTA, never two on screen. The in-column button
    // is retired; this column carries content only.
    // C63: extra bottom scroll padding (28 > bar-adjacent 20) so the
    // last item scrolls fully above the sticky bar — content is never
    // hidden behind it at 360px width.
    return Column(
      children: [
        _buildHeader(showBack: true),
        _buildTimeline(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formErrorSlot(),
              // C65: mobile stage body slides + fades on step change.
              _stageSwitcher(
                step: _currentStep,
                child: _buildCurrentStep(package),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP / TABLET HEADER
  // ==========================================================================

  Widget _buildDesktopHeader(Package package) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              // Stepwise backward nav (mobile parity): header Back is
              // previousStep() — 4→3→2 — never a direct jump to Schedule.
              if (_currentStep > 2) {
                ref.read(bookingFlowProvider.notifier).previousStep();
              } else if (context.canPop()) {
                context.pop();
              } else {
                try {
                  context.go('/home');
                } catch (_) {}
              }
            },
            icon: Icon(Icons.arrow_back_rounded, color: _title, size: 20),
            label: Text(
              'Back',
              style: TextStyle(
                color: _title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 18, width: 1, color: _surfaceBorder),
          const SizedBox(width: 10),
          // C27: one timeline everywhere — Schedule/Details/Payment
          // identical on mobile + web; divergent crumbs deleted.
          Expanded(child: _buildTimeline()),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  // ==========================================================================
  // CHECKOUT STATUS SCREEN
  // ==========================================================================

  String _bookingReference() {
    return ref.read(bookingFlowProvider).booking?.bookingReference ?? '—';
  }

  Widget _buildCheckoutScreen() {
    final flowState = ref.watch(bookingFlowProvider);
    final status = flowState.checkoutStatus;
    final reference = _bookingReference();

    final Widget content;
    if (status == BookingCheckoutStatus.confirmed) {
      content = _buildCheckoutCard(
        iconData: Icons.check_rounded,
        iconColor: SuccessCheck.successGreen,
        title: 'Payment Successful',
        messageLines: [
          'Thank you for your booking.',
          '',
          'Booking reference: $reference',
          'To check your status go to your booking settings.',
        ],
        buttonLabel: 'Done',
        buttonIcon: Icons.arrow_forward_rounded,
        onPressed: () {
          ref.read(bookingFlowProvider.notifier).reset();
          try {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          } catch (_) {}
        },
      );
    } else if (status == BookingCheckoutStatus.awaitingAdmin) {
      content = _buildCheckoutCard(
        iconData: Icons.schedule_rounded,
        iconColor: IneaCalendar.bookedAmber,
        title: 'Awaiting Admin Confirmation',
        messageLines: [
          'Your booking has been received.',
          '',
          'Booking reference: $reference',
          'Our team will confirm once your ${flowState.paymentMethod == 'cash' ? 'cash payment' : 'bank transfer'} is processed.',
        ],
        buttonLabel: 'Check Status',
        buttonIcon: Icons.refresh_rounded,
        onPressed: () {
          ref.read(bookingFlowProvider.notifier).checkStatusImmediate();
        },
      );
    } else if (status == BookingCheckoutStatus.cancelled) {
      content = _buildCheckoutCard(
        iconData: Icons.cancel_rounded,
        iconColor: IneaCalendar.bookedAmber,
        title: 'Booking Not Completed',
        messageLines: [
          'The payment link expired or the booking was cancelled.',
          '',
          'You can create a fresh booking to try again.',
        ],
        buttonLabel: 'Rebook',
        buttonIcon: Icons.restart_alt_rounded,
        onPressed: () {
          ref.read(bookingFlowProvider.notifier).rebook();
          _goToStep(2);
        },
      );
    } else if (status == BookingCheckoutStatus.awaitingPayment) {
      content = _buildCheckoutCard(
        iconData: Icons.hourglass_top_rounded,
        iconColor: plum,
        title: 'Processing Your Payment',
        messageLines: [
          'A secure checkout page should have opened in a new tab.',
          'If it did not, tap below to open it.',
          '',
          'Booking reference: $reference',
          'We are waiting for payment confirmation.',
        ],
        buttonLabel: 'Open Checkout Page',
        buttonIcon: Icons.open_in_new_rounded,
        onPressed: () {
          unawaited(_openCheckoutFromState());
        },
        secondaryLabel: 'Recheck status',
        secondaryIcon: Icons.refresh_rounded,
        secondaryOnPressed: () {
          ref.read(bookingFlowProvider.notifier).checkStatusImmediate();
        },
        showSpinner: true,
      );
    } else {
      final error = flowState.errorMessage;
      if (error != null && error.isNotEmpty) {
        // P6 (Q8): friendly copy — the raw error stays in logs only.
        content = _buildCheckoutCard(
          iconData: Icons.error_outline_rounded,
          iconColor: IneaCalendar.bookedAmber,
          title: 'Unable to Submit Booking',
          messageLines: [
            "We couldn't place your booking. Nothing was charged — "
                'please try again.',
          ],
          buttonLabel: 'Try Again',
          buttonIcon: Icons.refresh_rounded,
          onPressed: () {
            _goToStep(4);
          },
        );
      } else {
        content = _buildCheckoutCard(
          iconData: Icons.check_rounded,
          iconColor: SuccessCheck.successGreen,
          title: 'Booking Submitted',
          messageLines: ['Your booking is being processed.'],
          buttonLabel: 'Done',
          buttonIcon: Icons.arrow_forward_rounded,
          onPressed: () {
            ref.read(bookingFlowProvider.notifier).reset();
            try {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            } catch (_) {}
          },
        );
      }
    }

    return Column(
      children: [
        if (MediaQuery.of(context).size.width < 768)
          _buildHeader(showBack: false),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
          child: _formErrorSlot(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(child: content),
        ),
      ],
    );
  }

  /// C70: only the success moment (green check) draws in; every other
  /// checkout status keeps its static icon.
  static bool _isSuccessCheck(IconData iconData, Color iconColor) {
    return iconData == Icons.check_rounded &&
        iconColor.toARGB32() == SuccessCheck.successGreen.toARGB32();
  }

  Widget _buildCheckoutCard({
    required IconData iconData,
    required Color iconColor,
    required String title,
    required List<String> messageLines,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback? onPressed,
    String? secondaryLabel,
    IconData? secondaryIcon,
    VoidCallback? secondaryOnPressed,
    bool showSpinner = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: plum.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            // C70: success moment draws the check in (≤350ms stroke);
            // other statuses keep their static icon. Same 40px box either
            // way, so no layout shift.
            child: _isSuccessCheck(iconData, iconColor)
                ? const SuccessCheck()
                : Icon(iconData, color: _surface, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _title,
            ),
          ),
          const SizedBox(height: 18),
          ...messageLines.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                line,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _body, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (showSpinner) ...[
            const SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(strokeWidth: 3, color: plum),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(buttonIcon, size: 18),
              label: Text(buttonLabel),
              // C31: theme ElevatedButton supplies the plum/cream
              // token in both modes (no per-screen colors).
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: secondaryOnPressed,
                icon: Icon(secondaryIcon ?? Icons.refresh_rounded, size: 18),
                label: Text(secondaryLabel),
                // C31: theme TextButton supplies the legible
                // label token per mode (plum-on-night removed).
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // MOBILE SUB-WIDGETS
  // ==========================================================================

  Widget _buildHeader({required bool showBack}) {
    // C22: distilled — plain-text brand mark + dead chat/calendar icons
    // removed. Desktop TopNavBar covers nav; only the functional Back
    // stays (48px touch). Edit paths untouched (no route deletions).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            TextButton.icon(
              onPressed: () {
                if (_currentStep > 2) {
                  ref.read(bookingFlowProvider.notifier).previousStep();
                } else {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    try {
                      context.go('/home');
                    } catch (_) {}
                  }
                }
              },
              icon: Icon(Icons.arrow_back, color: _title, size: 20),
              label: Text(
                'Back',
                style: TextStyle(color: _title, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(48, 48),
              ),
            )
          else
            const SizedBox(width: 60),

          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // C19: 3-step wizard — Pax Choice and Scents are chosen before
    // entering the flow (?pax= + scent shelf), so the timeline shows
    // Schedule (2) → Details (3) → Payment (4).
    // C65: dots + connectors animate via AnimatedContainer (200ms
    // ease-out); reduced motion settles instantly (zero duration).
    final steps = ['Schedule', 'Details', 'Payment'];
    final flowIndex = (_currentStep - 2).clamp(0, 2);
    final reduce = _isReducedMotion(context);
    final animDuration = reduce
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final doneColor = plum;
    const todoColor = Color(0xFF99868C);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isPast = index < flowIndex;
          final isCurrent = index == flowIndex;
          final active = isPast || isCurrent;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index == 0)
                      const Expanded(child: SizedBox())
                    else
                      Expanded(
                        child: AnimatedContainer(
                          key: Key('timeline_connector_before_$index'),
                          duration: animDuration,
                          curve: Curves.easeOut,
                          height: 3,
                          color: isPast || isCurrent ? doneColor : todoColor,
                        ),
                      ),
                    Semantics(
                      selected: isCurrent,
                      label: steps[index],
                      child: AnimatedContainer(
                        key: Key('timeline_dot_$index'),
                        duration: animDuration,
                        curve: Curves.easeOut,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: active ? doneColor : todoColor,
                          shape: BoxShape.circle,
                        ),
                        child: active
                            ? Icon(Icons.check, size: 12, color: _surface)
                            : null,
                      ),
                    ),
                    if (index == steps.length - 1)
                      const Expanded(child: SizedBox())
                    else
                      Expanded(
                        child: AnimatedContainer(
                          key: Key('timeline_connector_after_$index'),
                          duration: animDuration,
                          curve: Curves.easeOut,
                          height: 3,
                          color: index < flowIndex ? doneColor : todoColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    // C36: title token both states (was plum/muted, fails 7:1).
                    color: _title,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(Package package) {
    if (_currentStep == 2) {
      // Schedule Step
      final options = package.options;
      // API options first, legacy paxOptions second, never a hardcoded list:
      // an empty list renders a flagged notice instead of silent pricing.
      final paxEntries = options.isNotEmpty
          ? options.map((t) => t.pax).toList()
          : (package.paxOptions ?? const <int>[]);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // C92: no Pax header in Schedule (headcount came via `?pax=`;
          // the collapsed summary below carries the PAX one-liner).
          Text(
            'Please Choose Available Schedule',
            // C36: title token (was plum, fails 7:1 on tinted fills).
            style: TextStyle(fontSize: 13, color: _title),
          ),
          const SizedBox(height: 15),
          IneaCalendar(
            key: const Key('mobile_inea_calendar'),
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              ref.read(bookingFlowProvider.notifier).setSelectedDate(date);
            },
          ),
          const SizedBox(height: 25),
          Text(
            'Choose Event Time',
            // C36: title token (was plum).
            style: TextStyle(fontSize: 13, color: _title),
          ),
          const SizedBox(height: 4),
          Text(
            'One booking lasts 3–4 hrs.',
            // C36: title token (was translucent plum, fails 7:1).
            style: TextStyle(fontSize: 12, color: _title),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _surfaceBorder),
            ),
            child: InkWell(
              key: const Key('event_time_picker_button'),
              onTap: () => _pickEventTime(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  // C152: dark-aware fill (was hardcoded light cream).
                  color: CardSurfaces.chipBg(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 18, color: plum),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedTime == null
                            ? 'Select time'
                            : TimeSlot.display(_selectedTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedTime == null
                              ? FontWeight.normal
                              : FontWeight.w700,
                          color: _title,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: plum,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          // C92: event recap retired (editing stays in step 3).
          // Proper-noun header (grill Q3a): the flow step already says
          // what this is; the product name carries the weight.
          // C48: survives only as the mobile stack section label (the
          // §1 package card stays retired from the schedule step).
          Text(
            package.name ?? 'Perfume Bar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _title,
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileScheduleCollapsedSummary(package, paxEntries),
        ],
      );
    } else if (_currentStep == 3) {
      // Details Step
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
          const SizedBox(height: 15),
          // C27: single column under 768px; desktop row untouched.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const Key('mobile_details_summary_card'),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(fontSize: 14, color: _title),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Pax Choice: ${package.name}',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Inclusions:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    ...(package.inclusions ?? []).map(
                      (e) => Text(
                        '• $e',
                        style: TextStyle(fontSize: 12, color: _title),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Freebies:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    ...(package.freebies ?? []).map(
                      (e) => Text(
                        '• $e',
                        style: TextStyle(fontSize: 12, color: _title),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Selected Date:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                          : 'Not selected',
                      style: TextStyle(fontSize: 13, color: _title),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Selected Time:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      TimeSlot.display(_selectedTime),
                      style: TextStyle(fontSize: 13, color: _title),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Selected Pax:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_selectedPax ?? 50} PAX',
                      style: TextStyle(fontSize: 13, color: _title),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Total Cost:',
                      style: TextStyle(fontSize: 13, color: _body),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatPeso(package.priceForPax(_selectedPax)),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _title,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Your Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileContactField(
                  controller: _customerNameController,
                  keyName: 'mobile_customer_name',
                  label: 'Full Name',
                  hint: 'Customer Name',
                  icon: Icons.person_outline_rounded,
                  textInputType: TextInputType.name,
                  onChanged: (v) =>
                      ref.read(bookingFlowProvider.notifier).setCustomerName(v),
                ),
                const SizedBox(height: 12),
                _buildMobileContactField(
                  controller: _customerEmailController,
                  keyName: 'mobile_customer_email',
                  label: 'Email Address',
                  hint: 'name@example.com',
                  icon: Icons.email_outlined,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (v) => ref
                      .read(bookingFlowProvider.notifier)
                      .setCustomerEmail(v),
                ),
                const SizedBox(height: 12),
                _buildMobileContactField(
                  controller: _customerPhoneController,
                  keyName: 'mobile_customer_phone',
                  label: 'Contact Phone',
                  hint: '+63 9XX XXX XXXX',
                  icon: Icons.phone_outlined,
                  textInputType: TextInputType.phone,
                  onChanged: (v) => ref
                      .read(bookingFlowProvider.notifier)
                      .setCustomerPhone(v),
                ),
                const SizedBox(height: 12),
                _buildMobileContactField(
                  controller: _venueAddressController,
                  keyName: 'mobile_venue_address',
                  label: 'Event Venue / Address',
                  hint: 'e.g. Grand Ballroom, Makati',
                  icon: Icons.location_on_outlined,
                  textInputType: TextInputType.streetAddress,
                  onChanged: (v) =>
                      ref.read(bookingFlowProvider.notifier).setVenueAddress(v),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Payment Step (step 4; 2/3 handled above, 5 returns earlier).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _title,
                  ),
                ),
                const SizedBox(height: 12),
                // C64: scannable price rows — package/Pax line, then total.
                // No fee model exists; no fee row is rendered (no invented
                // math). Labels left, amounts right-aligned tabular, wrap
                // never truncates amounts.
                Row(
                  key: const Key('price_details_pax_row'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedPax ?? 50} PAX · tier price',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _title,
                          height: 1.35,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        formatPeso(package.priceForPax(_selectedPax)),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _title,
                          height: 1.35,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        softWrap: true,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // C154: two labeled subgroups mirroring the Details card
                // (Inclusions:/Freebies:) — rows keep Included/Free amounts.
                Text(
                  'Inclusions:',
                  style: TextStyle(fontSize: 12, color: _body),
                ),
                const SizedBox(height: 10),
                // Live package data — same source as the desktop summary.
                // No per-item prices exist; rows show Included/Free.
                ...?package.inclusions?.map(
                  (label) => {'label': label, 'val': 'Included'},
                ).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item['label']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _title,
                              height: 1.35,
                            ),
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['val']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _body,
                            height: 1.35,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          softWrap: true,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Text(
                  'Freebies:',
                  style: TextStyle(fontSize: 12, color: _body),
                ),
                const SizedBox(height: 10),
                ...?package.freebies?.map(
                  (label) => {'label': label, 'val': 'Free'},
                ).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item['label']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _title,
                              height: 1.35,
                            ),
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['val']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _body,
                            height: 1.35,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          softWrap: true,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: _surfaceBorder, thickness: 1),
                ),
                Row(
                  key: const Key('price_details_total_row'),
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _title,
                          height: 1.35,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      key: const Key('price_details_total_amount'),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatPeso(package.priceForPax(_selectedPax)),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _title,
                            height: 1.35,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          softWrap: true,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _title,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        {
                          'id': 'online',
                          'label': 'Online',
                          'color': const Color(0xFFEB001B),
                        },
                        {
                          'id': 'cash',
                          'label': 'Cash',
                          // C77: same brand treatment as the online chip.
                          'color': const Color(0xFFEB001B),
                        },
                      ].map((m) {
                        final isSel = _paymentMethod == m['id'];
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 138) / 2,
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(bookingFlowProvider.notifier)
                                  .setPaymentMethod(m['id'] as String);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? (m['color'] as Color).withValues(
                                        alpha: 0.15,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                // P7 (Q4): constant width; color signals state.
                                border: Border.all(
                                  color: isSel
                                      ? (m['color'] as Color)
                                      : _surfaceBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                m['label'] as String,
                                style: TextStyle(
                                  // C33: title token (AAA 4.5+ UI).
                                  color: _title,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    }

  }

  Widget _buildMobileContactField({
    required TextEditingController controller,
    required String keyName,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType textInputType,
    required ValueChanged<String> onChanged,
  }) {
    // Borders/fill inherit InputDecorationTheme (radius 12).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: _title)),
        const SizedBox(height: 6),
        TextField(
          key: ValueKey(keyName),
          controller: controller,
          keyboardType: textInputType,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: _title),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: _body),
            prefixIcon: Icon(icon, size: 20, color: _body),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
