import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom page transitions builder providing smooth cross-fade transitions for desktop platforms.
class CrossFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const CrossFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
        ),
        child: child,
      ),
    );
  }
}

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF6A4053); // Dark Plum
  static const Color secondary = Color(0xFF99868C); // Muted Plum
  static const Color tertiary = Color(0xFFC4ACAC);
  static const Color neutralBg = Color(0xFFFDF4F5); // Light Cream
  static const Color neutralSurface = Color(0xFFFFFFFF); // Surface White
  static const Color neutralText = Color(0xFF6A4053); // Same as primary

  // C31 single-source primary-button token: plum fill + cream text in
  // BOTH modes. All plum CTA fills/labels resolve through here —
  // never per-screen hex.
  static const Color primaryButtonBackground = primary;
  static const Color onPrimaryButton = Color(0xFFFDF4F5); // cream
  static const Color primaryButtonHover = Color(0xFF5A3646);
  static const Color primaryButtonFocusRing = Color(0xFFDABDAC);

  // Background Gradients (for ambient backgrounds)
  static const Color backgroundTop = Color(0xFFF8E9DF);
  static const Color backgroundMiddle = Color(0xFFD8B0BA);
  static const Color backgroundBottom = Color(0xFFB78C9C);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color pending = Color(0xFFEAB308);
  static const Color unavailable = Color(0xFFFCA5A5);
  static const Color link = Color(0xFF06B6D4);

  // C36 single-source AAA error text for light surfaces: deep red-plum
  // holds 9.83:1 vs white (text bar 7:1). Dark mode keeps 0xFFF0A6B0.
  static const Color errorOnLight = Color(0xFF7A2531);

  // C118: dark-mode error text token (was inline hex in profile tile).
  static const Color errorOnDark = Color(0xFFF0A6B0);

  // C57 single-source header/brand fallback stack: Josefin Sans first,
  // system sans after — holds with font-fetch disabled (offline-safe).
  static const List<String> brandFontFallback = [
    'Josefin Sans',
    'Figtree',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  // Global PageTransitionsTheme with Desktop Cross-Fade
  static const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CrossFadePageTransitionsBuilder(),
      TargetPlatform.macOS: CrossFadePageTransitionsBuilder(),
      TargetPlatform.linux: CrossFadePageTransitionsBuilder(),
      TargetPlatform.fuchsia: CrossFadePageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: neutralBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: neutralSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primary,
        error: unavailable,
      ),
      textTheme: GoogleFonts.figtreeTextTheme().apply(
        bodyColor: primary,
        displayColor: primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: neutralBg,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
      ),
      pageTransitionsTheme: pageTransitionsTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return primary.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return primaryButtonHover; // C31 token
            }
            return primaryButtonBackground; // C31 token
          }),
          foregroundColor: WidgetStateProperty.all(
            onPrimaryButton,
          ), // C31 token
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return onPrimaryButton.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: primaryButtonFocusRing,
                width: 2.5,
              ); // C31 token
            }
            return BorderSide.none;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.hovered)) return 2.0;
            return 0.0;
          }),
        ),
      ),
      // C31: FilledButton defaults to the same plum/cream token so
      // plum-CTAs never fall back to scheme onPrimary (dark-on-dark).
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryButtonBackground.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return primaryButtonHover;
            }
            return primaryButtonBackground;
          }),
          foregroundColor: WidgetStateProperty.all(onPrimaryButton),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return onPrimaryButton.withValues(alpha: 0.08);
            }
            return null;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.06);
            }
            if (states.contains(WidgetState.focused)) {
              return primary.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return primary.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.06);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: primary, width: 2.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(color: primary, width: 1.5);
            }
            return BorderSide(
              color: primary.withValues(alpha: 0.6),
              width: 1.5,
            );
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.06);
            }
            return Colors.transparent;
          }),
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return primary.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return primary.withValues(alpha: 0.12);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: primary, width: 2.0);
            }
            return BorderSide.none;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return primary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return primary.withValues(alpha: 0.15);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: primary, width: 2.0);
            }
            return BorderSide.none;
          }),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        hoverColor: primary.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: primary),
        hintStyle: TextStyle(color: secondary.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Canonical landing nights: base #151012, surface #1c1618, border #36222c.
  static const Color night = Color(0xFF151012);
  static const Color nightSurface = Color(0xFF1C1618);
  static const Color nightBorder = Color(0xFF36222C);

  static ThemeData get darkTheme {
    const darkBg = night;
    const darkSurface = nightSurface;
    const darkPrimary = Color(0xFFFDF4F5);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg, // Very Dark Plum (no-black rule)
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary, // Light Cream for primary elements in dark mode
        secondary: secondary,
        surface: darkSurface, // Slightly lighter dark plum for surfaces
        onPrimary: darkBg,
        onSecondary: Colors.white,
        onSurface: darkPrimary,
        error: unavailable,
      ),
      textTheme: GoogleFonts.figtreeTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: darkPrimary, displayColor: darkPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkPrimary),
      ),
      pageTransitionsTheme: pageTransitionsTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          // C31: plum fill + cream text in BOTH modes (was cream/dark).
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryButtonBackground.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return primaryButtonHover;
            }
            return primaryButtonBackground;
          }),
          foregroundColor: WidgetStateProperty.all(onPrimaryButton),
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return onPrimaryButton.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: primaryButtonFocusRing,
                width: 2.5,
              );
            }
            return BorderSide.none;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.hovered)) return 2.0;
            return 0.0;
          }),
        ),
      ),
      // C31: FilledButton defaults to the same plum/cream token so
      // plum-CTAs never fall back to scheme onPrimary (dark-on-dark).
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return primaryButtonBackground.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return primaryButtonHover;
            }
            return primaryButtonBackground;
          }),
          foregroundColor: WidgetStateProperty.all(onPrimaryButton),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return onPrimaryButton.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return onPrimaryButton.withValues(alpha: 0.08);
            }
            return null;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(darkPrimary),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return darkPrimary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return darkPrimary.withValues(alpha: 0.12);
            }
            return Colors.transparent;
          }),
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return darkPrimary.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return darkPrimary.withValues(alpha: 0.08);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: darkPrimary, width: 2.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(color: darkPrimary, width: 1.5);
            }
            return BorderSide(
              color: darkPrimary.withValues(alpha: 0.6),
              width: 1.5,
            );
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(darkPrimary),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return darkPrimary.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return darkPrimary.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return darkPrimary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return darkPrimary.withValues(alpha: 0.12);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: darkPrimary, width: 2.0);
            }
            return BorderSide.none;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>((states) {
            if (states.contains(WidgetState.disabled)) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.click;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return darkPrimary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return darkPrimary.withValues(alpha: 0.15);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: darkPrimary, width: 2.0);
            }
            return BorderSide.none;
          }),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        hoverColor: darkPrimary.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: darkPrimary),
        hintStyle: TextStyle(color: secondary.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
      ),
      useMaterial3: true,
    );
  }
}
