import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/index.dart';
import '../providers/index.dart';
import '../utils/peso.dart';
import '../widgets/index.dart';

/// C11: read-only Booking detail at `/bookings/:id`.
///
/// The pre-existing `/booking/:id` route is the booking wizard (takes a
/// Pax Choice id), so the Upcoming section's View action lands here
/// instead — keyed by the numeric Booking `id`.
class BookingDetailScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: MediaQuery.of(context).size.width < 768
          ? AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/bookings');
                  }
                },
              ),
              title: Text(
                'Booking Details',
                style: TextStyle(
                  color: CardSurfaces.title(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: bookingsAsync.when(
          data: (bookings) {
            Booking? booking;
            for (final candidate in bookings) {
              if (candidate.id == bookingId) {
                booking = candidate;
                break;
              }
            }
            if (booking == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ErrorStateCard(
                    title: 'Booking not found',
                    message:
                        'This Booking is no longer available. '
                        'Check your bookings list for the latest.',
                    retryLabel: 'Back to Bookings',
                    onRetry: () => context.go('/bookings'),
                  ),
                ),
              );
            }
            return _DetailBody(booking: booking);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ErrorStateCard(
                title: 'Unable to load booking',
                message:
                    "We couldn't load this Booking. "
                    'Check your connection and try again.',
                onRetry: () => ref.invalidate(bookingsProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Booking booking;

  const _DetailBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status ?? 'pending';
    return SingleChildScrollView(
      // C40: clamp overscroll on mobile (<768px); SDK default
      // (stretch Android / bounce iOS) displaced content past edge.
      // Desktop/web physics untouched (null = platform default).
      physics: MobileClampScroll.physicsOf(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CardSurfaces.cardBg(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: CardSurfaces.cardBorder(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                              booking.bookingReference ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: CardSurfaces.title(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _DetailStatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    booking.package?.name ?? 'Pax Choice booking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CardSurfaces.title(context),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Event Date',
                    value:
                        booking.eventDate?.toString().split(' ')[0] ??
                        'N/A',
                  ),
                  const SizedBox(height: 11),
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Time Slot',
                    value: (booking.eventTime ?? '').isEmpty
                        ? 'N/A'
                        : booking.eventTime!,
                  ),
                  const SizedBox(height: 11),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Venue',
                    value: booking.venueAddress ?? 'N/A',
                  ),
                  const SizedBox(height: 11),
                  _DetailRow(
                    icon: Icons.people_outline,
                    label: 'Pax',
                    value: booking.pax == null
                        ? 'N/A'
                        : booking.pax == 1
                            ? '1 Pax'
                            : '${booking.pax} Pax',
                  ),
                  const SizedBox(height: 11),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Payment Method',
                    value: booking.paymentMethod ?? 'N/A',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: CardSurfaces.chipBg(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: CardSurfaces.cardBorder(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CardSurfaces.body(context),
                          ),
                        ),
                        Text(
                          booking.package != null
                              ? formatPeso(
                                  booking.package!.priceForPax(booking.pax),
                                )
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CardSurfaces.title(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailStatusChip extends StatelessWidget {
  final String status;

  const _DetailStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'confirmed' => const Color(0xFF648B70),
      'pending' => const Color(0xFFC28A52),
      'cancelled' => const Color(0xFF9A607B),
      _ => const Color(0xFF8B7B84),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        status.toUpperCase(),
        // C116: theme ramp (explicit Figtree).
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
