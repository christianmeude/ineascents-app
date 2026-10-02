import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/offering.dart';
import '../config/scents.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/peso.dart';
import '../widgets/index.dart';

/// C144: Pax Choice detail — pre-booking-flow picker reached from the
/// packages Pax Choice rows (`/packages/:id?pax=&date=`).
///
/// Shows the Pax Choice header (name/desc/price/rating), Inclusions +
/// Freebies (static [Offering] copy), the grouped Scent shelf (Women 4 /
/// Men 4, `n/4` counter, max 4), and `Book with these Scents` → the
/// booking flow with pax + scent_ids prefilled via [bookingFlowProvider].
class PackageDetailScreen extends ConsumerStatefulWidget {
  final int packageId;

  /// Headcount carried from the Pax Choice row (`?pax=`).
  final int? initialPax;

  /// Date carried from the calendar (`?date=`); forwarded to booking.
  final DateTime? initialDate;

  const PackageDetailScreen({
    super.key,
    required this.packageId,
    this.initialPax,
    this.initialDate,
  });

  @override
  ConsumerState<PackageDetailScreen> createState() =>
      _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(bookingFlowProvider.notifier);
      notifier.ensureFreshForPackage(widget.packageId);
      final package = ref.read(packageDetailsProvider(widget.packageId)).value;
      if (package == null) return;
      final candidates = package.options.isNotEmpty
          ? package.options.map((t) => t.pax).toList()
          : (package.paxOptions ?? const <int>[]);
      if (candidates.isEmpty) return;
      final flow = ref.read(bookingFlowProvider);
      final prevPax = flow.selectedPax;
      final preselected = widget.initialPax;
      final chosen =
          (preselected != null && candidates.contains(preselected))
          ? preselected
          : (prevPax != null && candidates.contains(prevPax)
                ? prevPax
                : candidates.first);
      notifier.setSelectedPackage(package);
      notifier.setSelectedPax(chosen);
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/packages');
    }
  }

  void _book(BuildContext context, int pax) {
    final notifier = ref.read(bookingFlowProvider.notifier);
    notifier.setSelectedPax(pax);
    final query = <String>[
      'pax=$pax',
      if (widget.initialDate != null)
        'date=${formatDateParam(widget.initialDate!)}',
    ];
    context.push('/booking/${widget.packageId}?${query.join('&')}');
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageDetailsProvider(widget.packageId));
    final selectedScentIds = ref.watch(
      bookingFlowProvider.select((flow) => flow.selectedScentIds),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: MobileClampScroll.physicsOf(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveAppShell.maxContentWidth,
              ),
              child: Padding(
                padding: ResponsiveAppShell.screenHeaderPadding,
                child: packageAsync.when(
                  data: (package) =>
                      _buildContent(context, package, selectedScentIds),
                  loading: () => const Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: SkeletonPackagesLoading(),
                  ),
                  error: (e, s) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ErrorStateCard(
                        title: "We couldn't open this Pax Choice",
                        message:
                            'Check your connection and try again. '
                            'Nothing has been charged.',
                        onRetry: () => ref.refresh(
                          packageDetailsProvider(widget.packageId),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Package package,
    List<int> selectedScentIds,
  ) {
    final candidates = package.options.isNotEmpty
        ? package.options.map((t) => t.pax).toList()
        : (package.paxOptions ?? const <int>[]);
    final flowPax = ref.read(bookingFlowProvider).selectedPax;
    final pax = (flowPax != null && candidates.contains(flowPax))
        ? flowPax
        : (widget.initialPax != null && candidates.contains(widget.initialPax)
              ? widget.initialPax!
              : (candidates.isNotEmpty ? candidates.first : 50));
    final price = package.priceForPax(pax);
    final titleColor = CardSurfaces.title(context);
    final bodyColor = CardSurfaces.body(context);
    final groups = groupScentChoices(package.scents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // C167: router-aware back to the packages list.
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('detail_back'),
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Packages'),
          ),
        ),
        const SizedBox(height: 8),
        // Pax Choice header.
        Container(
          key: const Key('detail_pax_header'),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CardSurfaces.cardBg(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CardSurfaces.cardBorder(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$pax Pax Choice',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((package.name ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  package.name!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: bodyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if ((package.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  package.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: bodyColor),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    formatPeso(price),
                    key: const Key('detail_pax_price'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  if (package.rating != null && package.rating! > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${package.rating}',
                          style: TextStyle(fontSize: 13, color: titleColor),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${package.reviewsCount ?? 0} reviews)',
                          style: TextStyle(fontSize: 13, color: bodyColor),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Inclusions + Freebies (static Offering copy).
        _StaticListCard(title: 'Inclusions', items: Offering.inclusions),
        const SizedBox(height: 12),
        _StaticListCard(title: 'Freebies', items: Offering.freebies),
        const SizedBox(height: 16),

        // Scent shelf.
        ScentShelf(
          key: const Key('detail_scent_shelf'),
          groups: groups,
          selectedIds: selectedScentIds,
          onToggle: (id) =>
              ref.read(bookingFlowProvider.notifier).toggleScent(id),
        ),
        const SizedBox(height: 20),

        // CTA → booking flow (pax + scent_ids already in the flow).
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: const Key('detail_book_cta'),
            onPressed: () => _book(context, pax),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: const Text(
              'Book with these Scents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// C144: static Inclusions/Freebies card. Labels render with `Scent`
/// (never `Perfume`) per the glossary.
class _StaticListCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _StaticListCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final titleColor = CardSurfaces.title(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CardSurfaces.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '• ${item.replaceAll('Perfume', 'Scent')}',
                style: TextStyle(fontSize: 13, color: titleColor, height: 1.35),
              ),
            ),
        ],
      ),
    );
  }
}
