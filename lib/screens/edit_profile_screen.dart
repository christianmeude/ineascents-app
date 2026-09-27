import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/api_user_email_verify_request_body.dart';
import '../api/models/api_user_request_body.dart';
import '../api/models/user.dart';
import '../providers/index.dart';
import '../src/providers/core_providers.dart';
import '../widgets/index.dart';
import 'auth_error_copy.dart';

// ============================================================================
// EDIT PROFILE SCREEN (C14: wired to backend A6)
// ============================================================================
//
// - Name saves inline via PUT /api/user.
// - New email: submit requests a code (PUT with email), then submit with the
//   code verifies it (POST /api/user/email/verify). The current address stays
//   the login until the swap completes.
// - Error words come from the shared auth phrasebook (auth_error_copy.dart).

/// Name must be non-blank.
String? validateProfileName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter your name';
  if (value.trim().length < 2) return 'Name must be at least 2 characters';
  return null;
}

/// New email is optional (blank keeps the current login); when filled it
/// must be a valid address awaiting code verification.
String? validateProfileEmail(String? value) {
  final text = value == null ? '' : value.trim();
  if (text.isEmpty) return null;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Verification code: required when a code was requested, otherwise
/// optional; whenever filled it must be 6 digits.
String? validateProfileCode(String? value, bool codeRequested) {
  final code = value == null ? '' : value.trim();
  if (code.isEmpty) {
    if (codeRequested) return 'Enter the 6-digit code';
    return null;
  }
  if (!RegExp(r'^\d{6}$').hasMatch(code)) return 'Code must be 6 digits';
  return null;
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;

  bool _sending = false;
  bool _codeSent = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _done(String message, User? user) async {
    if (user != null) {
      await ref.read(authProvider.notifier).updateUser(user);
    }
    if (!mounted) return;
    _snack(message);
    Navigator.of(context).maybePop();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _formError = null;
    });
    try {
      final api = ref.read(apiClientProvider).profile;
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final code = _codeController.text.trim();

      if (email.isEmpty) {
        final res = await api.putApiUser(body: ApiUserRequestBody(name: name));
        await _done('Profile updated.', res.data);
        return;
      }

      if (!_codeSent || code.isEmpty) {
        final res = await api.putApiUser(
          body: ApiUserRequestBody(name: name, email: email),
        );
        if (res.emailPending != null) {
          setState(() => _codeSent = true);
          _snack('Code sent to $email. Enter it below.');
          return;
        }
        await _done('Profile updated.', res.data);
        return;
      }

      final verified = await api.postApiUserEmailVerify(
        body: ApiUserEmailVerifyRequestBody(code: code),
      );
      await _done('Email updated.', verified.data);
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
      await ref.read(apiClientProvider).profile.postApiUserEmailResend();
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
    final cardBg = CardSurfaces.cardBg(context);
    final cardBorder = CardSurfaces.cardBorder(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          // C40: clamp overscroll on mobile (<768px); SDK default
          // (stretch Android / bounce iOS) displaced content past edge.
          physics: MobileClampScroll.physicsOf(context),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_formError != null) ...[
                        FormErrorSummary(message: _formError!),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        key: const Key('edit_profile_name'),
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: validateProfileName,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('edit_profile_email'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'New email',
                          helperText:
                              'Your current email stays your login until a '
                              'new one is verified.',
                        ),
                        validator: validateProfileEmail,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      GatedCodeSection(
                        codeSent: _codeSent,
                        field: TextFormField(
                          key: const Key('edit_profile_code'),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          decoration: const InputDecoration(
                            labelText: 'Verification code',
                          ),
                          validator: (value) =>
                              validateProfileCode(value, _codeSent),
                        ),
                        sending: _sending,
                        onResend: _resend,
                        resendKey: const Key('edit_profile_resend'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          key: const Key('edit_profile_submit'),
                          onPressed: _sending ? null : _submit,
                          child: Text(_sending ? 'Saving…' : 'Save changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
