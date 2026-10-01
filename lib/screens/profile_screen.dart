import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Solid card surfaces matching the rest of the app (Q3).
    final userName = authState.user?.name ?? 'User';
    final userEmail = authState.user?.email ?? '';

    // Safely get the first letter.
    final firstLetter = userName.trim().isNotEmpty
        ? userName.trim().substring(0, 1).toUpperCase()
        : 'U';

    // P7: no explicit color — flat theme scaffold background.
    return Scaffold(
      // C22: distilled — mobile AppBar removed (brand title + dead
      // overflow action). Desktop TopNavBar covers nav.
      appBar: null,

      // ============================================================
      // BODY (P7: flat theme background; decorative gradient removed)
      // ============================================================
      body: SafeArea(
        // C9: no-scroll fit at 360x800 — fixed header/cards plus an
        // Expanded logo zone that centers the muted mark in the
        // card-edge-to-screen-bottom space instead of scrolling.
        // C81: Center > ConstrainedBox cap mirrors home/bookings; the
        // header padding lives INSIDE the cap. C71 single-column stack
        // kept; C82 caps the cards at 600 centered (pre-C56 proof).
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveAppShell.maxContentWidth,
            ),
            child: Padding(
              padding: ResponsiveAppShell.screenHeaderPadding.copyWith(
                bottom: 12,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // PAGE TITLE (C42: unified header, trailing empty —
                  // C35: dark-aware via CardSurfaces, never per-screen hex)
                  // ==================================================
                  const TabHeader(
                    title: 'My Profile',
                    count: 'Manage your account and preferences.',
                  ),

                  const SizedBox(height: 12),

                  // C60: Q9 retired.

                  // ==================================================
                  // PROFILE + SETTINGS (C71: stacked single column
                  // on all breakpoints; C82: cards capped at 600
                  // centered, header stays at the 1200 container)
                  // ==================================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ResponsiveAppShell.maxCardWidth,
                      ),
                      child: Column(
                        children: [
                          _ProfileCard(
                            userName: userName,
                            userEmail: userEmail,
                            firstLetter: firstLetter,
                          ),
                          const SizedBox(height: 12),
                          _SettingsColumn(
                            onLogout: () {
                              ref.read(authProvider.notifier).logout();
                              context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // BRAND FOOTER (C9: muted mark optically centered in
                  // the card-edge-to-screen-bottom zone; SizedBox
                  // bounds the AppLogo FittedBox so its layout box
                  // stays compact — Transform.scale kept the full-size
                  // box and pushed 360x800 into scroll/overflow).
                  Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: 0.3,
                        // C56: enlarged footer mark (was 120) so the brand
                        // reads at desktop widths; still bounded so the
                        // 360x800 no-scroll fit holds.
                        child: SizedBox(width: 180, child: const AppLogo()),
                      ),
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

// ============================================================================
// PROFILE CARD (P7: single-column composition)
// ============================================================================

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String firstLetter;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.firstLetter,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = CardSurfaces.cardBg(context);
    final cardBorder = CardSurfaces.cardBorder(context);
    final textColor = CardSurfaces.title(context);
    final secondaryTextColor = CardSurfaces.body(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        // P6 (Q3): solid card, never glass.
        color: cardBg,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: cardBorder, width: 1),

        boxShadow: [
          BoxShadow(
            color: CardSurfaces.plum.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================
          // AVATAR
          // ==================================================
          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF95647E), AppTheme.primary],
              ),

              boxShadow: [
                BoxShadow(
                  color: CardSurfaces.plum.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Center(
              child: Text(
                firstLetter,

                // C118: theme ramp (explicit Figtree).
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ==================================================
          // USER INFORMATION
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  userName,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  // C118: theme ramp (explicit Figtree).
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 5),

                Text(
                  userEmail,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  // C118: theme ramp (explicit Figtree).
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor, fontSize: 12.5),
                ),
              ],
            ),
          ),

          // ==================================================
          // EDIT BUTTON
          // ==================================================
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: CardSurfaces.chipBg(context),
              shape: BoxShape.circle,
              border: Border.all(color: CardSurfaces.cardBorder(context)),
            ),

            child: IconButton(
              padding: EdgeInsets.zero,

              icon: Icon(Icons.edit_outlined, color: textColor, size: 18),

              // C148: mobile (<768px) opens the shared bottom sheet with
              // the same form; wide keeps the /profile/edit route.
              onPressed: () {
                if (isNarrowSheet(context)) {
                  showProfileSheet<void>(
                    context,
                    title: 'Edit Profile',
                    subtitle:
                        'Update your name or switch to a new verified email.',
                    child: const EditProfileForm(),
                  );
                } else {
                  context.push('/profile/edit');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SETTINGS COLUMN (P7: header + card, single-column composition)
// ============================================================================

class _SettingsColumn extends StatelessWidget {
  final VoidCallback onLogout;

  const _SettingsColumn({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final cardBg = CardSurfaces.cardBg(context);
    final cardBorder = CardSurfaces.cardBorder(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,

          decoration: BoxDecoration(
            // P6 (Q3): solid card, never glass.
            color: cardBg,
            borderRadius: BorderRadius.circular(24),

            border: Border.all(color: cardBorder),

            boxShadow: [
              BoxShadow(
                color: CardSurfaces.plum.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Column(
            children: [
              _ProfileSettingTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                // C148: mobile (<768px) opens the shared bottom sheet with
                // the same form; wide keeps the /profile/edit route.
                onTap: () {
                  if (isNarrowSheet(context)) {
                    showProfileSheet<void>(
                      context,
                      title: 'Edit Profile',
                      subtitle:
                          'Update your name or switch to a new verified email.',
                      child: const EditProfileForm(),
                    );
                  } else {
                    context.push('/profile/edit');
                  }
                },
              ),

              const _SettingDivider(),

              _ProfileSettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                // C149: mobile (<768px) opens the shared bottom sheet with
                // the same form; wide keeps the /profile/password route.
                onTap: () {
                  if (isNarrowSheet(context)) {
                    showProfileSheet<void>(
                      context,
                      title: 'Change Password',
                      subtitle: ChangePasswordScreen.flowDescription,
                      child: const ChangePasswordForm(),
                    );
                  } else {
                    context.push('/profile/password');
                  }
                },
              ),

              const _SettingDivider(),

              // C23: the single in-app theme toggle. Wired to
              // themeModeProvider via toggleTheme so the choice persists
              // (inea-theme) and every screen follows it through
              // MaterialApp.themeMode. No toggles live on other screens'
              // settings surfaces.
              const _ThemeToggleTile(),

              const _SettingDivider(),

              _ProfileSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => context.push('/privacy'),
              ),

              const _SettingDivider(),

              _ProfileSettingTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: true,
                showArrow: false,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// THEME TOGGLE TILE (C23: Profile-only; persisted via toggleTheme)
// ============================================================================

class _ThemeToggleTile extends ConsumerWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // C56: brand-aligned via CardSurfaces/AppTheme tokens (was per-screen
    // hex); matches _ProfileSettingTile icon chip + text in both modes.
    const primaryColor = AppTheme.primary;
    final textColor = CardSurfaces.title(context);
    final iconColor = CardSurfaces.onBrand(context);

    final mode = ref.watch(themeModeProvider);
    final darkEnabled =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    void flip(bool value) => toggleTheme(ref, value);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => flip(!darkEnabled),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    darkEnabled
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Dark theme',
                    // C118: theme ramp (explicit Figtree).
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Switch.adaptive(
                  value: darkEnabled,
                  // C56: brand plum track (was default green-grey).
                  activeThumbColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.35),
                  inactiveThumbColor: CardSurfaces.mutedPlum,
                  onChanged: flip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE SETTING TILE
// ============================================================================

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showArrow;
  // C29: deferred tiles render disabled with a short note.
  final bool enabled;
  final String? note;

  const _ProfileSettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.showArrow = true,
    this.enabled = true,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    // P6 (Q1): dark-aware tile text.
    // C118: single-source surfaces (were inline hex).
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = AppTheme.primary;
    final textColor = CardSurfaces.title(context);
    final secondaryTextColor = CardSurfaces.body(context);

    final itemColor = isDestructive
        ? (isDark ? AppTheme.errorOnDark : AppTheme.errorOnLight)
        : (isDark ? AppTheme.onPrimaryButton : primaryColor);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        // C29: disabled tiles are not tappable.
        onTap: enabled ? onTap : null,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(24),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),

          child: Row(
            children: [
              // ========================================================
              // ICON
              // ========================================================
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: isDestructive
                      ? itemColor.withValues(alpha: 0.10)
                      : primaryColor.withValues(alpha: 0.10),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: itemColor, size: 20),
              ),

              const SizedBox(width: 14),

              // ========================================================
              // TEXT
              // ========================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      // C118: theme ramp (explicit Figtree).
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDestructive ? itemColor : textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 3),

                    // C29: deferred note under disabled tiles.
                    if (note != null)
                      Text(
                        note!,
                        // C118: theme ramp (explicit Figtree).
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                      ),
                  ],
                ),
              ),

              // ========================================================
              // ARROW
              // ========================================================
              // C29: no arrow on disabled tiles.
              if (showArrow && enabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: secondaryTextColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SETTING DIVIDER
// ============================================================================

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 73, right: 17),

      child: Divider(
        height: 1,
        thickness: 0.7,
        // P6 (Q1): visible on solid cards in both themes.
        // C118: single-source border (was inline hex).
        color: CardSurfaces.cardBorder(context),
      ),
    );
  }
}
