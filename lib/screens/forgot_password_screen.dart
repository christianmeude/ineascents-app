import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/models/api_forgot_password_request_body.dart';
import '../config/theme.dart';
import '../src/providers/core_providers.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    child: const Column(
                      children: [
                        AppLogo(),
                        SizedBox(height: 44),
                        // C150: shared with the mobile bottom sheet.
                        ForgotPasswordForm(),
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

/// C150: the forgot-password form without Scaffold/chrome — rendered inside
/// the route above and inside the mobile bottom sheet from login.
class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ConsumerState<ForgotPasswordForm> createState() =>
      _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final emailController = TextEditingController();

  bool _sending = false;
  String? _formError;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  static String? _validateEmail(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  void _snack(String message) {
    // C164: overlay banner on web, legacy toast on mobile.
    showAppNotice(context, message: message);
  }

  /// C93: request a reset code (POST /api/forgot-password). The backend
  /// always answers success — address existence is never revealed — so a
  /// code step follows unconditionally.
  Future<void> _submit() async {
    final emailError = _validateEmail(emailController.text);
    if (emailError != null) {
      setState(() => _formError = emailError);
      return;
    }
    setState(() {
      _sending = true;
      _formError = null;
    });
    try {
      final email = emailController.text.trim();
      await ref.read(apiClientProvider).auth.postApiForgotPassword(
            body: ApiForgotPasswordRequestBody(email: email),
          );
      if (!mounted) return;
      _snack('If that email exists, a code was sent.');
      context.push('/reset-password?email=${Uri.encodeComponent(email)}');
    } on DioException catch (e) {
      setState(() => _formError = authErrorCopy(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // C109: single-source label color (was inline hex).
    final inputLabelColor = isDark
        ? AppTheme.onPrimaryButton
        : AppTheme.primaryButtonBackground;

    // C150: dismiss-lock while busy — back/drag refused mid-request,
    // allowed when idle. Covers both sheet and route.
    return PopScope(
      canPop: !_sending,
      child: Column(
        children: [
          // C93: form-level failure renders in-card.
          if (_formError != null) ...[
            FormErrorSummary(
              message: _formError!,
            ),
            const SizedBox(height: 16),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter your email address to receive a 6-digit reset code.',
              style: GoogleFonts.figtree(
                // C109: single-source helper color (was hex).
                color: isDark
                    ? AppTheme.onPrimaryButton.withValues(
                        alpha: 0.8,
                      )
                    // C45: full-strength plum in light mode —
                    // the 0.8 wash drops to ~4.7:1, below AAA.
                    : AppTheme.primaryButtonBackground,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _InputLabel(text: 'Email', color: inputLabelColor),
          const SizedBox(height: 4),
          CustomTextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              key: const Key('forgot_password_submit'),
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                // C31: plum/cream token both modes.
                backgroundColor:
                    AppTheme.primaryButtonBackground,
                foregroundColor: AppTheme.onPrimaryButton,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _sending
                  ? const SizedBox(
                      // C109: 20px spinner matches login/register.
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        // C31: cream spinner on plum token.
                        color: AppTheme.onPrimaryButton,
                      ),
                    )
                  : Text(
                      'SEND RESET CODE',
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              // C150: pop-or-go — inside the sheet this closes the sheet
              // (login sits underneath); on the pushed route it returns to
              // login; on a deep link with nothing to pop it goes to login.
              // A bare go() would no-op inside the sheet and orphan it.
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/login');
                }
              },
              style: OutlinedButton.styleFrom(
                // C31: plum token (label stays dark-aware below).
                foregroundColor:
                    AppTheme.primaryButtonBackground,
                side: BorderSide(
                  // C109: single-source border (was inline hex).
                  color: isDark
                      ? AppTheme.onPrimaryButton.withValues(
                          alpha: 0.5,
                        )
                      : AppTheme.primaryButtonBackground,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'BACK TO LOGIN',
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
        ],
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
