import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/index.dart';
import '../utils/peso.dart';
import 'card_surfaces.dart';

/// Distilled booking side-panel (C75, 2026-09-24):
/// `Your Booking` heading (Booking avoids `order` per CONTEXT.md),
/// exactly five label-value rows (Package, Pax, Date, Time Slot, Total)
/// separated by dividers, a single inclusions count caption, then the CTA.
/// Removed: PAX-tier context line (tiers are a lookup — no `from` math),
/// the `{pax} PAX · {date} · {time}` one-liner, the `· 3–4 hrs` duration
/// suffix (time only), the venue row (venue lives in Details/schedule
/// steps), and the full InclusionsList (a count line preserves the signal
/// without breaking scannability). `₱`-canonical total, amount-in-CTA.
/// [isSticky] caps the panel at viewport height with an internal scroll so
/// the web/tablet rail stays usable while the page scrolls.
// C6: Order* class name kept (referenced across booking_screen and tests);
// customer-facing copy already uses Booking ("Your Booking").
class OrderSummaryPanel extends StatelessWidget {
  // C31: single-sourced via AppTheme (never per-screen hex).
  static const Color plum = AppTheme.primaryButtonBackground;

  // Sticky-rail viewport cap (C75 sweep): reserve for header/footer chrome,
  // clamped so the rail stays usable on short and tall viewports.
  static const double _railViewportReserve = 140.0;
  static const double _railMinHeight = 240.0;
  static const double _railMaxHeight = 720.0;

  final Package package;
  final DateTime? selectedDate;
  final String? selectedTime;
  final int? selectedPax;

  /// C169: chosen Scent ids — an empty selection renders the
  /// Scent-required hint above the CTA (Scents are chosen on the
  /// Package detail; at least 1 is required to proceed).
  final List<int> selectedScentIds;
  final String? paymentMethod;
  final VoidCallback? onProceed;
  final String actionButtonText;
  final bool isLoading;
  final bool isSticky;

  const OrderSummaryPanel({
    super.key,
    required this.package,
    this.selectedDate,
    this.selectedTime,
    this.selectedPax,
    this.selectedScentIds = const [],
    this.paymentMethod,
    this.onProceed,
    this.actionButtonText = 'Confirm & Pay',
    this.isLoading = false,
    this.isSticky = true,
  });

  /// Explicit contract date: `Saturday, September 26, 2026`.
  String _formatFullDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Single label-value row: label left, value right-aligned, wrap kept.
  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Key? valueKey,
    bool strongValue = false,
  }) {
    final titleColor = CardSurfaces.title(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CardSurfaces.body(context),
                height: 1.35,
              ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              key: valueKey,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: strongValue ? FontWeight.w700 : FontWeight.w600,
                color: titleColor,
                height: 1.35,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Divider(
        color: CardSurfaces.cardBorder(context),
        thickness: 1,
        height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = CardSurfaces.cardBg(context);
    final surfaceBorder = CardSurfaces.cardBorder(context);
    final titleColor = CardSurfaces.title(context);
    final effectivePrice = package.priceForPax(selectedPax);

    // Live package data only — no fallback fiction. The full list lives in
    // the Details step; the rail keeps a single count caption.
    final inclusionCount =
        (package.inclusions ?? const <String>[]).length +
        (package.freebies ?? const <String>[]).length;
    final inclusionsCaption = inclusionCount == 0
        ? 'No inclusions listed'
        : '$inclusionCount inclusion${inclusionCount == 1 ? '' : 's'}';

    // Amount-in-CTA (grill Q5): only the default submit text carries it.
    final ctaText = actionButtonText == 'Confirm & Pay'
        ? 'Confirm & Pay ${formatPeso(effectivePrice)}'
        : actionButtonText;

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: plum.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header (no Live chip per C).
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CardSurfaces.chipBg(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: titleColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: 0.2,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Five label-value rows with dividers — no paragraphs.
          _summaryRow(
            context,
            label: 'Package',
            value: package.name ?? 'Perfume Bar',
            valueKey: const Key('summary_value_package'),
          ),
          _rowDivider(context),
          _summaryRow(
            context,
            label: 'Pax',
            value: '${selectedPax ?? 50} PAX',
            valueKey: const Key('summary_value_pax'),
          ),
          _rowDivider(context),
          _summaryRow(
            context,
            label: 'Date',
            value: selectedDate != null
                ? _formatFullDate(selectedDate!)
                : 'Not selected',
            valueKey: const Key('summary_value_date'),
          ),
          _rowDivider(context),
          _summaryRow(
            context,
            label: 'Time Slot',
            value: TimeSlot.display(selectedTime),
            valueKey: const Key('summary_value_time'),
          ),
          _rowDivider(context),
          if (selectedScentIds.isNotEmpty) ...[
            _summaryRow(
              context,
              label: 'Scents',
              value: selectedScentIds.map((id) {
                final matches = package.scents?.where((s) => s.id == id);
                return (matches != null && matches.isNotEmpty) ? matches.first.name : 'Scent $id';
              }).join(', '),
              valueKey: const Key('summary_value_scents'),
            ),
            _rowDivider(context),
          ],
          
          // Collapsed inclusions signal (full list lives in Details).
          Text(
            inclusionsCaption,
            key: const Key('order_summary_inclusions_count'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CardSurfaces.body(context),
              height: 1.3,
            ),
            softWrap: true,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: surfaceBorder, thickness: 1),
          ),

          // Total — `₱` only, wrap-don't-truncate.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  formatPeso(effectivePrice),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // C169: Scent-required hint at the decision point (renders only
          // when empty; the sticky rail scrolls internally, so the fixed
          // desktop Schedule geometry is unaffected).
          if (selectedScentIds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Choose at least 1 Scent on the Package detail to continue your Booking.',
                key: const Key('order_summary_scent_hint'),
                style: TextStyle(
                  fontSize: 12,
                  color: CardSurfaces.body(context),
                  height: 1.35,
                ),
                softWrap: true,
              ),
            ),

          // CTA.
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isLoading ? null : onProceed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        // C31: cream spinner on the plum CTA token.
                        color: AppTheme.onPrimaryButton,
                      ),
                    )
                  : Text(
                      ctaText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    // C75 sticky rail: cap at viewport height with an internal scroll so
    // the summary stays usable while the page scrolls. Non-sticky callers
    // (none in the flow; covered by widget tests) get the bare card.
    if (!isSticky) return card;
    final viewportHeight = MediaQuery.of(context).size.height;
    final cap = (viewportHeight - _railViewportReserve)
        .clamp(_railMinHeight, _railMaxHeight);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: cap),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: card,
      ),
    );
  }
}
