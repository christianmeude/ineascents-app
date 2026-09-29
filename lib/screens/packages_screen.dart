import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/index.dart';
import '../widgets/index.dart';
import '../models/index.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  /// Date carried from the calendar (`?date=`); forwarded with each card.
  final DateTime? initialDate;

  const PackagesScreen({super.key, this.initialDate});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

/// C17: one Offering renders one hero plus one row per Pax Choice.
/// Packages without an option map fall back to a single row at the
/// scalar price so the list never renders empty.

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(packagesProvider);

    // ============================================================
    // COLORS (P7: flat theme background + dark-aware text)
    // ============================================================

    final textColor = CardSurfaces.title(context);

    // P7: no explicit color — the theme scaffold color (light cream /
    // dark night) is the background.
    return Scaffold(
      // C22: distilled — mobile AppBar removed (brand title + dead tune
      // filter). Desktop TopNavBar covers nav; body carries the title.
      appBar: null,

      // ============================================================
      // BODY (P7: flat theme background; decorative gradient removed)
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          // C40: clamp overscroll on mobile (<768px); SDK default
          // (stretch Android / bounce iOS) displaced content past edge.
          // Desktop/web physics untouched (null = platform default).
          physics: MobileClampScroll.physicsOf(context),

          // C81: padding lives INSIDE the 1200 cap (was on the scroll
          // view outside Center/ConstrainedBox). Mirrors bookings.
          child: Center(
            child: ConstrainedBox(
              // C72: shared max-width token (was hardcoded 1200).
              constraints: const BoxConstraints(
                maxWidth: ResponsiveAppShell.maxContentWidth,
              ),
              child: Padding(
                // C72: shared header token (was hardcoded fromLTRB(20, 18, 20, 30)).
                padding: ResponsiveAppShell.screenHeaderPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PAGE TITLE (C42: unified header, trailing empty)
                    // ==================================================
                    const TabHeader(
                      title: 'Our Collections',
                      count: 'Discover your perfect scent.',
                    ),

                    const SizedBox(height: 20),

                    // C60: Q9 retired — reopening a draft routes to the flow
                    // itself at its stored stage.

                    // C53: the calendar reroute retains the draft date — say
                    // so, and forward it with every Pax Choice row below.
                    if (widget.initialDate != null) ...[
                      _CarriedDateBanner(date: widget.initialDate!),
                      const SizedBox(height: 12),
                    ],

                    // ==================================================
                    // C17: single Offering hero + Pax Choice rows
                    // C66: skeleton→content crossfade (fade, no pop-in)
                    // ==================================================
                    Builder(
                      builder: (context) {
                        // Initial load only: reloads keep stale content
                        // (no skeleton flash) until fresh data lands.
                        final isInitialLoading =
                            packagesAsync.isLoading && !packagesAsync.hasValue;
                        final content = packagesAsync.when(
                          data: (packages) {
                            if (packages.isEmpty) {
                              return _EmptyPackages();
                            }

                            final offering = packages.first;
                            final opts = offering.options;
                            final choices = opts.isEmpty
                                ? [
                                    PackageOption(
                                      offering.paxOptions?.firstOrNull ?? 50,
                                      offering.priceForPax(null),
                                    ),
                                  ]
                                : opts;

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // C21: compact hero (200 mobile / 240 desktop)
                                // + full Pax Choice list below. Desktop fills
                                // the 1200 cap with a 2-column grid; mobile
                                // stays single-column (360px safe).
                                final wide = constraints.maxWidth >= 768;
                                final rows = <Widget>[
                                  for (final choice in choices) ...[
                                    PaxChoiceRow(
                                      packageId: offering.id,
                                      pax: choice.pax,
                                      price: choice.price,
                                      initialDate: widget.initialDate,
                                    ),
                                  ],
                                ];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PackageOfferingHero(package: offering),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Choose your Pax Choice',
                                      // C113: theme ramp (explicit Figtree).
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: textColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (!wide) ...[
                                      for (int i = 0; i < rows.length; i++) ...[
                                        rows[i],
                                        if (i < rows.length - 1)
                                          const SizedBox(height: 10),
                                      ],
                                    ] else
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                              // Roomy rows: ~76px tall at 1200 cap.
                                              mainAxisExtent: 78,
                                            ),
                                        itemCount: rows.length,
                                        itemBuilder: (context, i) => rows[i],
                                      ),
                                  ],
                                );
                              },
                            );
                          },

                          // ==================================================
                          // LOADING (C66: empty — skeleton lives in the
                          // crossfade wrapper below so the swap animates)
                          // ==================================================
                          loading: () {
                            return const SizedBox.shrink();
                          },

                          // ==================================================
                          // ERROR
                          // ==================================================
                          // P6 (Q6/Q8): shared friendly card; raw errors
                          // stay in logs, never on screen.
                          error: (error, stack) {
                            return ErrorStateCard(
                              title: 'Unable to load Offerings',
                              message:
                                  "We couldn't load the Offerings. "
                                  'Check your connection and try again.',
                              onRetry: () => ref.invalidate(packagesProvider),
                            );
                          },
                        );
                        return SkeletonCrossfade(
                          isLoading: isInitialLoading,
                          skeleton: const SkeletonPackagesLoading(),
                          child: content,
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // BODY WRAPPER END
      // ============================================================
    );
  }
}

// ============================================================================
// C53 CARRIED DATE BANNER
// ============================================================================

/// Confirms the `?date=` the calendar reroute retained. Informational only —
/// every Pax Choice row below forwards it to the single booking route.
class _CarriedDateBanner extends StatelessWidget {
  final DateTime date;

  const _CarriedDateBanner({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('packages_carried_date'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CardSurfaces.chipBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CardSurfaces.cardBorder(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 18,
            color: CardSurfaces.title(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing for ${formatDateParam(date)} — carried from the calendar.',
              // C113: theme ramp (explicit Figtree).
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CardSurfaces.title(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY PACKAGES
// ============================================================================

class _EmptyPackages extends StatelessWidget {
  const _EmptyPackages();

  @override
  Widget build(BuildContext context) {
    // P6 (Q1): solid + dark-aware, like every other state card.
    // C113: single-source surfaces (were inline hex).
    final textColor = CardSurfaces.title(context);
    final secondaryTextColor = CardSurfaces.body(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 25),

      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CardSurfaces.cardBorder(context),
        ),
      ),

      child: Column(
        children: [
          Icon(Icons.local_florist_outlined, size: 42, color: textColor),

          const SizedBox(height: 14),

          SelectableText(
            'No Offerings available',
            textAlign: TextAlign.center,
            // C113: theme ramp (explicit Figtree).
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 6),

          SelectableText(
            'Please check back again later.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: secondaryTextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
