import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/index.dart';
import '../config/theme.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';

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
  // C159: privacy acknowledgment gates submit (version-pinned consent is
  // captured server-side at inquiry/booking; register carries no PII beyond
  // the account itself).
  bool consentChecked = false;

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
        // C162: sanitize both surfaces — raw transient/server blobs
        // (mailer-down 500, stream_socket/exception text) render as the
        // short friendly line, never verbatim.
        final raw =
            next.errorMessage ??
            "That didn't work. Check your details and try again.";
        final message = friendlyRegisterMessage(raw);
        if (isTransientErrorMessage(raw) ||
            isTransientErrorMessage(message)) {
          showAppError(
            context,
            // C162: sanitized friendly copy; raw server words stay in logs.
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
                        // C162: in-card copy is sanitized — raw 500/mailer
                        // blobs render as the friendly line, never verbatim.
                        if (authState.errorMessage != null) ...[
                          FormErrorSummary(
                            message: friendlyRegisterMessage(
                              authState.errorMessage!,
                            ),
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
                          // C165: new-account hint (was `password`, which
                          // invites the password manager to treat this as a
                          // login field and fight typing with autofill UI).
                          autofillHints: const [AutofillHints.newPassword],
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

                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                key: const Key('register_consent'),
                                value: consentChecked,
                                onChanged: (v) => setState(
                                  () => consentChecked = v ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => consentChecked = !consentChecked,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: inputLabelColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'privacy policy',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: inputLabelColor,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              context.push('/privacy'),
                                      ),
                                      TextSpan(
                                        text:
                                            ' and to being contacted about my account.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: inputLabelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('register_submit'),
                            // C159: submit stays disabled until privacy is accepted.
                            onPressed: authState.isLoading || !consentChecked
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
