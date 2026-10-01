import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'inline_errors.dart';
import 'micro_interactions.dart';

/// C164 test hook: forces the web overlay-banner path in widget tests
/// where [kIsWeb] is always false on the VM. Null (default) uses the
/// real `kIsWeb` gate. Never set outside tests.
@visibleForTesting
bool? debugForceWebBanner;

/// C52: app-wide error display is toast-only on every width. The wide
/// (>=768px) nav-level [MaterialBanner] is gone — validation errors
/// render inline at the field/card level ([InlineFieldError],
/// [FormErrorSummary]) and only transient failures surface here, with
/// Retry. Friendly copy passes through untouched; raw errors stay
/// in logs, never on screen.
///
/// [transient] gates the Retry affordance. When omitted, the
/// [isTransientErrorMessage] heuristic over [message] decides — so a
/// caller that passes `onRetry` for a validation message gets no
/// Retry button. Pass `transient: true` explicitly to force it.
void showAppError(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
  String retryLabel = 'Retry',
  String? actionLabel,
  VoidCallback? onAction,
  bool? transient,
}) {
  final isTransient = transient ?? isTransientErrorMessage(message);
  // C162: never render raw server/exception blobs in the toast. Raw
  // mailer/socket shapes fall back to the register-friendly line when
  // they look mail-related, else to the generic line. Already-friendly
  // copy passes through untouched.
  final displayMessage = _sanitizedToastMessage(message);
  final hasRetry = onRetry != null && isTransient;
  final hasAction = onAction != null && actionLabel != null;
  // C164: zero SnackBar on web — overlay banner instead (same copy,
  // same Retry gating, plum/cream tokens).
  if (debugForceWebBanner ?? kIsWeb) {
    _showWebBanner(
      context,
      message: displayMessage,
      actionLabel: hasAction || hasRetry
          ? (hasAction ? actionLabel : retryLabel)
          : null,
      onAction: hasAction || hasRetry
          ? () {
              _hideWebBanner();
              (hasAction ? onAction : onRetry)?.call();
            }
          : null,
      sticky: hasRetry || hasAction,
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearMaterialBanners()
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // C31: plum/cream token both modes.
        backgroundColor: AppTheme.primaryButtonBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Retry keeps the toast up longer so it stays tappable.
        duration: Duration(seconds: (hasRetry || hasAction) ? 8 : 4),
        // C52: plain wrapping text — no Row/IconButton squeeze, so a
        // long message never overflows at 360px even with an action.
        // C68: slide-in entry on the toast content (transform-only, no
        // layout shift; instant when reduced-motion is on). Tokens stay
        // C31 plum/cream — no restyle.
        content: ToastEntry(
          child: Text(
            displayMessage,
            style: const TextStyle(color: AppTheme.onPrimaryButton),
            softWrap: true,
          ),
        ),
        // C52: one action slot — extra action wins, else retry, and
        // retry only for transient failures. Validation copy never
        // gets a Retry button here (it renders in-card instead).
        action: hasAction || hasRetry
            ? SnackBarAction(
                key: Key(hasAction ? 'app_error_action' : 'app_error_retry'),
                label: actionLabel ?? retryLabel,
                // C31: cream action label on the plum token.
                textColor: AppTheme.onPrimaryButton,
                onPressed: () {
                  messenger.clearSnackBars();
                  (hasAction ? onAction : onRetry)?.call();
                },
              )
            : null,
      ),
    );
}

/// C52: clears any visible app error toast (plus legacy banners).
/// C164: also clears the web overlay banner.
void hideAppError(BuildContext context) {
  _hideWebBanner();
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..clearMaterialBanners();
}

/// C164: success/info notices share the web overlay banner (no Retry
/// gating) so the 5 `_snack` call sites render zero SnackBar on web.
/// Mobile keeps the legacy SnackBar path untouched.
void showAppNotice(BuildContext context, {required String message}) {
  if (debugForceWebBanner ?? kIsWeb) {
    _showWebBanner(context, message: message, sticky: false);
    return;
  }
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryButtonBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        content: ToastEntry(
          child: Text(
            message,
            style: const TextStyle(color: AppTheme.onPrimaryButton),
            softWrap: true,
          ),
        ),
      ),
    );
}

OverlayEntry? _webBannerEntry;
int _webBannerGeneration = 0;
Timer? _webBannerTimer;

/// C164: top-center overlay banner — the web replacement for SnackBar.
/// Plum/cream tokens, message + optional action + dismiss. `sticky`
/// banners persist until dismissed; others auto-dismiss like a toast.
void _showWebBanner(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  required bool sticky,
}) {
  _hideWebBanner();
  final generation = ++_webBannerGeneration;
  final entry = OverlayEntry(
    builder: (overlayContext) => Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: AppTheme.primaryButtonBackground,
            borderRadius: BorderRadius.circular(12),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      message,
                      key: const Key('web_banner_message'),
                      style: const TextStyle(
                        color: AppTheme.onPrimaryButton,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      key: const Key('web_banner_action'),
                      onPressed: onAction,
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: AppTheme.onPrimaryButton,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  IconButton(
                    key: const Key('web_banner_dismiss'),
                    tooltip: 'Dismiss',
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _hideWebBanner,
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.onPrimaryButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _webBannerEntry = entry;
  Overlay.of(context).insert(entry);
  if (!sticky) {
    _webBannerTimer = Timer(const Duration(seconds: 4), () {
      if (generation == _webBannerGeneration) _hideWebBanner();
    });
  }
}

void _hideWebBanner() {
  _webBannerTimer?.cancel();
  _webBannerTimer = null;
  _webBannerEntry?.remove();
  _webBannerEntry = null;
  _webBannerGeneration++;
}

/// C162: toast-level guard against raw server/exception blobs. Returns
/// [message] verbatim unless it looks like a raw failure (socket/
/// stack/mailer shapes, or an `exception` blob tied to mail/socket/500
/// markers), in which case it falls back to the register-friendly line
/// for mail-related blobs or the generic line otherwise. Friendly and
/// validation copy never rewrite — note Dio's own badResponse wrapper
/// ("This exception was thrown ... status code of 422") must pass
/// through, so a bare `exception` match never qualifies alone.
String _sanitizedToastMessage(String message) {
  if (message == registerVerificationMailCopy) return message;
  final m = message.toLowerCase();
  final looksMail = m.contains('stream_socket') ||
      m.contains('mailer') ||
      m.contains('smtp') ||
      m.contains('verification') ||
      m.contains('ssl') ||
      m.contains('500');
  final hasException =
      m.contains('exception') || m.contains('dioexception');
  final isRaw = m.contains('stream_socket') ||
      m.contains('socketexception') ||
      m.contains('dioexception') ||
      m.contains('stack trace') ||
      m.contains('#0 ') ||
      m.contains('smtp') ||
      (hasException && looksMail) ||
      (m.contains('mailer') && !m.contains('verification email'));
  if (!isRaw) return message;
  return looksMail
      ? registerVerificationMailCopy
      : 'Something went wrong. Please try again.';
}
