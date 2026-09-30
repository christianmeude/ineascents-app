import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/index.dart';
import '../providers/index.dart';
import 'card_surfaces.dart';
import 'skeleton_shimmer.dart';

/// C11: picks the nearest upcoming Booking from a list.
///
/// Upcoming = Status `pending`/`confirmed` (case-insensitive) with a
/// non-null `eventDate` whose device-local date is today or later.
/// Cancelled, unknown-Status, and null-date Bookings never count; the
/// Time Slot is informational and never affects the pick. Ties on the
/// same day resolve Confirmed-first, then lowest `id`.
Booking? selectUpcomingBooking(List<Booking> bookings, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);

  Booking? best;
  for (final booking in bookings) {
    final status = (booking.status ?? '').toLowerCase();
    if (status != 'pending' && status != 'confirmed') continue;
    final eventDate = booking.eventDate;
    if (eventDate == null) continue;
    final day = DateTime(eventDate.year, eventDate.month, eventDate.day);
    if (day.isBefore(today)) continue;

    if (best == null) {
      best = booking;
      continue;
    }
    final bestDate = best.eventDate!;
    final bestDay = DateTime(bestDate.year, bestDate.month, bestDate.day);
    if (day.isBefore(bestDay)) {
      best = booking;
    } else if (day.isAtSameMomentAs(bestDay)) {
      final bestStatus = (best.status ?? '').toLowerCase();
      if (bestStatus == 'pending' && status == 'confirmed') {
        best = booking;
      } else if (status == bestStatus) {
        const missing = 1 << 30;
        if ((booking.id ?? missing) < (best.id ?? missing)) {
          best = booking;
        }
      }
    }
  }
  return best;
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return const Color(0xFF648B70);
    case 'pending':
      return const Color(0xFFC28A52);
    case 'cancelled':
      return const Color(0xFF9A607B);
    default:
      return const Color(0xFF8B7B84);
  }
}

/// C11: Profile "Upcoming Booking" section. Compact by design — the
/// Profile screen fits 360x800 with no scroll (C9), so every state
/// (loading/error/empty/data) stays under ~200px tall.
class UpcomingBookingSection extends ConsumerWidget {
  const UpcomingBookingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    return bookingsAsync.when(
      data: (bookings) {
        final upcoming = selectUpcomingBooking(bookings);
        if (upcoming == null) return const _EmptyUpcoming();
        return _UpcomingCard(booking: upcoming);
      },
      loading: () => const _LoadingUpcoming(),
      error: (error, _) =>
          _ErrorUpcoming(onRetry: () => ref.invalidate(bookingsProvider)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CardSurfaces.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: CardSurfaces.plum.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final Booking booking;

  const _UpcomingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status ?? 'pending';
    final color = _statusColor(status);
    final date = booking.eventDate?.toString().split(' ')[0] ?? 'N/A';
    final time = (booking.eventTime ?? '').isEmpty ? null : booking.eventTime;
    final pax = booking.pax == null
        ? 'N/A'
        : booking.pax == 1
        ? '1 Pax'
        : '${booking.pax} Pax';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'UPCOMING BOOKING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: CardSurfaces.body(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.package?.name ?? 'Pax Choice booking',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CardSurfaces.title(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time == null ? date : '$date · $time',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: CardSurfaces.body(context)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 15,
                color: CardSurfaces.body(context),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  pax,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CardSurfaces.title(context),
                  ),
                ),
              ),
              if (booking.id != null)
                TextButton(
                  onPressed: () => context.push('/bookings/${booking.id}'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CardSurfaces.chipBg(context),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: CardSurfaces.title(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No upcoming Booking yet',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CardSurfaces.title(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your next event will appear here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CardSurfaces.body(context),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/packages'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Explore',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingUpcoming extends StatelessWidget {
  const _LoadingUpcoming();

  @override
  Widget build(BuildContext context) {
    // C126: single parent SkeletonShimmer (was per-bar Shimmer with
    // divergent tokens) — uniform muted tone, never flashes white.
    Widget bar(double height, double width) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return SkeletonShimmer(
      child: _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(11, 130),
            const SizedBox(height: 10),
            bar(16, double.infinity),
            const SizedBox(height: 8),
            bar(12, 170),
          ],
        ),
      ),
    );
  }
}

class _ErrorUpcoming extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorUpcoming({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: CardSurfaces.body(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "We couldn't load your upcoming Booking.",
              style: TextStyle(fontSize: 12, color: CardSurfaces.body(context)),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
