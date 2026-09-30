import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'card_surfaces.dart';

/// C42: one shared two-slot tab header (C41 spec §1–§3, pairing B).
///
/// LEFT — title + count/subtitle. RIGHT — one reserved trailing slot that
/// renders empty until a future ticket wires an action (zero actions now).
/// Title 32px at/above [narrowBreakpoint], 28px below (script optical
/// parity vs the old 26/22 sans); count fixed 13px;
/// single-line ellipsis, step change only (no FittedBox).
class TabHeader extends StatelessWidget {
  /// Viewport breakpoint matching the existing `< 768` checks (C41 §3).
  static const double narrowBreakpoint = 768;
  static const double titleSizeWide = 32;
  static const double titleSizeNarrow = 28;
  static const double countSize = 13;
  static const double titleLetterSpacing = 0;

  /// C73: header title renders Great Vibes (was Josefin Sans, C57);
  /// script-first offline-safe fallback (brand stack stays Josefin
  /// for the INEA logo — out of scope, do not realias).
  static const List<String> titleFallback = [
    'Great Vibes',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];
  static const List<String> bodyFallback = [
    'Figtree',
    '-apple-system',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  final String title;
  final String count;

  /// Reserved trailing-action slot. Empty until a future ticket claims it —
  /// never wire an action here without one.
  final Widget trailing;

  const TabHeader({
    super.key,
    required this.title,
    required this.count,
    this.trailing = const SizedBox.shrink(),
  });

  /// Title size for a viewport [width] (pure, testable).
  static double titleSizeFor(double width) =>
      width < narrowBreakpoint ? titleSizeNarrow : titleSizeWide;

  @override
  Widget build(BuildContext context) {
    // C41 §5 B: explicit fallback stacks hold with font-fetch disabled.
    // (copyWith AFTER the GoogleFonts call — the package overwrites
    // fontFamilyFallback internally.)
    // C73: Great Vibes ships Regular 400 only — was w400 (no synthetic
    // bold), neutral tracking (scripts kern naturally), natural line
    // height (script descenders clip under the old 1.15 override).
    // C127: owner-directed bolden — w700 faux-bold on the script so
    // screen titles (Our Collections, Availability, …) carry weight.
    final titleStyle = GoogleFonts.greatVibes(
      fontSize: titleSizeFor(MediaQuery.sizeOf(context).width),
      fontWeight: FontWeight.w700,
      letterSpacing: titleLetterSpacing,
      color: CardSurfaces.title(context),
    ).copyWith(fontFamilyFallback: titleFallback);
    final countStyle = GoogleFonts.figtree(
      fontSize: countSize,
      fontWeight: FontWeight.w400,
      color: CardSurfaces.body(context),
    ).copyWith(fontFamilyFallback: bodyFallback);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(height: 5),
              Text(
                count,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: countStyle,
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
