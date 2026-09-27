import 'package:flutter/material.dart';

/// Shared gate for verification-code entry: the code [field] plus the resend
/// row render only after a code was requested ([codeSent]). Screens pass
/// their own field subtree so per-screen styling, keys, and validation stay
/// intact; the gating rule and the resend layout stay unified here.
class GatedCodeSection extends StatelessWidget {
  const GatedCodeSection({
    super.key,
    required this.codeSent,
    required this.field,
    required this.sending,
    required this.onResend,
    required this.resendKey,
  });

  /// True once the code request succeeded. False hides field + resend.
  final bool codeSent;

  /// The screen's code field subtree (label, input, inline error as needed).
  final Widget field;

  /// Disables resend while a request is in flight.
  final bool sending;

  final VoidCallback? onResend;

  final Key resendKey;

  @override
  Widget build(BuildContext context) {
    if (!codeSent) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            key: resendKey,
            onPressed: sending ? null : onResend,
            child: const Text('Resend code'),
          ),
        ),
      ],
    );
  }
}
