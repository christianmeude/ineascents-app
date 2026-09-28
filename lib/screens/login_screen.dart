import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/index.dart';
import '../config/theme.dart';
import '../widgets/index.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.verified = false});

  /// True when arriving from /verify-email — shows the verified notice.
  final bool verified;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        // C52: never carry a prior error surface onto /home.
        hideAppError(context);
        context.go('/home');
      } else if (next.errorMessage != null) {
        // C52: form-level failure renders in-card (see build); only a
        // transient failure additionally surfaces a toast with Retry.
        final message =
            next.errorMessage ??
            "That didn't work. Check your details and try again.";
        if (isTransientErrorMessage(message)) {
          showAppError(
            context,
            // P6 (Q8): friendly fallback; provider messages pass through.
            message: message,
            transient: true,
            onRetry: () => ref
                .read(authProvider.notifier)
                .login(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                ),
          );
        }
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputLabelColor = isDark
        ? const Color(0xFFFDF4F5)
        : const Color(0xFF6A4053);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Let AuthBackground handle background
      body: AuthBackground(
        isDark: isDark,
        child: Stack(
          children: [
            // ======================================================
            // MAIN CONTENT
            // ======================================================
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  // C40: clamp overscroll on mobile (<768px); SDK default
                  // (stretch Android / bounce iOS) displaced content past edge.
                  physics: MobileClampScroll.physicsOf(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 336),
                    child: Column(
                      children: [
                        const AppLogo(),
                        const SizedBox(
                          height: 44,
                        ), // Adjusted to account for the visual overhang of the logo

                        // C95: verified notice after register→verify.
                        if (widget.verified) ...[
                          _VerifiedNotice(isDark: isDark),
                          const SizedBox(height: 16),
                        ],

                        // C52: form-level failure renders in-card; Retry
                        // only for transient failures (toast covers those).
                        if (authState.errorMessage != null) ...[
                          FormErrorSummary(
                            message: authState.errorMessage!,
                            onRetry: isTransientErrorMessage(
                              authState.errorMessage!,
                            )
                                ? () => ref
                                      .read(authProvider.notifier)
                                      .login(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                      )
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _InputLabel(text: 'Email', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),

                        const SizedBox(height: 24), // gap-6

                        Row(
                          children: [
                            // C23: Expanded keeps the pair inside 360px even
                            // with wide fallback fonts (was 41px overflow).
                            Expanded(
                              child: _InputLabel(
                                text: 'Password',
                                color: inputLabelColor,
                              ),
                            ),
                            _LinkButton(
                              text: 'Forgot password?',
                              color: isDark
                                  ? const Color(
                                      0xFFFDF4F5,
                                    ).withValues(alpha: 0.8)
                                  : const Color(0xFF6A4053),
                              onTap: () => context.push('/forgot-password'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        CustomTextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 32,
                        ), // gap-6 (24px) + mt-2 (8px) = 32px

                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                mouseCursor: SystemMouseCursors.click,
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                                activeColor:
                                    AppTheme.primaryButtonBackground, // C31
                                checkColor: AppTheme.onPrimaryButton, // C31
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppTheme
                                        .primaryButtonBackground; // C31
                                  }
                                  return isDark
                                      ? const Color(0xFF151012)
                                      : Colors.white;
                                }),
                                side: BorderSide(
                                  color: AppTheme.primaryButtonBackground // C31
                                      .withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: GoogleFonts.figtree(
                                color: isDark
                                    ? const Color(
                                        0xFFFDF4F5,
                                      ).withValues(alpha: 0.8)
                                    : const Color(0xFF6A4053),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 32,
                        ), // gap-6 (24px) + mt-2 (8px) = 32px

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(authProvider.notifier)
                                        .login(
                                          email: emailController.text.trim(),
                                          password: passwordController.text,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              // C31: plum/cream token both modes.
                              backgroundColor:
                                  AppTheme.primaryButtonBackground,
                              // C23: keep the plum fill while loading instead
                              // of dropping to the grey disabled wash.
                              disabledBackgroundColor:
                                  AppTheme.primaryButtonBackground,
                              foregroundColor: AppTheme.onPrimaryButton,
                              disabledForegroundColor:
                                  AppTheme.onPrimaryButton,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      // C31: cream spinner on plum token.
                                      color: AppTheme.onPrimaryButton,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'LOG IN',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.figtree(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => context.go('/register'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.primaryButtonBackground, // C31 token
                              side: BorderSide(
                                color: isDark
                                    ? const Color(
                                        0xFFFDF4F5,
                                      ).withValues(alpha: 0.5)
                                    : const Color(0xFF6A4053),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            // C23: scale down instead of clipping glyphs at
                            // narrow widths (360px).
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CREATE NEW ACCOUNT',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.figtree(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  // C31: cream label in dark via token.
                                  color: isDark
                                      ? AppTheme.onPrimaryButton
                                      : AppTheme.primaryButtonBackground,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // THEME TOGGLE
            // ======================================================
            const Positioned(
              top: 24,
              right: 24,
              child: SafeArea(child: ConnectedThemeToggleButton()),
            ),
          ],
        ),
      ),
    );
  }
}

// C101: brand wordmark lives in widgets/app_logo.dart (shared AppLogo).

// ============================================================================
// INPUT LABEL
// ============================================================================

class _InputLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _InputLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.figtree(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ============================================================================
// LINK BUTTON (Accessible web link with hover and focus ring)
// ============================================================================

class _LinkButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (hovered) {
        if (_isHovered != hovered) {
          setState(() => _isHovered = hovered);
        }
      },
      onShowFocusHighlight: (focused) {
        if (_isFocused != focused) {
          setState(() => _isFocused = focused);
        }
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: _isFocused
                ? Border.all(color: widget.color, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.figtree(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.7)
                  : widget.color,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              decoration: _isHovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// VERIFIED NOTICE (C95: register→verify lands on /login?verified=1)
// ============================================================================

class _VerifiedNotice extends StatelessWidget {
  final bool isDark;

  const _VerifiedNotice({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('login_verified_notice'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151012).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryButtonBackground.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppTheme.primaryButtonBackground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Email verified. Log in to continue.',
              style: GoogleFonts.figtree(
                color: isDark
                    ? const Color(0xFFFDF4F5)
                    : const Color(0xFF6A4053),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BLURRED BACKGROUND BLOB lives in widgets/auth_background.dart (C59 shared).
// ============================================================================
