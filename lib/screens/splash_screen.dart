import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/tab_header.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _taglineAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // C106: tagline arrives after the wordmark (concierge voice, script).
    _taglineAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    );

    _animationController.forward();

    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      context.go('/login');
    }
  }

  // C128: honor reduced motion — jump to the end state instead of
  // playing the 2.2s entrance when animations are disabled.
  bool _motionResolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motionResolved) {
      _motionResolved = true;
      if (MediaQuery.disableAnimationsOf(context)) {
        _animationController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // C106: script tagline in single-source cream (offline-safe fallback).
    final taglineStyle = GoogleFonts.greatVibes(
      fontSize: 28,
      color: AppTheme.onPrimaryButton,
    ).copyWith(fontFamilyFallback: TabHeader.titleFallback);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // ========================================================
              // BACKGROUND (C128: decorative — excluded from semantics;
              // Positioned.fill: bare DecoratedBox would collapse to 0x0
              // where Container expanded to fill)
              // ========================================================
              const Positioned.fill(
                child: ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF1E3D3), // Nude/Peach
                          Color(0xFFE4C3C7),
                          Color(0xFFC7A2AE),
                          Color(0xFF90697B),
                          Color(0xFF653A4C), // Plum
                        ],
                        stops: [0.0, 0.3, 0.55, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================================
              // MAIN BRAND
              // ========================================================
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    // C101: shared wordmark (was inline INEA/Scents dup).
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: 'Inea Scents',
                          child: const SizedBox(
                            width: 280,
                            child: AppLogo(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _taglineAnimation,
                          child: Text(
                            'Bespoke scent experiences',
                            style: taglineStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
