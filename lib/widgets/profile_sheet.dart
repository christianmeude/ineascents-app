import 'package:flutter/material.dart';

import 'card_surfaces.dart';
import 'mobile_clamp_scroll.dart';
import 'responsive_app_shell.dart';

// ============================================================================
// PROFILE SHEET (C148: shared mobile bottom-sheet for profile flows)
// ============================================================================
//
// One pattern for Edit Profile, Change Password, and Forgot Password so the
// three sheets land uniform: drag handle, title, keyboard-safe scroll.
// Mobile (<768px) presents the sheet; wide keeps the existing routes —
// sheets are a mobile-only presentation, never a web modal (grill Q3).

/// True below the shared mobile breakpoint — the sheet branch.
bool isNarrowSheet(BuildContext context) =>
    MediaQuery.sizeOf(context).width < ResponsiveAppShell.mobileBreakpoint;

/// Presents [child] as a bottom sheet with handle + title.
///
/// Dismiss-lock while busy (grill Q4) is the child's job: wrap content in
/// `PopScope(canPop: !sending)` so back/drag is refused mid-request and
/// allowed when idle. This helper stays purely presentational.
Future<T?> showProfileSheet<T>(
  BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
  final textColor = CardSurfaces.title(context);
  final secondaryTextColor = CardSurfaces.body(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CardSurfaces.cardBg(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
          ),
          child: SingleChildScrollView(
            // C40 parity: clamp overscroll on mobile; desktop untouched.
            physics: MobileClampScroll.physicsOf(ctx),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    key: const Key('profile_sheet_handle'),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          CardSurfaces.mutedPlum.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
