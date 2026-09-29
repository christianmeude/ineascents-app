import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/models/api_forgot_password_request_body.dart';
import '../api/models/api_reset_password_request_body.dart';
import '../config/theme.dart';
import '../src/providers/core_providers.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';
import 'change_password_screen.dart';

// ============================================================================
// RESET PASSWORD SCREEN (C93: wired to backend A8)
// ============================================================================
//
// Second step of forgot-password: the code from POST /api/forgot-password
// plus a new password completes POST /api/reset-password. Success revokes
// all Sanctum tokens server-side, so the customer lands back on /login.

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _sending = false;
  String? _formError;

  /// Fields show inline errors only after user interaction.
  final _touched = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _touch(String key) {
    if (_touched[key] != true) setState(() => _touched[key] = true);
  }

  static String? _emailError(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? get _codeError {
    final code = _codeController.text.trim();
    if (code.isEmpty) return 'Enter the 6-digit code.';
    return ChangePasswordValidators.validateCode(code);
  }

  String? get _newError => ChangePasswordValidators.validateNew(
        _newController.text,
        '',
      );

  String? get _confirmError => ChangePasswordValidators.validateConfirm(
        _confirmController.text,
        _newController.text,
      );

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    setState(() {
      _touched['email'] = true;
      _touched['code'] = true;
      _touched['new'] = true;
      _touched['confirm'] = true;
      _formError = null;
    });
    final emailError = _emailError(_emailController.text);
    if (emailError != null ||
        _codeError != null ||
        _newError != null ||
        _confirmError != null) {
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(apiClientProvider).auth.postApiResetPassword(
            body: ApiResetPasswordRequestBody(
              email: _emailController.text.trim(),
              code: _codeController.text.trim(),
              password: _newController.text,
              passwordConfirmation: _confirmController.text,
            ),
          );
      if (!mounted) return;
      _snack('Password reset.');
      context.go('/login');
    } on DioException catch (e) {
      setState(() => _formError = authErrorCopy(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resend() async {
    final emailError = _emailError(_emailController.text);
    if (emailError != null) {
      setState(() {
        _touched['email'] = true;
        _formError = emailError;
      });
      return;
    }
    setState(() {
      _sending = true;
      _formError = null;
    });
    try {
      await ref.read(apiClientProvider).auth.postApiForgotPassword(
            body: ApiForgotPasswordRequestBody(
              email: _emailController.text.trim(),
            ),
          );
      if (!mounted) return;
      _snack('Code re-sent.');
    } on DioException catch (e) {
      setState(() => _formError = authErrorCopy(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // C110: single-source label color (was inline hex).
    final inputLabelColor = isDark
        ? AppTheme.onPrimaryButton
        : AppTheme.primaryButtonBackground;

    final emailError =
        _touched['email'] == true ? _emailError(_emailController.text) : null;
    final codeError = _touched['code'] == true ? _codeError : null;
    final newError = _touched['new'] == true ? _newError : null;
    final confirmError =
        _touched['confirm'] == true ? _confirmError : null;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let AuthBackground handle background
      body: AuthBackground(
        isDark: isDark,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  // C40: clamp overscroll on mobile (<768px).
                  physics: MobileClampScroll.physicsOf(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 336),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Reset Password',
                            style: GoogleFonts.figtree(
                              color: inputLabelColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter the 6-digit code we emailed you, then choose a new password.',
                            style: GoogleFonts.figtree(
                              // C110: single-source helper color (was hex).
                              color: isDark
                                  ? AppTheme.onPrimaryButton.withValues(
                                      alpha: 0.8,
                                    )
                                  : AppTheme.primaryButtonBackground,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_formError != null) ...[
                          FormErrorSummary(message: _formError!),
                          const SizedBox(height: 16),
                        ],
                        _FieldLabel(text: 'Email', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('reset_password_email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (_) => _touch('email'),
                        ),
                        InlineFieldError(
                          key: const Key('reset_password_email_error'),
                          message: emailError,
                        ),
                        const SizedBox(height: 16),
                        GatedCodeSection(
                          // Post-request step: reached only after the forgot
                          // screen sends the code, so the section is open.
                          codeSent: true,
                          field: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _FieldLabel(
                                  text: '6-digit code',
                                  color: inputLabelColor),
                              const SizedBox(height: 4),
                              CustomTextField(
                                key: const Key('reset_password_code'),
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                hintText: '123456',
                                onChanged: (_) => _touch('code'),
                              ),
                              InlineFieldError(
                                key: const Key('reset_password_code_error'),
                                message: codeError,
                              ),
                            ],
                          ),
                          sending: _sending,
                          onResend: _resend,
                          resendKey: const Key('reset_password_resend'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(text: 'New password', color: inputLabelColor),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('reset_password_new'),
                          controller: _newController,
                          obscureText: _obscureNew,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            // C110: screen-reader label (parity with C108).
                            tooltip: _obscureNew
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                              () => _obscureNew = !_obscureNew,
                            ),
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                          ),
                          onChanged: (_) {
                            _touch('new');
                            if (_touched['confirm'] == true) setState(() {});
                          },
                        ),
                        InlineFieldError(
                          key: const Key('reset_password_new_error'),
                          message: newError,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(
                          text: 'Confirm new password',
                          color: inputLabelColor,
                        ),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const Key('reset_password_confirm'),
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          suffixIcon: IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            // C110: screen-reader label (parity with C108).
                            tooltip: _obscureConfirm
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                          ),
                          onChanged: (_) => _touch('confirm'),
                        ),
                        InlineFieldError(
                          key: const Key('reset_password_confirm_error'),
                          message: confirmError,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('reset_password_submit'),
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
                                    // C110: 20px spinner matches auth screens.
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.onPrimaryButton,
                                    ),
                                  )
                                : Text(
                                    'RESET PASSWORD',
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
                            key: const Key('reset_password_back'),
                            onPressed: () => context.go('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.primaryButtonBackground,
                              side: BorderSide(
                                // C110: single-source border (was inline hex).
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
                                color: isDark
                                    ? AppTheme.onPrimaryButton
                                    : AppTheme.primaryButtonBackground,
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

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _FieldLabel({required this.text, required this.color});

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
