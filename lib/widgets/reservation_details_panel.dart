import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/index.dart';
import '../utils/peso.dart';
import 'card_surfaces.dart';

/// Middle Column / Panel for INEA Scents reservation flow on tablet.
/// Handles Package variation overview and Time slot selection. Payment
/// Method is picked once at the payment step (C18 pay-once); this panel
/// carries no picker. C92: Pax UI retired (the headcount step is chosen
/// on the packages grid and echoed by the summary rail) — [selectedPax]
/// and [onChangePax] stay as ignored compatibility params.
/// Included-info lives in the booking summary's InclusionsList (C7).
// C6: Reservation* class name kept per ADR 0008 (zero-ripple rule);
// customer-facing copy uses Booking / Pax Choice.
class ReservationDetailsPanel extends StatelessWidget {
  final Package package;
  final int? selectedPax;

  /// C76: locked Pax display — RETIRED (C92: the rail owns the
  /// headcount echo). Kept as an ignored compatibility param so
  /// tablet/mobile call sites and direct-panel usages keep compiling.
  final VoidCallback? onChangePax;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;

  /// C48: schedule-step grid shows time + pax only (COL B) — the §1
  /// package summary card duplicates the summary rail's proper-noun line
  /// and stays retired from the schedule step. Defaults true so existing
  /// direct-panel usages (and their tests) render unchanged.
  final bool showPackageSummary;

  const ReservationDetailsPanel({
    super.key,
    required this.package,
    required this.selectedPax,
    required this.onChangePax,
    required this.selectedTime,
    required this.onTimeSelected,
    this.showPackageSummary = true,
  });

  @override
  Widget build(BuildContext context) {
    // P7: all surfaces resolve through the shared helper so the dark
    // toggle recolors every card, chip, and label.
    final surfaceBorder = CardSurfaces.cardBorder(context);
    final titleColor = CardSurfaces.title(context);
    final bodyColor = CardSurfaces.body(context);
    final chipColor = CardSurfaces.chipBg(context);
    final options = package.options;
    final paxList = options.isNotEmpty
        ? options.map((t) => t.pax).toList()
        : (package.paxOptions ?? const <int>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // 1. PACKAGE SUMMARY CARD (C48: retired from the schedule
        // step — hidden via [showPackageSummary]; the rail owns the
        // proper-noun line there).
        // ========================================================
        if (showPackageSummary) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        color: titleColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name ?? 'Luxury Experience Pax Choice',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Starting at ${formatPeso(package.price ?? 4500.0)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: bodyColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Package facts (grill critique #7): headcount range
                          // + duration hint give the middle column weight.
                          // Staff lives in the booking summary Inclusions;
                          // no invented data.
                          if (paxList.isNotEmpty)
                            Text(
                              paxList.length > 1
                                  ? '${paxList.first}–${paxList.last} PAX — 3–4 hrs'
                                  : '${paxList.first} PAX — 3–4 hrs',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                // C36: title token (was DE-plum, fails 7:1).
                                color: titleColor,
                                height: 1.35,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Description lives on the package detail screen only
                // (grill Q3-final): no server-copy price echo here.
                // C7: included-info lives only in the booking summary
                // (OrderSummaryPanel InclusionsList) — no duplicate accordion.
              ],
            ),
          ),

          const SizedBox(height: 14),
        ],

        // ========================================================
        // 2. SELECT TIME SLOT
        // ========================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: titleColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Choose Event Time',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'One booking lasts 3–4 hrs.',
                style: TextStyle(fontSize: 12, color: bodyColor),
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('event_time_picker_button'),
                onTap: () async {
                  TimeOfDay initial = const TimeOfDay(hour: 14, minute: 0);
                  final current = TimeSlot.toEventTime(selectedTime);
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
                  if (picked == null) return;
                  onTimeSelected(
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                mouseCursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: titleColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedTime == null
                              ? 'Select time'
                              : TimeSlot.display(selectedTime),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: bodyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
