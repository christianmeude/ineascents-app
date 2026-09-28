import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'tab_header.dart';

class SkeletonPackageCard extends StatelessWidget {
  const SkeletonPackageCard({super.key});
  @override
  Widget build(BuildContext context) {
    // P6 (Q1): dark-aware shimmer so loading states never flash white.
    // C84: single parent Shimmer — children are plain Containers.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? const Color(0xFF36222C)
        : const Color(0xFF99868C);
    final highlight = isDark
        ? const Color(0xFF5A4450)
        : const Color(0xFFE8DEE2);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1618) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0x4D99868C),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child:
                    Container(width: double.infinity, color: Colors.white),
              ),
            ),
            // Content skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Container(height: 14, width: 100, color: Colors.white),
                  const SizedBox(height: 12),
                  // Price
                  Container(height: 16, width: 80, color: Colors.white),
                  const SizedBox(height: 12),
                  // Button
                  Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// C58: packages loading skeleton — mirrors the Offering hero + Pax
/// Choice rows so loading never teases the retired card grid.
/// C84: single parent Shimmer — children are plain Containers.
class SkeletonPackagesLoading extends StatelessWidget {
  const SkeletonPackagesLoading({super.key});

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

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        key: const Key('skeleton_packages_loading'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // C97: Collections header tease — script title per TabHeader
          // (Great Vibes) + count slot bar; mirrors the real header
          // above the hero instead of jumping straight to content.
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                key: const Key('skeleton_collections_header'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Collections',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.greatVibes(
                      fontSize: TabHeader.titleSizeFor(constraints.maxWidth),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ).copyWith(
                        fontFamilyFallback: TabHeader.titleFallback),
                  ),
                  const SizedBox(height: 5),
                  bar(height: 13, width: 200, radius: 6),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Hero mirror: 200px banner (mobile) with thumb + text block.
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 768;
              final bannerHeight = wide ? 240.0 : 200.0;
              final imageWidth = wide ? 340.0 : 132.0;
              return Container(
                key: const Key('skeleton_offering_hero'),
                width: double.infinity,
                height: bannerHeight,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1618) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // C97: clip the thumb to the left edge (topLeft +
                    // bottomLeft 20) like the real PackageOfferingHero —
                    // square image corners must not poke past the outer
                    // rounding, which stays circular(20) on both edges.
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Container(
                        width: imageWidth,
                        height: bannerHeight,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            bar(height: 18, width: double.infinity, radius: 6),
                            const SizedBox(height: 8),
                            bar(height: 14, width: 140, radius: 6),
                            const SizedBox(height: 8),
                            bar(height: 12, width: double.infinity, radius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          bar(height: 18, width: 200, radius: 6),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++) ...[
            Container(
              key: Key('skeleton_pax_row_$i'),
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1618) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(height: 15, width: 140, radius: 6),
                        const SizedBox(height: 6),
                        bar(height: 13, width: 90, radius: 6),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            if (i < 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
