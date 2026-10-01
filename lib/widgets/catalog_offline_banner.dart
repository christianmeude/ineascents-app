import 'package:flutter/material.dart';

import '../config/theme.dart';

/// C160: offline banner for the packages catalog. Renders when the catalog
/// falls back to the 5-minute in-memory cache (see `packages_screen.dart`).
/// Plum/cream Elegant Concierge tokens only — no new palette.
class CatalogOfflineBanner extends StatelessWidget {
  const CatalogOfflineBanner({super.key});

  static const String labelText = 'Offline — showing cached packages';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppTheme.nightSurface
        : AppTheme.primary.withValues(alpha: 0.08);
    final border = isDark
        ? AppTheme.nightBorder
        : AppTheme.primary.withValues(alpha: 0.30);
    final fg = isDark ? AppTheme.onPrimaryButton : AppTheme.primary;

    return Semantics(
      liveRegion: true,
      label: labelText,
      child: Container(
        key: const Key('catalog_offline_banner'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                labelText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
