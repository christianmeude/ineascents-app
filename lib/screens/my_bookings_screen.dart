import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../utils/peso.dart';
import '../utils/feedback_api.dart';
import '../utils/feedback_store.dart';
import '../widgets/index.dart';

// C78: sort keys for the bookings list (below header).
enum _BookingsSort { recent, status, price, eventDate }

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  // C115: dead local palette removed (P6 ambient lives in the shell;
  // text/border resolve via CardSurfaces). Only the primary alias stays.
  static const Color primaryColor = AppTheme.primary;

  @override
  ConsumerState<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

// ============================================================================
// BOOKINGS LIST STATE (C78: sort / filter / search, all below header)
// ============================================================================

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  _BookingsSort _sort = _BookingsSort.recent;
  bool _descending = true;
  String _statusFilter = 'All';
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  // C146: client-detected completion + once-per-booking feedback popup.
  // Both are guarded per Booking id so rebuilds never re-fire them.
  final Set<int> _completeAttempted = <int>{};
  final Set<int> _promptedIds = <int>{};
  bool _handlingPostLoad = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const Map<_BookingsSort, String> _sortLabels = {
    _BookingsSort.recent: 'Most recent',
    _BookingsSort.status: 'Status',
    _BookingsSort.price: 'Price',
    _BookingsSort.eventDate: 'Event date',
  };

  void _selectSort(_BookingsSort key) {
    setState(() {
      if (_sort == key) {
        _descending = !_descending;
      } else {
        _sort = key;
        _descending = key == _BookingsSort.recent;
      }
    });
  }

  void _openFilters(BuildContext context, List<String> statuses) {
    final wide =
        MediaQuery.of(context).size.width >=
        ResponsiveAppShell.mobileBreakpoint;
    // Panel reads live parent state at build time; both setState calls
    // keep the list below and the open panel in sync.
    Widget buildPanel(StateSetter setPanel) => _BookingsFilterPanel(
      sort: _sort,
      descending: _descending,
      statusFilter: _statusFilter,
      statuses: statuses,
      onSelectSort: (key) {
        setState(() => _selectSort(key));
        setPanel(() {});
      },
      onSelectStatus: (s) {
        setState(() => _statusFilter = s);
        setPanel(() {});
      },
      onReset: () {
        setState(() {
          _sort = _BookingsSort.recent;
          _descending = true;
          _statusFilter = 'All';
          _query = '';
          _searchController.clear();
        });
        setPanel(() {});
      },
    );
    if (wide) {
      // C87: web/tablet (≥768px) opens a popover-style dialog panel.
      showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setPanel) => Dialog(
            key: const Key('bookings_filter_dialog'),
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: buildPanel(setPanel),
            ),
          ),
        ),
      );
    } else {
      // C87: mobile (<768px) opens a bottom sheet with the same panel.
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setPanel) => SafeArea(
            child: buildPanel(setPanel),
          ),
        ),
      );
    }
  }

  bool get _hasActiveFilters =>
      _sort != _BookingsSort.recent ||
      _descending != true ||
      _statusFilter != 'All' ||
      _query.trim().isNotEmpty;

  double? _priceOf(Booking b) =>
      b.package == null ? null : b.package!.priceForPax(b.pax);

  // C78: Booking has no createdAt — most recent first = highest id first.
  // Nulls always sort last, in both directions.
  List<Booking> _visible(List<Booking> bookings) {
    final q = _query.trim().toLowerCase();
    final list = bookings.where((b) {
      if (_statusFilter != 'All' &&
          (b.status ?? 'Unknown') != _statusFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final haystack =
          '${b.bookingReference ?? ''} ${b.customerName ?? ''} '
          '${b.package?.name ?? ''} ${b.id ?? ''}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
    int cmp(Booking a, Booking b) {
      int directed(int c) => _descending ? -c : c;
      switch (_sort) {
        case _BookingsSort.recent:
          final ia = a.id;
          final ib = b.id;
          if (ia == null && ib == null) return 0;
          if (ia == null) return 1;
          if (ib == null) return -1;
          return directed(ia.compareTo(ib));
        case _BookingsSort.status:
          return directed(
              (a.status ?? '').compareTo(b.status ?? ''));
        case _BookingsSort.price:
          final pa = _priceOf(a);
          final pb = _priceOf(b);
          if (pa == null && pb == null) return 0;
          if (pa == null) return 1;
          if (pb == null) return -1;
          return directed(pa.compareTo(pb));
        case _BookingsSort.eventDate:
          final da = a.eventDate;
          final db = b.eventDate;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return directed(da.compareTo(db));
      }
    }

    list.sort(cmp);
    return list;
  }

  /// C146: runs once per loaded list — fires client-detected completion for
  /// past Confirmed Bookings, then shows the once-per-booking feedback popup
  /// for the first eligible Completed Booking. All network failures are
  /// swallowed (backend A37 may not be live; offline must stay graceful).
  Future<void> _handlePostLoad(List<Booking> bookings) async {
    if (_handlingPostLoad || !mounted) return;
    _handlingPostLoad = true;
    try {
      for (final booking in bookings) {
        final id = booking.id;
        if (id == null ||
            _completeAttempted.contains(id) ||
            !isConfirmedStatus(booking.status) ||
            !isEventPast(booking.eventDate)) {
          continue;
        }
        _completeAttempted.add(id);
        try {
          await ref.read(feedbackApiProvider).completeBooking(id);
          ref.invalidate(bookingsProvider);
        } catch (_) {
          // Graceful offline: retry next load; popup logic below still runs
          // off the cached Status.
        }
      }

      final submitted = await FeedbackStore.submittedIds();
      if (!mounted) return;
      final seen = await FeedbackStore.seenIds();
      if (!mounted) return;
      Booking? candidate;
      for (final booking in bookings) {
        final id = booking.id;
        if (id == null ||
            _promptedIds.contains(id) ||
            submitted.contains(id) ||
            seen.contains(id) ||
            !isCompletedStatus(booking.status) ||
            !isEventPast(booking.eventDate)) {
          continue;
        }
        candidate = booking;
        break;
      }
      final target = candidate;
      if (target == null || target.id == null) return;
      _promptedIds.add(target.id!);
      if (!mounted) return;
      await showFeedbackDialog(context, target.id);
      if (!mounted) return;
      // Dismiss (`Not now`, back, tap-outside) never nags again for this
      // popup instance; submit already persisted via the dialog.
      await FeedbackStore.markSeen(target.id!);
      ref.read(feedbackRefreshProvider.notifier).state++;
      if (mounted) setState(() {});
    } finally {
      _handlingPostLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);
    // C43: header is title+count only (book-another removed);
    // empty state keeps its own CTA to /packages.

    // P7: no explicit color — flat theme scaffold background.
    // C43: header shows title+count only (no book-another affordance).
    return Scaffold(

      // ============================================================
      // BODY (P7: flat theme background; decorative gradient removed)
      // ============================================================
      body: SafeArea(
        child: bookingsAsync.when(
          data: (bookings) {
            // C146: post-load side effects (completion + feedback popup)
            // run once per frame, guarded per Booking id inside.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _handlePostLoad(bookings),
            );
            final visible = _visible(bookings);
            final statuses = <String>['All'];
            for (final b in bookings) {
              final s = b.status ?? 'Unknown';
              if (!statuses.contains(s)) statuses.add(s);
            }
            if (bookings.isEmpty) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ResponsiveAppShell.maxContentWidth,
                  ),
                  child: Padding(
                    padding: ResponsiveAppShell.screenHeaderPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // C42: unified header over the empty state.
                        const TabHeader(
                          title: 'My Bookings',
                          count: '0 bookings',
                        ),
                        const Expanded(child: _EmptyBookings()),
                      ],
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: MyBookingsScreen.primaryColor,
              onRefresh: () => ref.refresh(bookingsProvider.future),
              child: SingleChildScrollView(
                // C40: clamp overscroll on mobile (<768px); SDK default
                // (stretch Android / bounce iOS) displaced content past edge.
                // Desktop/web physics untouched (null = platform default).
                physics: MobileClampScroll.physicsOf(context),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: ResponsiveAppShell.maxContentWidth,
                    ),
                    child: Padding(
                      padding: ResponsiveAppShell.screenHeaderPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ==================================================
                          // PAGE HEADER (C42: unified header, trailing
                          // empty — C43 title+count adopted as-is)
                          // ==================================================
                          TabHeader(
                            title: 'My Bookings',
                            count: '${visible.length} '
                                '${visible.length == 1 ? 'booking' : 'bookings'}',
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // CONTROLS (C87: search row below the header —
                          // search field + trailing filter button at its
                          // right; sort + status live inside the
                          // popover (≥768px) / bottom sheet (<768px),
                          // zero bare chips in the main layout)
                          // ==================================================
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  key: const Key(
                                    'bookings_search_field',
                                  ),
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Search reference, name, or package',
                                    prefixIcon: Icon(
                                      Icons.search_outlined,
                                    ),
                                  ),
                                  onChanged: (value) => setState(
                                    () => _query = value,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // C87: filter affordance sits at the search
                              // bar's right — never at header level.
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    key: const Key(
                                      'bookings_filter_button',
                                    ),
                                    tooltip: 'Filter bookings',
                                    icon: const Icon(
                                      Icons.filter_list_outlined,
                                    ),
                                    onPressed: () => _openFilters(
                                      context,
                                      statuses,
                                    ),
                                  ),
                                  if (_hasActiveFilters)
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyBookingsScreen
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          if (visible.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 32),
                              child: Center(
                                child: Text(
                                  'No bookings match your filters.',
                                ),
                              ),
                            )
                          else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cards = visible
                                  .map(
                                    (booking) => _BookingCard(booking: booking),
                                  )
                                  .toList();

                          // Cards below render `visible` (filtered + sorted).

                              if (constraints.maxWidth <=
                                  ResponsiveAppShell.tabletBreakpoint) {
                                return Column(children: cards);
                              }
                              final rows = <Widget>[];
                              for (var i = 0; i < cards.length; i += 2) {
                                final pair = cards.sublist(
                                  i,
                                  (i + 2).clamp(0, cards.length),
                                );
                                rows.add(
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: pair[0]),
                                      if (pair.length > 1) ...[
                                        const SizedBox(width: 24),
                                        Expanded(child: pair[1]),
                                      ] else
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                    ],
                                  ),
                                );
                                rows.add(const SizedBox(height: 2));
                              }
                              return Column(children: rows);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },

          // ======================================================
          // LOADING
          // ======================================================
          loading: () => SingleChildScrollView(
            physics: MobileClampScroll.physicsOf(context),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ResponsiveAppShell.maxContentWidth,
                ),
                child: Padding(
                  padding: ResponsiveAppShell.screenHeaderPadding,
                  child: const SkeletonBookingsList(),
                ),
              ),
            ),
          ),

          // ======================================================
          // ERROR
          // ======================================================
          // P6 (Q6/Q8): shared friendly card; raw errors stay
          // in logs, never on screen.
          error: (error, stack) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ErrorStateCard(
                  title: 'Unable to load bookings',
                  message:
                      "We couldn't load your bookings. "
                      'Check your connection and try again.',
                  onRetry: () => ref.invalidate(bookingsProvider),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// BOOKINGS FILTER PANEL (C87: sort + status re-housed here; C90: search
// lives only in the in-row field below the header, never in this panel;
// C78 semantics preserved — parent owns state, panel only forwards)
// Wide (≥768px): shown in a Dialog popover. Narrow: bottom sheet.
// ============================================================================

class _BookingsFilterPanel extends StatefulWidget {
  final _BookingsSort sort;
  final bool descending;
  final String statusFilter;
  final List<String> statuses;
  final ValueChanged<_BookingsSort> onSelectSort;
  final ValueChanged<String> onSelectStatus;
  final VoidCallback onReset;

  const _BookingsFilterPanel({
    required this.sort,
    required this.descending,
    required this.statusFilter,
    required this.statuses,
    required this.onSelectSort,
    required this.onSelectStatus,
    required this.onReset,
  });

  @override
  State<_BookingsFilterPanel> createState() => _BookingsFilterPanelState();
}

class _BookingsFilterPanelState extends State<_BookingsFilterPanel> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filter bookings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close filters',
                icon: const Icon(Icons.close_outlined),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in _BookingsSort.values)
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _MyBookingsScreenState._sortLabels[key]!,
                      ),
                      if (widget.sort == key)
                        Icon(
                          widget.descending
                              ? Icons.arrow_downward_outlined
                              : Icons.arrow_upward_outlined,
                          size: 14,
                        ),
                    ],
                  ),
                  selected: widget.sort == key,
                  onSelected: (_) => setState(
                    () => widget.onSelectSort(key),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Booking status',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in widget.statuses)
                FilterChip(
                  label: Text(s),
                  selected: widget.statusFilter == s,
                  onSelected: (_) => setState(
                    () => widget.onSelectStatus(s),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(widget.onReset),
                child: const Text('Reset'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Show results'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOOKING CARD
// ============================================================================

class _BookingCard extends ConsumerWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // C51: live flow subscription — the in-flight Booking's fresh Status
    // (flipped by poll/recheck) renders here with no list refresh. Any
    // other row keeps its cached copy.
    final flowBooking = ref.watch(
      bookingFlowProvider.select((s) => s.booking),
    );
    final live =
        (flowBooking != null &&
            flowBooking.id != null &&
            flowBooking.id == booking.id)
        ? flowBooking
        : booking;
    final status = live.status.toString();
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () => context.push('/bookings/${booking.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),

      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: CardSurfaces.cardBorder(context), width: 1),

        boxShadow: [
          BoxShadow(
            color: MyBookingsScreen.primaryColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // TOP ROW
            // ==========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking icon
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: CardSurfaces.chipBg(context),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Icon(
                    Icons.local_mall_outlined,
                    color: CardSurfaces.title(context),
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                // Booking reference
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKING REFERENCE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: CardSurfaces.body(context),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        live.bookingReference ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CardSurfaces.title(context),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status
                _StatusBadge(status: status, color: statusColor),
              ],
            ),

            const SizedBox(height: 18),

            // ==========================================================
            // DIVIDER
            // ==========================================================
            Container(height: 1, color: CardSurfaces.cardBorder(context)),

            const SizedBox(height: 17),

            // ==========================================================
            // PACKAGE NAME
            // ==========================================================
            Text(
              live.package?.name ?? 'Unknown Pax Choice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CardSurfaces.title(context),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================================
            // EVENT DATE
            // ==========================================================
            _BookingDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Event Date',
              value: live.eventDate?.toString().split(' ')[0] ?? 'N/A',
            ),

            const SizedBox(height: 11),

            // ==========================================================
            // VENUE
            // ==========================================================
            _BookingDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Venue',
              value: live.venueAddress ?? 'N/A',
            ),

            const SizedBox(height: 11),

            // ==========================================================
            // PAX
            // ==========================================================
            _BookingDetailRow(
              icon: Icons.people_outline,
              label: 'PAX',
              value: live.pax == null
                  ? 'N/A'
                  : live.pax == 1
                  ? '1 PAX'
                  : '${live.pax} PAX',
            ),

            const SizedBox(height: 18),

            // ==========================================================
            // PRICE
            // ==========================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),

              decoration: BoxDecoration(
                color: CardSurfaces.chipBg(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CardSurfaces.cardBorder(context)),
              ),

              child: Row(
                children: [
                  Text(
                    'Pax Choice Price',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CardSurfaces.body(context),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // C25: price takes remaining width and ellipsizes
                  // instead of overflowing the row at 360px.
                  Expanded(
                    child: Text(
                      live.package != null
                          ? formatPeso(
                              live.package!.priceForPax(live.pax),
                            )
                          : 'N/A',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CardSurfaces.title(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // C146: persistent `Rate experience` action for Completed
            // Bookings without submitted feedback (opens the same form).
            _RateExperienceButton(booking: live),
          ],
        ),
      ),
      ),
    );
  }
}

// ============================================================================
// RATE EXPERIENCE ACTION (C146)
// ============================================================================

/// Persistent `Rate experience` action for Completed Bookings without
/// submitted feedback. Hidden for any other Status, for future-dated events,
/// and once feedback is submitted.
class _RateExperienceButton extends ConsumerWidget {
  final Booking booking;

  const _RateExperienceButton({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild when feedback state changes (submit / dismiss anywhere).
    ref.watch(feedbackRefreshProvider);
    if (!isCompletedStatus(booking.status) ||
        !isEventPast(booking.eventDate) ||
        booking.id == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<Set<int>>(
      future: FeedbackStore.submittedIds(),
      builder: (context, snapshot) {
        if (snapshot.data?.contains(booking.id) ?? false) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: Key('rate_experience_${booking.id}'),
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text('Rate experience'),
              onPressed: () async {
                await showFeedbackDialog(context, booking.id);
                ref.read(feedbackRefreshProvider.notifier).state++;
              },
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// BOOKING DETAIL ROW
// ============================================================================

class _BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: CardSurfaces.chipBg(context),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, size: 17, color: CardSurfaces.title(context)),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: CardSurfaces.body(context),
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CardSurfaces.title(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    // C68: chip appear on mount (fade + scale, layout-stable).
    return ChipAppear(
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

      decoration: BoxDecoration(
        // C55: bolder fill + border so the semantic chip reads at 9px.
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,

            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),

          const SizedBox(width: 5),

          Text(
            status.toUpperCase(),
            // C115: theme ramp (explicit Figtree).
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: color,
                ),
          ),
        ],
      ),
      ),
    );
  }
}

// ============================================================================
// EMPTY BOOKINGS
// ============================================================================

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: CardSurfaces.chipBg(context),
                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: MyBookingsScreen.primaryColor.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Icon(
                Icons.calendar_month_outlined,
                size: 42,
                // C36: title token (was 0xFF8B6B7C, fails 4.5).
                color: CardSurfaces.title(context),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'No bookings yet',
              // C115: theme ramp (explicit Figtree).
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CardSurfaces.title(context),
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your perfume experiences and upcoming '
              'events will appear here.',
              textAlign: TextAlign.center,
              // C115: theme ramp (explicit Figtree).
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: CardSurfaces.body(context),
                  ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: () {
                context.go('/packages');
              },
              // P7: theme ElevatedButton drives both modes.
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                elevation: 0,
              ),
              child: Text(
                'Explore Pax Choices',
                // C115: theme ramp (explicit Figtree).
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NOTE (P6 Q6/Q8): the bespoke _ErrorBookings was retired; call sites use
// the shared ErrorStateCard from widgets/index.dart (friendly copy, dark-
// aware, raw errors never rendered).

// ============================================================================
// STATUS COLOR
// ============================================================================

// C55: status chips resolve through AppTheme semantic tokens
// (success/pending/errorOnLight/secondary) — never bespoke hex.
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'confirmed':
    case 'paid':
      return AppTheme.success;

    case 'pending':
      return AppTheme.pending;

    case 'cancelled':
    case 'canceled':
    case 'expired':
      return AppTheme.errorOnLight;

    default:
      return AppTheme.secondary;
  }
}
