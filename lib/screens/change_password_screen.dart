import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/models/api_user_password_change_request_body.dart';
import '../config/theme.dart';
import '../src/providers/core_providers.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';

/// C15 (wired to backend A7):
/// change-password form at `/profile/password`. First submit requests a
/// code (POST /api/user/password/request); second submit changes the
/// password (POST /api/user/password/change). Success keeps the current
/// session (other Sanctum tokens are revoked server-side).
///
/// Field contracts mirror backend A7:
/// - current  -> `current_password` (wrong current rejected)
/// - new      -> `password` (min 8)
/// - confirm  -> `password_confirmation` (must match `password`)
/// - code     -> `code` (6 digits; required once a code was requested)
class ChangePasswordValidators {
  static String? validateCurrent(String value) {
    if (value.isEmpty) return 'Enter your current password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? validateNew(String value, String current) {
    if (value.isEmpty) return 'Enter a new password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (current.isNotEmpty && value == current) {
      return 'New password must differ from the current password.';
    }
    return null;
  }

  static String? validateConfirm(String value, String next) {
    if (value.isEmpty) return 'Confirm your new password.';
    if (value != next) return 'Passwords do not match.';
    return null;
  }

  static String? validateCode(String value) {
    if (value.isEmpty) return 'Enter the 6-digit code.';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Code must be 6 digits.';
    }
    return null;
  }
}

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  /// Shared flow blurb — route header and mobile sheet subtitle.
  static const flowDescription =
      'Enter your current password, choose a new one, and confirm the 6-digit code.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // C149: header + card mirror Edit Profile (uniformity); the form
    // itself is shared with the mobile sheet.
    // C120: single-source text colors (were inline hex).
    final textColor = CardSurfaces.title(context);
    final secondaryTextColor = CardSurfaces.body(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Change Password'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // C40: clamp overscroll on mobile (<768px); SDK default
            // (stretch Android / bounce iOS) displaced content past edge.
            physics: MobileClampScroll.physicsOf(context),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    // C120: theme ramp (explicit Figtree).
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ChangePasswordScreen.flowDescription,
                    // C120: theme ramp (explicit Figtree).
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CardSurfaces.cardBg(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: CardSurfaces.cardBorder(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CardSurfaces.plum.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const ChangePasswordForm(),
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

/// C149: the change-password form without Scaffold/chrome — rendered inside
/// the route card above and inside the mobile bottom sheet.
class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ConsumerState<ChangePasswordForm> createState() =>
      _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _sending = false;
  bool _codeSent = false;
  String? _formError;

  /// Fields show inline errors only after user interaction.
  final _touched = <String, bool>{};

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _touch(String key) {
    if (_touched[key] != true) setState(() => _touched[key] = true);
  }

  String? get _currentError =>
      ChangePasswordValidators.validateCurrent(_currentController.text);

  String? get _newError => ChangePasswordValidators.validateNew(
        _newController.text,
        _currentController.text,
      );

  String? get _confirmError => ChangePasswordValidators.validateConfirm(
        _confirmController.text,
        _newController.text,
      );

  /// The code is required only once a code was requested; a half-typed
  /// code still reports inline so typos surface early.
  String? get _codeError {
    final code = _codeController.text;
    if (!_codeSent && code.isEmpty) return null;
    return ChangePasswordValidators.validateCode(code);
  }

  void _snack(String message) {
    // C164: overlay banner on web, legacy toast on mobile.
    showAppNotice(context, message: message);
  }

  Future<void> _done(String message) async {
    // C149: clear the busy flag BEFORE popping — the PopScope below
    // (canPop: !_sending) would veto the success pop otherwise.
    if (mounted) setState(() => _sending = false);
    if (!mounted) return;
    _snack(message);
    Navigator.of(context).maybePop();
  }

  Future<void> _submit() async {
    setState(() {
      _touched['current'] = true;
      _touched['new'] = true;
      _touched['confirm'] = true;
      _touched['code'] = true;
      _formError = null;
    });
    if (_currentError != null ||
        _newError != null ||
        _confirmError != null ||
        _codeError != null) {
      return;
    }
    setState(() => _sending = true);
    try {
      final api = ref.read(apiClientProvider).profile;
      if (!_codeSent) {
        await api.postApiUserPasswordRequest();
        if (!mounted) return;
        setState(() => _codeSent = true);
        _snack('Code sent to your email. Enter it below.');
        return;
      }
      await api.postApiUserPasswordChange(
        body: ApiUserPasswordChangeRequestBody(
          currentPassword: _currentController.text,
          code: _codeController.text.trim(),
          password: _newController.text,
          passwordConfirmation: _confirmController.text,
        ),
      );
      if (!mounted) return;
      await _done('Password changed.');
    } on DioException catch (e) {
      setState(() => _formError = authErrorCopy(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _sending = true;
      _formError = null;
    });
    try {
      await ref.read(apiClientProvider).profile.postApiUserPasswordRequest();
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
    final currentError =
        _touched['current'] == true ? _currentError : null;
    final newError = _touched['new'] == true ? _newError : null;
    final confirmError =
        _touched['confirm'] == true ? _confirmError : null;
    final codeError = _touched['code'] == true ? _codeError : null;

    // C149: dismiss-lock while busy (grill Q4) — back/drag refused
    // mid-request, allowed when idle. Covers both sheet and route.
    return PopScope(
      canPop: !_sending,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_formError != null) ...[
            FormErrorSummary(message: _formError!),
            const SizedBox(height: 12),
          ],
          TextFormField(
            key: const Key('change_password_current'),
            controller: _currentController,
            obscureText: _obscureCurrent,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Current password',
              suffixIcon: IconButton(
                mouseCursor: SystemMouseCursors.click,
                // C120: screen-reader label (parity C108/C110).
                tooltip:
                    _obscureCurrent ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
            ),
            onChanged: (_) => _touch('current'),
          ),
          InlineFieldError(
            key: const Key('change_password_current_error'),
            message: currentError,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('change_password_new'),
            controller: _newController,
            obscureText: _obscureNew,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                mouseCursor: SystemMouseCursors.click,
                // C120: screen-reader label (parity C108/C110).
                tooltip: _obscureNew ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscureNew = !_obscureNew),
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
            ),
            onChanged: (_) {
              _touch('new');
              if (_touched['confirm'] == true) setState(() {});
            },
          ),
          InlineFieldError(
            key: const Key('change_password_new_error'),
            message: newError,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('change_password_confirm'),
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              suffixIcon: IconButton(
                mouseCursor: SystemMouseCursors.click,
                // C120: screen-reader label (parity C108/C110).
                tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
            ),
            onChanged: (_) => _touch('confirm'),
          ),
          InlineFieldError(
            key: const Key('change_password_confirm_error'),
            message: confirmError,
          ),
          const SizedBox(height: 16),
          GatedCodeSection(
            codeSent: _codeSent,
            field: TextFormField(
              key: const Key('change_password_code'),
              controller: _codeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(
                labelText: '6-digit code',
                hintText: '123456',
              ),
              onChanged: (_) => _touch('code'),
            ),
            sending: _sending,
            onResend: _resend,
            resendKey: const Key('change_password_resend'),
          ),
          InlineFieldError(
            key: const Key('change_password_code_error'),
            message: codeError,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              key: const Key('change_password_submit'),
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryButtonBackground,
                foregroundColor: AppTheme.onPrimaryButton,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              // C120: spinner + label parity with auth screens.
              child: _sending
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            // C31 parity: cream on plum.
                            color: AppTheme.onPrimaryButton,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Changing…',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'CHANGE PASSWORD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
