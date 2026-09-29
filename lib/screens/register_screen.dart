import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/index.dart';
import '../config/theme.dart';
import '../widgets/index.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
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
      } else if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage == null &&
          next.user != null) {
        // C95: pending registration (zero token) — verify email first.
        hideAppError(context);
        final email = emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : (next.user?.email ?? '');
        context.go('/verify-email?email=${Uri.encodeComponent(email)}');
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
                .register(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text,
                ),
          );
        }
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // C108: single-source label colors (were inline hex).
    final inputLabelColor = isDark
        ? AppTheme.onPrimaryButton
        : AppTheme.primaryButtonBackground;

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
                                      .register(
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                      )
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _InputLabel(text: 'Full Name', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('register_name'),
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                        ),

                        const SizedBox(height: 16),

                        _InputLabel(text: 'Email', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('register_email'),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),

                        const SizedBox(height: 16),

                        _InputLabel(text: 'Password', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('register_password'),
                          controller: passwordController,
                          obscureText: obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            // C108: screen-reader label for the toggle.
                            tooltip: obscurePassword
                                ? 'Show password'
                                : 'Hide password',
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

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('register_submit'),
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(authProvider.notifier)
                                        .register(
                                          name: nameController.text.trim(),
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
                                      'REGISTER',
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
                            onPressed: () => context.go('/login'),
                            style: OutlinedButton.styleFrom(
                              // C31: plum token (label stays dark-aware below).
                              foregroundColor:
                                  AppTheme.primaryButtonBackground,
                              side: BorderSide(
                                // C108: single-source border (was inline hex).
                                color: isDark
                                    ? AppTheme.onPrimaryButton.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppTheme.primaryButtonBackground,
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
                                'ALREADY HAVE AN ACCOUNT? LOG IN',
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
// BLURRED BACKGROUND BLOB lives in widgets/auth_background.dart (C59 shared).
// ============================================================================
