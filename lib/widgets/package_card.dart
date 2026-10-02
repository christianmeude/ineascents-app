import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/index.dart';
import '../config/theme.dart';
import '../utils/peso.dart';

class PackageCard extends StatefulWidget {
  final Package package;
  final VoidCallback? onTap;

  /// Package-option override: renders this card as one selectable headcount
  /// step ("50 PAX — ₱4,499") instead of the whole package.
  final int? optionPax;

  /// Date carried from the calendar (`?date=`); forwarded with the push.
  final DateTime? initialDate;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.optionPax,
    this.initialDate,
  });

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _isHovered = false;
  bool _isFocused = false;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      final option = widget.optionPax;
      final id = widget.package.id;
      final query = <String>[
        if (option != null) 'pax=$option',
        if (widget.initialDate != null)
          'date=${formatDateParam(widget.initialDate!)}',
      ];
      context.push(
        '/booking/$id${query.isEmpty ? '' : '?${query.join('&')}'}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? (_isHovered ? AppTheme.nightBorder : AppTheme.nightSurface)
        : (_isHovered ? const Color(0xFFFAF2F4) : Colors.white);
    final focusBorderColor = isDark
        ? const Color(0xFFFDF4F5)
        : AppTheme.primary;
    final primaryTextColor = isDark
        ? const Color(0xFFFDF4F5)
        : AppTheme.primary;
    final secondaryTextColor = isDark
        ? const Color(0xFFC4ACAC)
        : AppTheme.secondary;
    final badgeBg = isDark
        ? (_isHovered ? AppTheme.nightBorder : AppTheme.nightSurface)
        : (_isHovered ? const Color(0xFFFAF2F4) : Colors.white);

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (hovered) {
        if (_isHovered != hovered) {
          setState(() => _isHovered = hovered);
        }
      },
      onShowFocusHighlight: (focused) {
        if (_isFocused != focused) {
          setState(() => _isFocused = focused);
        }
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _handleTap(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: _isFocused
                ? Border.all(color: focusBorderColor, width: 2.5)
                : Border.all(
                    color: _isHovered
                        ? AppTheme.primary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    width: 1.5,
                  ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.10)
                    : AppTheme.primary.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 16 : 10,
                offset: _isHovered ? const Offset(0, 6) : const Offset(0, 5),
              ),
              if (_isFocused)
                BoxShadow(
                  color: (isDark ? const Color(0xFFFDF4F5) : AppTheme.primary)
                      .withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: Container(
                        width: double.infinity,
                        color: isDark ? AppTheme.night : AppTheme.neutralBg,
                        child:
                            (package.images != null &&
                                package.images!.isNotEmpty)
                            ? Image.network(
                                package.images![0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // P6 (G6-A): monogram fallback tile keeps
                                  // imageless cards composed instead of void.
                                  return _MonogramTile(
                                    name: package.name,
                                    isDark: isDark,
                                  );
                                },
                              )
                            : _MonogramTile(name: package.name, isDark: isDark),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View Pax Choice',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.optionPax != null
                          ? '${widget.optionPax} PAX'
                          : package.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // C2: zero-rating packages render without the trust row —
                    // check the raw rating before the display fallback.
                    if (package.rating != null && package.rating! > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${package.rating ?? 4.5}',
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '(${package.reviewsCount ?? 232} reviews)',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Description lives on the detail screen only
                    // (grill Q3-final): cards stay dense, no price echo.
                    const SizedBox(height: 12),
                    Text(
                      formatPeso(package.priceForPax(widget.optionPax)),
                      style: TextStyle(
                        fontSize: 15,
                        color: primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C21: compact Offering banner — 180-220px mobile, capped desktop.
/// Row layout: image thumb + Offering name, starting price,
/// inclusions/freebies teaser. Static; the Pax Choice rows below drive
/// the detail picker via `/packages/:id?pax=&date=`.
class PackageOfferingHero extends StatelessWidget {
  final Package package;

  const PackageOfferingHero({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFFDF4F5) : AppTheme.primary;
    final bodyColor = isDark ? const Color(0xFFC4ACAC) : AppTheme.secondary;
    final options = package.options;
    final starting = options.isEmpty
        ? (package.price ?? 4500.0)
        : options.map((o) => o.price).reduce((a, b) => a < b ? a : b);
    final teaserBits = [...?package.inclusions, ...?package.freebies]
        .take(2)
        .toList();
    final teaser = teaserBits.isNotEmpty
        ? teaserBits.join(' · ')
        : (package.description ?? '');

    return LayoutBuilder(
      builder: (context, constraints) {
        // Constraints here are finite (page caps at maxWidth 1200).
        final wide = constraints.maxWidth >= 768;
        // C21 acceptance: 180-220px mobile, capped desktop.
        final bannerHeight = wide ? 240.0 : 200.0;
        final imageWidth = wide ? 340.0 : 132.0;
        final titleSize = wide ? 22.0 : 17.0;
        final priceSize = wide ? 16.0 : 14.0;
        final teaserSize = wide ? 13.0 : 12.0;
        final pad = wide ? 20.0 : 14.0;

        Widget image() {
          final img = Container(
            width: imageWidth,
            height: bannerHeight,
            color: isDark ? AppTheme.night : AppTheme.neutralBg,
            child: (package.images != null && package.images!.isNotEmpty)
                ? Image.network(
                    package.images![0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/bar-1440.webp',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/bar-1440.webp',
                    fit: BoxFit.cover,
                  ),
          );
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: img,
          );
        }

        return Container(
          key: const Key('offering_hero'),
          width: double.infinity,
          height: bannerHeight,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.nightSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        package.name ?? '',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Starting at ${formatPeso(starting)}',
                        style: TextStyle(
                          fontSize: priceSize,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (teaser.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          teaser,
                          style:
                              TextStyle(fontSize: teaserSize, color: bodyColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// C17: one Pax Choice selector row — pax + price. Tap pushes the C144
/// Pax Choice detail (`/packages/:id?pax=&date=`), the pre-booking picker
/// carrying the headcount and the Scent shelf.
class PaxChoiceRow extends StatelessWidget {
  final int? packageId;
  final int pax;
  final double price;

  /// Date carried from the calendar (`?date=`); forwarded with the push.
  final DateTime? initialDate;

  const PaxChoiceRow({
    super.key,
    required this.packageId,
    required this.pax,
    required this.price,
    this.initialDate,
  });

  void _go(BuildContext context) {
    final query = <String>[
      'pax=$pax',
      if (initialDate != null) 'date=${formatDateParam(initialDate!)}',
    ];
    context.push('/packages/$packageId?${query.join('&')}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFFDF4F5) : AppTheme.primary;
    final bodyColor = isDark ? const Color(0xFFC4ACAC) : AppTheme.secondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // C21: adapt row density: compact single-column mobile,
        // roomier two-column desktop proportions.
        final wide = constraints.maxWidth >= 768;
        final vPad = wide ? 16.0 : 12.0;
        final titleSize = wide ? 16.0 : 15.0;
        final priceSize = wide ? 14.0 : 13.0;

        return GestureDetector(
          key: Key('pax_choice_$pax'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _go(context),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.nightSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pax Pax Choice',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatPeso(price),
                        style: TextStyle(fontSize: priceSize, color: bodyColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 20, color: bodyColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// P6 (G6-A): monogram fallback tile for packages without images.
/// Plum-tinted tile with the package initial; never a blank void.
class _MonogramTile extends StatelessWidget {
  final String? name;
  final bool isDark;

  const _MonogramTile({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final trimmed = (name ?? '').trim();
    final initial = trimmed.isNotEmpty
        ? trimmed.substring(0, 1).toUpperCase()
        : 'I';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [AppTheme.nightSurface, AppTheme.nightBorder]
              : const [Color(0xFFF3E4E7), Color(0xFFE4CBD2)],
        ),
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark ? const Color(0xFFFDF4F5) : AppTheme.primary)
                .withValues(alpha: 0.12),
            border: Border.all(
              color: (isDark ? const Color(0xFFFDF4F5) : AppTheme.primary)
                  .withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFFDF4F5) : AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
