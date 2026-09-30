import 'package:flutter/material.dart';

import 'responsive_app_shell.dart';
import 'skeleton_shimmer.dart';

/// C79: booking-flow loading skeleton — teases the booking schedule step
/// (locked Pax header + calendar card + time/pax rows + event summary +
/// summary rail) so package loading never flashes a spinner.
///
/// Calendar mirrors [SkeletonCalendar] (month-nav chrome + weekday row +
/// 5x7 36px circles), simplified; details block mirrors
/// [ReservationDetailsPanel] §§2–3 (pax pill + time picker); event summary
/// mirrors the schedule recap rows (Date/Time/Venue/Contact); right rail
/// teases the order-summary block (5 rows + CTA bar). Viewports >=768
/// render a Row with the rail (tablet + desktop); narrower stack.
/// C84: single parent Shimmer — children are plain Containers.
class SkeletonBookingFlow extends StatelessWidget {
  const SkeletonBookingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // C126: tone resolves through SkeletonShimmer (uniform + muted).
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    Widget circle(double size) {
      return Container(
        width: size,
        height: size,
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF36222C) : const Color(0x4D99868C),
          ),
        ),
        child: Column(
          children: [
            // Month-nav bar: back / title / forward.
            Row(
              key: const Key('skeleton_flow_month_nav'),
              children: [
                circle(28),
                Expanded(
                  child: Center(child: bar(height: 14, width: 140, radius: 7)),
                ),
                circle(28),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday header: 7 labels.
            Row(
              key: const Key('skeleton_flow_weekday_header'),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [for (int i = 0; i < 7; i++) weekdayLabel()],
            ),
            const SizedBox(height: 6),
            for (int row = 0; row < 5; row++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [for (int i = 0; i < 7; i++) circle(36)],
              ),
              if (row < 4) const SizedBox(height: 10),
            ],
          ],
        ),
      );
    }

    Widget detailsBlock() {
      return Container(
        key: const Key('skeleton_flow_details'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? const Color(0xFF36222C) : const Color(0x4D99868C),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pax pill row (§2 readonly row).
            Container(
              height: 38,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            const SizedBox(height: 14),
            // Time picker header (§3 title + caption + picker button).
            Row(
              children: [
                circle(36),
                const SizedBox(width: 10),
                bar(height: 15, width: 140, radius: 6),
              ],
            ),
            const SizedBox(height: 8),
            bar(height: 12, width: 150, radius: 6),
            const SizedBox(height: 12),
            Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      );
    }

    Widget eventSummaryBlock() {
      return Container(
        key: const Key('skeleton_flow_event_summary'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? const Color(0xFF36222C) : const Color(0x4D99868C),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(height: 14, width: 110, radius: 6),
            const SizedBox(height: 12),
            for (int i = 0; i < 4; i++) ...[
              Row(
                children: [
                  bar(height: 12, width: 72, radius: 6),
                  const SizedBox(width: 12),
                  Expanded(
                    child: bar(height: 13, width: double.infinity, radius: 6),
                  ),
                ],
              ),
              if (i < 3) const SizedBox(height: 10),
            ],
          ],
        ),
      );
    }

    Widget summaryRail() {
      return Container(
        key: const Key('skeleton_flow_summary'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? const Color(0xFF36222C) : const Color(0x4D99868C),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(height: 16, width: 140, radius: 6),
            const SizedBox(height: 12),
            for (int i = 0; i < 5; i++) ...[
              Row(
                children: [
                  bar(height: 12, width: 72, radius: 6),
                  const SizedBox(width: 12),
                  Expanded(
                    child: bar(height: 13, width: double.infinity, radius: 6),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            // CTA bar.
            Container(
              key: const Key('skeleton_flow_cta'),
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ],
        ),
      );
    }

    return SkeletonShimmer(
      child: Column(
        key: const Key('skeleton_booking_flow'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pax header bar.
          Container(
            key: const Key('skeleton_flow_pax_header'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1618) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF36222C)
                    : const Color(0x4D99868C),
              ),
            ),
            child: Row(
              children: [
                circle(20),
                const SizedBox(width: 10),
                Expanded(
                  child: bar(height: 18, width: double.infinity, radius: 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack =
                  constraints.maxWidth < ResponsiveAppShell.mobileBreakpoint;
              if (!stack) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          calendarCard(),
                          const SizedBox(height: 16),
                          detailsBlock(),
                          const SizedBox(height: 16),
                          eventSummaryBlock(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: summaryRail()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  calendarCard(),
                  const SizedBox(height: 16),
                  detailsBlock(),
                  const SizedBox(height: 16),
                  eventSummaryBlock(),
                  const SizedBox(height: 16),
                  summaryRail(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
