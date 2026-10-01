import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';
import 'processing_payment_overlay.dart';
import 'tab_swipe_view.dart';
import 'theme_toggle_button.dart';
import 'top_nav_bar.dart';

/// Foundational responsive layout scaffolding for the application.
///
/// Breakpoints:
/// - Mobile (`< 768px`, 1-col): Hides [TopNavBar], renders unconstrained content, and renders [BottomNavBar].
/// - Tablet (`768px - 1024px`, 2-col): Displays [TopNavBar], centers content in [maxContentWidth] container.
/// - Desktop (`> 1024px`, 3-col): Displays [TopNavBar], centers content in [maxContentWidth] container.
/// - Max content width: `1200px`.
class ResponsiveAppShell extends StatelessWidget {
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1200.0;
  // C72: shared screen header insets — home, packages, bookings and
  // calendar read this token instead of hardcoding per-screen insets
  // (profile uses it with its own bottom via copyWith).
  static const EdgeInsets screenHeaderPadding =
      EdgeInsets.fromLTRB(20, 18, 20, 30);
  // C82: inner profile cards cap (600 centered) — named here so the
  // profile cap reads as a shared token, not a raw literal.
  static const double maxCardWidth = 600.0;

  final Widget child;
  final double maxWidth;
  final double breakpoint;
  final Color? backgroundColor;

  /// C23: live tab shell when hosted in a `StatefulShellRoute`. The shell
  /// renders the active branch and drives the tab bar without resetting
  /// per-tab stacks. Null in tests / standalone use, where [child] renders.
  final StatefulNavigationShell? navigationShell;

  /// Injectable so provider-less tests can render the shell; production
  /// passes the connected toggle.
  final Widget themeToggle;

  const ResponsiveAppShell({
    super.key,
    required this.child,
    this.maxWidth = maxContentWidth,
    this.breakpoint = mobileBreakpoint,
    this.backgroundColor,
    this.navigationShell,
    this.themeToggle = const ThemeToggleButton(isDark: false),
  });

  /// Helper to get responsive column counts based on R1 breakpoints.
  /// P6 (G2): package grids render 2 → 3 → 4 columns across
  /// mobile / tablet / desktop.
  static int getGridColumnCount(double width) {
    if (width > tabletBreakpoint) {
      return 4;
    } else if (width >= mobileBreakpoint) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Shared grid delegate for package grids (P6 G2). Keeps the
  /// established card proportions and spacing; only the column count
  /// adapts to the available width.
  static SliverGridDelegate gridDelegateForWidth(
    double width, {
    double childAspectRatio = 0.52,
    double crossAxisSpacing = 14,
    double mainAxisSpacing = 16,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: getGridColumnCount(width),
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  /// C3: Home package-grid delegate. Column counts follow
  /// [getGridColumnCount] (2 → 3 → 4); the tile ratio hugs the
  /// PackageCard content (image at AspectRatio 1.15 + fixed body)
  /// so tablet/desktop tiles don't leave a void below the price.
  /// Mobile band keeps the established 0.52 — mobile untouched.
  static SliverGridDelegate homeGridDelegateForWidth(
    double width, {
    double crossAxisSpacing = 15,
    double mainAxisSpacing = 15,
  }) {
    final cols = getGridColumnCount(width);
    double ratio;
    if (width < mobileBreakpoint) {
      ratio = 0.52;
    } else {
      final cellW = (width - crossAxisSpacing * (cols - 1)) / cols;
      // Measured card body below the image (~104px at 1.0x text:
      // name + rating + price rows + 12px vertical padding each side).
      const imageAspect = 1.15;
      const cardBodyHeight = 104.0;
      ratio = cellW / (cellW / imageAspect + cardBodyHeight);
    }
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      childAspectRatio: ratio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  /// Returns `true` if the screen width is strictly in the Desktop range (`> 1024px`).
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletBreakpoint;
  }

  /// Returns `true` if the screen width is strictly in the Tablet range (`768px - 1024px`).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width <= tabletBreakpoint;
  }

  /// Returns `true` if the screen width is strictly in the Mobile range (`< 768px`).
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns `true` if the screen width qualifies for wide layout / Top Navigation Bar (`>= 768px`).
  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint;
  }

  /// C158: tab roots eligible for mobile swipe (nav order). Detail /
  /// sub-routes (booking, bookings/:id, profile/*) are excluded.
  static const List<String> tabSwipeRoots = [
    '/home',
    '/packages',
    '/bookings',
    '/calendar',
    '/profile',
  ];

  /// C158: mobile-only swipe wrapper. Roots get [TabSwipeView]
  /// (PageView -> goBranch); detail routes render the plain shell so the
  /// booking wizard stays buttons-only. Desktop keeps indexedStack as-is.
  Widget _mobileBody(BuildContext context, StatefulNavigationShell shell) {
    String location = '';
    try {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        try {
          location = router.routeInformationProvider.value.uri.path;
        } catch (_) {
          try {
            location = router.location;
          } catch (_) {}
        }
      }
    } catch (_) {}
    final path = location.split('?').first;
    if (tabSwipeRoots.contains(path)) {
      return TabSwipeView(
        key: const ValueKey('tab_swipe_view'),
        navigationShell: shell,
      );
    }
    return shell;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktopView = width >= breakpoint;

        final shell = navigationShell;
        final Widget bodyContent;
        if (shell != null && !isDesktopView) {
          bodyContent = _mobileBody(context, shell);
        } else {
          bodyContent = shell ?? child;
        }
        return Scaffold(
          // Null inherits the theme scaffold color; the fixed ambient
          // below paints the shared gradient over it full-bleed.
          backgroundColor: backgroundColor,
          appBar: isDesktopView
              ? TopNavBar(themeToggle: themeToggle)
              : null,
          // P7: flat theme background — decorative ambient layers were
          // stripped app-wide per owner direction; the theme scaffold
          // color (light cream / dark night) carries both modes.
          // C23: the live navigation shell renders the active tab branch.
          // C51: the minimizable payment modal stacks above every tab so
          // processing survives navigation (provider-level, never
          // route-local).
          body: ProcessingPaymentOverlayHost(
            child: bodyContent,
          ),
          bottomNavigationBar: isDesktopView
              ? null
              : _buildMobileBottomNav(context),
        );
      },
    );
  }

  Widget? _buildMobileBottomNav(BuildContext context) {
    try {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        String location = '';
        try {
          location = router.routeInformationProvider.value.uri.path;
        } catch (_) {
          try {
            location = router.location;
          } catch (_) {}
        }
        final hideBottomNav =
            location.contains('booking/') ||
            location.contains('login') ||
            location.contains('register') ||
            location.contains('forgot-password') ||
            location.contains('reset-password') ||
            location.contains('splash');
        if (hideBottomNav) {
          return null;
        }
      }
    } catch (_) {}
    final shell = navigationShell;
    if (shell != null) return BottomNavBar(navigationShell: shell);
    return const BottomNavBar();
  }
}
