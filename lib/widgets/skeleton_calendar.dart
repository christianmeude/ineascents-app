import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'responsive_app_shell.dart';

/// C58: calendar loading skeleton — mirrors the Availability card +
/// agenda column so loading never flashes a spinner or stale chrome.
/// C83: teases the real layout — radius24 calendarCard (pads 12,14,12,14)
/// with month-nav chrome + weekday header + month grid, desktop 7:4
/// calendar|agenda Row, agenda teasing the text-only empty state.
/// C85: grid mirrors TableCalendar (Monday-start, outsideDaysVisible false)
/// — leading blanks for the real month; agenda teases the empty state
/// (no pill CTA — real empty state is text-only, CTA needs a date).
/// C84: single parent Shimmer — children are plain Containers.
class SkeletonCalendar extends StatelessWidget {
  const SkeletonCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? const Color(0xFF36222C)
        : const Color(0xFF99868C);
    final highlight = isDark
        ? const Color(0xFF5A4450)
        : const Color(0xFFE8DEE2);

    Widget bar({
      required double height,
      required double width,
      double radius = 6,
    }) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    // C122: 42px cells + 10px gaps = 52px pitch, matching TableCalendar
    // rowHeight — and fitting the 296px card interior at 360px screens
    // (was 36+10=46, drifting 6px per row).
    Widget dayCell(int day) {
      return Container(
        key: Key('skeleton_day_cell_$day'),
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    // C85: empty leading cell — mirrors TableCalendar blank slots
    // (outsideDaysVisible false, Monday-start) before day 1.
    Widget leadingCell(int slot) {
      return SizedBox(
        key: Key('skeleton_leading_cell_$slot'),
        width: 42,
        height: 42,
      );
    }

    Widget navButton() {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    Widget weekdayLabel() {
      return Container(
        height: 10,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      );
    }

    Widget calendarCard() {
      // C85: leading blanks for the real month (Monday-start, matching
      // TableCalendar default; outside days hidden).
      final now = DateTime.now();
      final leading =
          DateTime(now.year, now.month, 1).weekday - DateTime.monday;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final totalCells = leading + daysInMonth;
      final paddedCells = ((totalCells + 6) ~/ 7) * 7;
      final cells = <Widget>[
        for (int s = 0; s < leading; s++) leadingCell(s),
        for (int d = 1; d <= daysInMonth; d++) dayCell(d),
        for (int t = totalCells; t < paddedCells; t++)
          const SizedBox(width: 42, height: 42),
      ];
      final rowCount = paddedCells ~/ 7;
      return Container(
        key: const Key('skeleton_calendar_card'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFF36222C)
                : const Color(0x4D99868C),
          ),
        ),
        child: Column(
          children: [
            // Month-nav chrome mirror: back / title-bar / forward.
            Row(
              key: const Key('skeleton_month_nav'),
              children: [
                navButton(),
                Expanded(
                  child: Center(child: bar(height: 14, width: 140, radius: 7)),
                ),
                navButton(),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday header mirror: 7 labels in a 22px row, matching
            // TableCalendar daysOfWeekHeight.
            SizedBox(
              height: 22,
              child: Center(
                child: Row(
                  key: const Key('skeleton_weekday_header'),
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [for (int i = 0; i < 7; i++) weekdayLabel()],
                ),
              ),
            ),
            const SizedBox(height: 6),
            for (int row = 0; row < rowCount; row++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: cells.sublist(row * 7, row * 7 + 7),
              ),
              if (row < rowCount - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      );
    }

    // C85: empty-state tease — real empty agenda is text-only
    // ('Select a date to see details.'); no pill CTA without a date.
    // C122: two bars — the real line wraps to two at mobile widths.
    Widget agendaColumn() {
      return Column(
        key: const Key('skeleton_agenda'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(height: 12, width: 220),
          const SizedBox(height: 6),
          bar(height: 12, width: 160),
        ],
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        key: const Key('skeleton_calendar'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >=
                  ResponsiveAppShell.tabletBreakpoint;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: calendarCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: agendaColumn()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  calendarCard(),
                  const SizedBox(height: 20),
                  agendaColumn(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
