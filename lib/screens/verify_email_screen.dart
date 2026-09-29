import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../src/providers/core_providers.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';
import 'change_password_screen.dart';
import 'verify_email_api.dart';

// ============================================================================
// VERIFY EMAIL SCREEN (C95: wired to backend A11)
// ============================================================================
//
// Second step of registration: POST /api/register already created the
// pending User and emailed a 6-digit code (zero token issued), so this
// screen opens with the code gate visible. Verifying marks the email
// verified — still no token — and the customer lands on /login with a
// verified notice, then logs in to receive the session.

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();

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

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    setState(() {
      _touched['email'] = true;
      _touched['code'] = true;
      _formError = null;
    });
    final emailError = _emailError(_emailController.text);
    if (emailError != null || _codeError != null) {
      return;
    }
    setState(() => _sending = true);
    try {
      await postRegisterVerify(
        ref.read(dioClientProvider).dio,
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );
      if (!mounted) return;
      _snack('Email verified. Log in.');
      context.go('/login?verified=1');
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
      await postRegisterResend(
        ref.read(dioClientProvider).dio,
        email: _emailController.text.trim(),
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
    // C111: single-source label color (was inline hex).
    final inputLabelColor = isDark
        ? AppTheme.onPrimaryButton
        : AppTheme.primaryButtonBackground;

    final emailError =
        _touched['email'] == true ? _emailError(_emailController.text) : null;
    final codeError = _touched['code'] == true ? _codeError : null;

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
                            'Verify Email',
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
                            'Enter the 6-digit code we emailed you to finish registration.',
                            style: GoogleFonts.figtree(
                              // C111: single-source helper color (was hex).
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
                          key: const Key('verify_email_email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (_) => _touch('email'),
                        ),
                        InlineFieldError(
                          key: const Key('verify_email_email_error'),
                          message: emailError,
                        ),
                        const SizedBox(height: 16),
                        GatedCodeSection(
                          // Post-request step: register already sent the
                          // code, so the section is open.
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
                                key: const Key('verify_email_code'),
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                hintText: '123456',
                                onChanged: (_) => _touch('code'),
                              ),
                              InlineFieldError(
                                key: const Key('verify_email_code_error'),
                                message: codeError,
                              ),
                            ],
                          ),
                          sending: _sending,
                          onResend: _resend,
                          resendKey: const Key('verify_email_resend'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('verify_email_submit'),
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
                                    // C111: 20px spinner matches auth screens.
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.onPrimaryButton,
                                    ),
                                  )
                                : Text(
                                    'VERIFY EMAIL',
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
                            key: const Key('verify_email_back'),
                            onPressed: () => context.go('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.primaryButtonBackground,
                              side: BorderSide(
                                // C111: single-source border (was inline hex).
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
