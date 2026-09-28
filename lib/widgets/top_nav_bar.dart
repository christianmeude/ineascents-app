import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'bottom_nav_bar.dart';
import 'tab_header.dart';
import 'theme_toggle_button.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// Injectable so provider-less tests can render the bar; production
  /// passes the connected toggle via [ResponsiveAppShell].
  final Widget themeToggle;

  const TopNavBar({
    super.key,
    this.themeToggle = const ThemeToggleButton(isDark: false),
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? AppTheme.night.withValues(alpha: 0.88)
        : AppTheme.primary.withValues(alpha: 0.88);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A4053).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: preferredSize.height,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 1200.0,
                      height: preferredSize.height,
                      child: Row(
                        children: [
                          // ========================================================
                          // 1. BRAND LOGO
                          // ========================================================
                          _BrandLogo(
                            onTap: () => _navigateTo(context, '/home'),
                          ),

                          const SizedBox(width: 16),

                          // ========================================================
                          // 2. NAVIGATION ITEMS
                          // ========================================================
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TopNavItem(
                                      label: 'HOME',
                                      icon: Icons.home_outlined,
                                      activeIcon: Icons.home,
                                      isSelected:
                                          _getCurrentIndex(context) == 0,
                                      onTap: () =>
                                          _navigateTo(context, '/home'),
                                    ),
                                    const SizedBox(width: 6),
                                    _TopNavItem(
                                      label: 'PACKAGES',
                                      icon: Icons.card_giftcard_outlined,
                                      activeIcon: Icons.card_giftcard,
                                      isSelected:
                                          _getCurrentIndex(context) == 1,
                                      onTap: () =>
                                          _navigateTo(context, '/packages'),
                                    ),
                                    const SizedBox(width: 6),
                                    _TopNavItem(
                                      label: 'BOOKINGS',
                                      icon: Icons.calendar_today_outlined,
                                      activeIcon: Icons.calendar_today,
                                      isSelected:
                                          _getCurrentIndex(context) == 2,
                                      onTap: () =>
                                          _navigateTo(context, '/bookings'),
                                    ),
                                    const SizedBox(width: 6),
                                    _TopNavItem(
                                      label: 'CALENDAR',
                                      icon: Icons.event_available_outlined,
                                      activeIcon: Icons.event_available,
                                      isSelected:
                                          _getCurrentIndex(context) == 3,
                                      onTap: () =>
                                          _navigateTo(context, '/calendar'),
                                    ),
                                    const SizedBox(width: 6),
                                    _TopNavItem(
                                      label: 'PROFILE',
                                      icon: Icons.person_outline,
                                      activeIcon: Icons.person,
                                      isSelected:
                                          _getCurrentIndex(context) == 4,
                                      onTap: () =>
                                          _navigateTo(context, '/profile'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ========================================================
                          // 3. RIGHT ACTIONS (theme toggle; PACKAGES nav
                          // item covers the route, no CTA here)
                          // ========================================================
                          themeToggle,
                        ],
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

  int _getCurrentIndex(BuildContext context) {
    try {
      final router = GoRouter.maybeOf(context);
      if (router == null) return 0;
      String location = '';
      try {
        location = router.routeInformationProvider.value.uri.path;
      } catch (_) {
        try {
          location = router.location;
        } catch (_) {}
      }
      // C53: shared matcher — the single `/booking/:id` route reads as
      // Packages (its branch), only plural `/bookings…` reads as Bookings.
      return navIndexForLocation(location);
    } catch (_) {
      return 0;
    }
  }

  void _navigateTo(BuildContext context, String path) {
    try {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        context.go(path);
      }
    } catch (_) {}
  }
}

class _TopNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TopNavItem> createState() => _TopNavItemState();
}

class _TopNavItemState extends State<_TopNavItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final bg = isSelected
        ? Colors.white.withValues(alpha: 0.25)
        : (_isHovered || _isFocused)
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.transparent;

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (h) => setState(() => _isHovered = h),
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
      },
      child: Semantics(
        button: true,
        selected: isSelected,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(9999),
              border: _isFocused
                  ? Border.all(color: Colors.white, width: 2)
                  : isSelected
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1,
                    )
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? widget.activeIcon : widget.icon,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 3),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatefulWidget {
  final VoidCallback onTap;

  const _BrandLogo({required this.onTap});

  @override
  State<_BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<_BrandLogo> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (h) => setState(() => _isHovered = h),
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
      },
      child: Semantics(
        button: true,
        label: 'INEA Scents Home',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: _isFocused
                  ? Border.all(color: Colors.white, width: 2.0)
                  : Border.all(color: Colors.transparent, width: 2.0),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INEA',
                    style: GoogleFonts.josefinSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ).copyWith(
                      // C57: offline-safe fallback stack (single-source).
                      fontFamilyFallback: AppTheme.brandFontFallback,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Scents',
                    style: GoogleFonts.greatVibes(
                      fontSize: 20,
                      color: const Color(0xFFFDF4F5),
                      // C101: script-first offline-safe fallback (single-source).
                    ).copyWith(
                      fontFamilyFallback: TabHeader.titleFallback,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
