import 'package:flutter/material.dart';

import '../config/theme.dart';

/// C52: shared inline error surfaces. The nav-level [MaterialBanner] is
/// gone — validation renders inline at the field/card level, form-level
/// failures render in-card via [FormErrorSummary], and only transient
/// failures surface a toast with Retry (see `error_banner.dart`).
///
/// Both widgets wrap (never clip) at 360px+: the message always sits in
/// an [Expanded]/[Flexible] with [softWrap], and the summary stacks its
/// Retry below the copy so the row can never squeeze.

/// Heuristic over provider-facing copy: true for connectivity/timeout/
/// server failures (safe to retry), false for validation copy (fix the
/// form instead). Callers pass the result as `transient` to
/// [showAppError] and as `onRetry` to [FormErrorSummary].
///
/// C162: register mailer-down copy — transient/500 server failures during
/// registration surface this short friendly line (with Retry) instead of
/// raw `stream_socket`/exception text.
const registerVerificationMailCopy =
    'Something went wrong sending the verification email. Please retry.';

bool isTransientErrorMessage(String message) {
  final m = message.toLowerCase();
  // Note (C162): no bare `exception` match — Dio's own badResponse
  // message always contains "This exception was thrown", which would
  // flag every mapped 4xx (validation) failure as retryable. Raw
  // mailer blobs still match via socket/mailer/500/server-error.
  return m.contains('could not connect') ||
      m.contains('taking too long') ||
      m.contains('check your internet') ||
      m.contains('check your connection') ||
      m.contains('connection') ||
      m.contains('network') ||
      m.contains('timeout') ||
      m.contains('timed out') ||
      m.contains('server error') ||
      m.contains('internal server error') ||
      m.contains('unexpected network') ||
      m.contains('socket') ||
      m.contains('stream_socket') ||
      m.contains('mailer') ||
      m.contains('verification email') ||
      m.contains('500');
}

/// C52: dark-aware error text (mirrors the former per-screen values).
Color inlineErrorColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFF0A6B0)
    : AppTheme.errorOnLight;

/// C52: field-level error line. Null [message] renders nothing so callers
/// can wire it straight to a validator without branching.
class InlineFieldError extends StatelessWidget {
  final String? message;

  const InlineFieldError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    final color = inlineErrorColor(context);
    return Semantics(
      liveRegion: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, left: 20, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message!,
                style: TextStyle(color: color, fontSize: 12, height: 1.4),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// C52: in-card summary for form-level errors. Renders the [messages]
/// (or single [message]) as a wrapping list; [onRetry] adds a Retry
/// button — pass it only for transient failures.
class FormErrorSummary extends StatelessWidget {
  final List<String> messages;
  final VoidCallback? onRetry;
  final String retryLabel;

  FormErrorSummary({
    super.key,
    this.messages = const [],
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String? message;

  List<String> get _all => messages.isNotEmpty
      ? messages
      : (message != null && message!.isNotEmpty ? [message!] : const []);

  @override
  Widget build(BuildContext context) {
    final all = _all;
    if (all.isEmpty) return const SizedBox.shrink();
    final color = inlineErrorColor(context);
    return Semantics(
      liveRegion: true,
      label: all.join(' '),
      child: Container(
        key: const Key('form_error_summary'),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < all.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == all.length - 1 ? 0 : 4,
                          ),
                          child: Text(
                            all[i],
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            softWrap: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('form_error_retry'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(retryLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(48, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
