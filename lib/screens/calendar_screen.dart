import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../providers/index.dart';
import '../widgets/index.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime? _selectedDay;

  // ============================================================
  // INEA COLORS
  // ============================================================

  static const Color primary = AppTheme.primary;

  // C4: no dot indicators — day cells render without markers.

  @override
  Widget build(BuildContext context) {
    final availabilityAsync = ref.watch(availabilityProvider);

    // P7: no explicit color — flat theme scaffold background.
    return Scaffold(
      // C22: distilled — mobile AppBar removed (brand title + refresh
      // button). Pull-to-refresh stays the refresh path; desktop
      // TopNavBar covers nav.
      appBar: null,

      // ========================================================
      // BODY
      // ========================================================
      // P7: flat theme background; decorative gradient removed.
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // C66: initial load only — reloads keep stale content
            // (no skeleton flash) until fresh data lands.
            final isInitialLoading =
                availabilityAsync.isLoading && !availabilityAsync.hasValue;
            final content = availabilityAsync.when(
              skipLoadingOnReload: true,

              loading: () {
                return const SizedBox.shrink();
              },

              // P6 (Q6/Q8): shared friendly card; raw errors stay
              // in logs, never on screen.
              error: (error, _) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ErrorStateCard(
                      title: 'Unable to load availability',
                      message:
                          "We couldn't load the calendar. "
                          'Check your connection and try again.',
                      onRetry: () {
                        ref.read(availabilityProvider.notifier).refresh();
                      },
                    ),
                  ),
                );
              },

              data: (availabilityState) {
                return _buildCalendar(availabilityState);
              },
            );
            // C66: skeleton→content crossfade (fade, no pop-in).
            // Header stays mounted in both branches so only the
            // shimmer/content swaps.
            return SkeletonCrossfade(
              isLoading: isInitialLoading,
              skeleton: ListView(
                padding: ResponsiveAppShell.screenHeaderPadding,
                children: const [
                  TabHeader(
                    title: 'Availability',
                    count: 'Choose a date for your scent experience.',
                  ),
                  // C60: Q9 retired.
                  SizedBox(height: 22),
                  SkeletonCalendar(),
                ],
              ),
              child: content,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CALENDAR CONTENT
  // ============================================================

  Widget _buildCalendar(AvailabilityState availabilityState) {
    // P7: content chrome resolves through the shared helper.
    final surface = CardSurfaces.cardBg(context);
    final surfaceBorder = CardSurfaces.cardBorder(context);
    final titleColor = CardSurfaces.title(context);
    final availability = availabilityState.data;

    // C28: date-entry grid is the shared IneaCalendar; only days the
    // backend marks available are enabled (past days never are).
    final enabledDays = <DateTime>{
      for (final item in availability)
        if (item.date != null && _isAvailable(item.status ?? ''))
          _dayOnly(item.date!),
    };

    final dates = <DateTime, String>{
      for (final item in availability)
        if (item.date != null) _dayOnly(item.date!): item.status ?? 'available',
    };

    final selectedStatus = _selectedDay == null
        ? null
        : dates[_dayOnly(_selectedDay!)];

    return RefreshIndicator(
      color: titleColor,
      onRefresh: () async {
        ref.read(availabilityProvider.notifier).refresh();
      },

      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop =
              constraints.maxWidth >= ResponsiveAppShell.tabletBreakpoint;

          // C42: unified header (title+count left, trailing empty).
          const titleContent = TabHeader(
            title: 'Availability',
            count: 'Choose a date for your scent experience.',
          );

          final calendarCard = // ====================================================
              // CALENDAR CARD
              // ====================================================
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: surfaceBorder, width: 1),

                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),

                  // C28: date-entry grid is the shared IneaCalendar
                  // (bare mode — this card owns the chrome). Paging
                  // keeps the selection; only the month refetches.
                  child: IneaCalendar(
                    showChrome: false,
                    selectedDate: _selectedDay,
                    enabledDays: enabledDays,
                    onDateSelected: (selectedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    },
                  ),
                ),
              );

          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                // C42: header aligns to the 1200 shell cap (was 1000).
                constraints: const BoxConstraints(
                  maxWidth: ResponsiveAppShell.maxContentWidth,
                ),
                child: ListView(
                  // C40: desktop surface — platform default untouched.
                  padding: ResponsiveAppShell.screenHeaderPadding,
                  children: [
                    titleContent,
                    // C60: Q9 retired.
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: calendarCard),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: _buildAgendaColumn(
                            selectedStatus,
                            isDesktop: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            // C40: clamp overscroll on mobile (<768px); SDK default
            // (stretch Android / bounce iOS) displaced content past edge.
            // Desktop/web physics untouched (null = platform default).
            physics: MobileClampScroll.physicsForWidth(constraints.maxWidth),
            padding: ResponsiveAppShell.screenHeaderPadding,
            children: [
              titleContent,
              // C60: Q9 retired.
              const SizedBox(height: 22),
              calendarCard,
              const SizedBox(height: 20),
              _buildAgendaColumn(selectedStatus, isDesktop: false),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  /// Selected-date agenda + continue action. Stacked on
  /// mobile, calendar | agenda side-by-side on web. C28.
  Widget _buildAgendaColumn(String? selectedStatus, {bool isDesktop = false}) {
    final titleColor = CardSurfaces.title(context);
    final bodyColor = CardSurfaces.body(context);
    final selection = Column(
      key: const Key('calendar_agenda'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====================================================
        // SELECTED DATE
        // ====================================================
        if (_selectedDay != null) ...[
          Text(
            _formatDate(_selectedDay!),
            // C117: theme ramp (explicit Figtree).
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedStatus == null || _isAvailable(selectedStatus)
                ? 'Available for your event'
                : 'Unavailable — pick another date',
            // C117: theme ramp (explicit Figtree).
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: bodyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              key: const Key('calendar_continue_cta'),
              onPressed: () {
                final d = _selectedDay!;
                final dateStr =
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                // C53: the draft date lives in the flow AND the query, so
                // the reroute retains it. `go` (not `push`) switches to the
                // Packages branch, keeping the tab selection in sync.
                ref.read(bookingFlowProvider.notifier).setSelectedDate(d);
                context.go('/packages?date=$dateStr');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text('Continue with ${_formatDate(_selectedDay!)}'),
              // P7: theme ElevatedButton drives both modes.
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ] else ...[
          // C28: agenda empty state — keeps the panel present.
          Text(
            'Select a date to see details.',
            // C117: theme ramp (explicit Figtree).
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: bodyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ],
    );

    // P7 impeccable adapt: stacked on mobile, legend | selection
    // side-by-side on web.
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [selection],
      );
    }
    return selection;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isAvailable(String status) {
    return status.toLowerCase() == 'available';
  }

  DateTime _dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }
}

// NOTE (P6 Q6/Q8): the bespoke _CalendarError was retired; call sites use
// the shared ErrorStateCard from widgets/index.dart (friendly copy, dark-
// aware, raw errors never rendered).
// NOTE (C28): the bespoke _CalendarDay grid was retired; both calendar
// grids render through the shared IneaCalendar widget.
