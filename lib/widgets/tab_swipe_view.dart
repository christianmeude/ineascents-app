import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// C158: mobile swipe between the 5 tab roots (nav order).
///
/// PageView wrapper used ONLY on mobile tab roots
/// (`/home`, `/packages`, `/bookings`, `/calendar`, `/profile`).
/// - Slide per swipe direction via [PageView] (nav order 0..4).
/// - Page change calls `goBranch` so [BottomNavBar] stays synced both
///   directions (swipe -> branch, tap -> controller jump).
/// - Detail/sub-routes (booking, bookings/:id, profile/*) never mount
///   this widget — [ResponsiveAppShell] renders the plain shell there.
/// - Wizard step navigation stays buttons-only: [BookingScreen] owns no
///   PageView and its route is excluded above.
/// - Web/desktop untouched: shell renders the indexedStack as-is.
class TabSwipeView extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const TabSwipeView({super.key, required this.navigationShell});

  @override
  State<TabSwipeView> createState() => _TabSwipeViewState();
}

class _TabSwipeViewState extends State<TabSwipeView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TabSwipeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.navigationShell.currentIndex;
    if (target != oldWidget.navigationShell.currentIndex &&
        _controller.hasClients) {
      final current = _controller.page?.round() ?? _controller.initialPage;
      if (current != target) {
        // Tab taps switch instantly (matches goBranch); post-frame avoids
        // jump-during-build when the shell rebuilds synchronously.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_controller.hasClients) return;
          final now = _controller.page?.round() ?? target;
          if (now != target) _controller.jumpToPage(target);
        });
      }
    }
  }

  void _onPageChanged(int index) {
    if (index != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.navigationShell.currentIndex;
    // Single live shell mount (no duplicate GlobalKey): only the active
    // page hosts the shell; neighbours are blank scaffold-colored pages
    // so the swipe still slides per direction before goBranch swaps.
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return PageView(
      controller: _controller,
      onPageChanged: _onPageChanged,
      children: List<Widget>.generate(5, (i) {
        if (i == current) return widget.navigationShell;
        return Container(key: ValueKey('tab_swipe_placeholder_$i'), color: bg);
      }),
    );
  }
}
