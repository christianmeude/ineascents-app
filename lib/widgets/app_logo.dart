import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import 'tab_header.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // C101: plum/cream via single-source tokens (values identical —
    // primaryButtonBackground == 0xFF6A4053, onPrimaryButton == 0xFFFDF4F5).
    final brandPrimary = isDark
        ? AppTheme.onPrimaryButton
        : AppTheme.primaryButtonBackground;
    final strokeColor = isDark
        ? AppTheme.primaryButtonBackground
        : AppTheme.onPrimaryButton;

    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw >= 640;

    final ineaSize = isDesktop ? 72.0 : 60.0;
    final ineaSpacing = ineaSize * 0.15;
    final scentsSize = isDesktop ? 96.0 : 72.0;

    // Adjusted offset for perfect visual 1:1 match with Inertia Web Rendering
    final scentsOffsetX = isDesktop ? -76.0 : -63.0;
    final scentsOffsetY = isDesktop ? 34.0 : 25.0;

    // Since Transform.translate only moves the visual layer, the layout bounding box
    // still reserves the original width on the right. We shift the whole block right
    // by half the offset to keep the logo perfectly centered.
    final visualCenterOffset = isDesktop ? 38.0 : 31.5;

    // C57: brand header renders Josefin Sans with the single-source
    // offline-safe fallback stack (copyWith AFTER — the package
    // overwrites fontFamilyFallback internally).
    final ineaStroke = GoogleFonts.josefinSans(
      fontSize: ineaSize,
      fontWeight: FontWeight.w700,
      letterSpacing: ineaSpacing,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor,
    ).copyWith(fontFamilyFallback: AppTheme.brandFontFallback);

    final ineaFill = GoogleFonts.josefinSans(
      fontSize: ineaSize,
      fontWeight: FontWeight.w700,
      letterSpacing: ineaSpacing,
      color: brandPrimary,
    ).copyWith(fontFamilyFallback: AppTheme.brandFontFallback);

    // C101: script-first offline-safe fallback (copyWith AFTER —
    // the package overwrites fontFamilyFallback internally).
    final scentsStroke = GoogleFonts.greatVibes(
      fontSize: scentsSize,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor,
    ).copyWith(fontFamilyFallback: TabHeader.titleFallback);

    final scentsFill = GoogleFonts.greatVibes(
      fontSize: scentsSize,
      color: brandPrimary,
    ).copyWith(fontFamilyFallback: TabHeader.titleFallback);

    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Transform.translate(
        offset: Offset(visualCenterOffset, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ==============================================================
            // 1. INEA STROKE (Base layer, sizes the Stack)
            // ==============================================================
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INEA', style: ineaStroke),
                // Invisible untranslated Scents guarantees the Stack layout width
                // matches the natural flow of the two words.
                Opacity(opacity: 0, child: Text('Scents', style: scentsStroke)),
              ],
            ),

            // ==============================================================
            // 2. INEA FILL
            // ==============================================================
            Text('INEA', style: ineaFill),

            // ==============================================================
            // 3. SCENTS STROKE (Knocks out the INEA Fill beneath it!)
            // ==============================================================
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(opacity: 0, child: Text('INEA', style: ineaStroke)),
                Transform.translate(
                  offset: Offset(scentsOffsetX, scentsOffsetY),
                  child: Text('Scents', style: scentsStroke),
                ),
              ],
            ),

            // ==============================================================
            // 4. SCENTS FILL
            // ==============================================================
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(opacity: 0, child: Text('INEA', style: ineaStroke)),
                Transform.translate(
                  offset: Offset(scentsOffsetX, scentsOffsetY),
                  child: Text('Scents', style: scentsFill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INPUT LABEL
// ============================================================================
