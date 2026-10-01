import 'package:dio/dio.dart';

import '../widgets/inline_errors.dart' show registerVerificationMailCopy;

/// Single shared phrasebook for auth error words (C14 creates, C15/C93
/// extend). Screens map the server machine `code` — never render server
/// `message` verbatim. Unknown shapes fall back to generic copy.
///
/// C162: transient/500 server failures during registration (mailer down)
/// map to [registerVerificationMailCopy] — short friendly copy with Retry,
/// zero raw `stream_socket`/exception text on screen.
String authErrorCopy(DioException e, {Map<String, Object?>? data}) {
  final body = data ??
      (e.response?.data is Map<String, Object?>
          ? e.response!.data as Map<String, Object?>
          : null);
  final code = body?['code']?.toString();

  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    return 'Could not connect to the server. Please check your internet connection.';
  }
  if (e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'The request is taking too long. Please try again.';
  }

  // C162: mailer-down 500 — never leak raw server words. The status
  // gate carries 5xx; the text gate catches mailer/socket blobs that
  // arrive without a status (or wrapped in a 200 body). Note: Dio's own
  // badResponse message always contains "This exception was thrown",
  // so a bare `exception` match would hijack every mapped 4xx code —
  // only mail-specific markers qualify here.
  final status = e.response?.statusCode;
  if (status != null && status >= 500) {
    return registerVerificationMailCopy;
  }
  final msgLower = body?['message']?.toString().toLowerCase() ?? '';
  final errLower = e.message?.toLowerCase() ?? '';
  final looksMail = msgLower.contains('stream_socket') ||
      msgLower.contains('mailer') ||
      msgLower.contains('smtp') ||
      errLower.contains('stream_socket') ||
      errLower.contains('mailer') ||
      errLower.contains('smtp') ||
      errLower.contains('500');
  if (looksMail) {
    return registerVerificationMailCopy;
  }

  switch (code) {
    case 'EMAIL_TAKEN':
      return 'That email is already in use. Try another.';
    case 'EMAIL_CODE_MISMATCH':
      final left = body?['attempts_left'];
      final tries = left is int ? '$left ${left == 1 ? 'try' : 'tries'}' : 'a few tries';
      return "That code doesn't match. You have $tries left.";
    case 'EMAIL_CODE_EXPIRED':
      return 'That code expired. Request a new one.';
    case 'EMAIL_CODE_LOCKED':
      return 'Too many wrong tries. Request a new code.';
    case 'EMAIL_CODE_RESEND_TOO_SOON':
      return 'Please wait a minute, then resend the code.';
    case 'EMAIL_CHANGE_NONE':
      return 'No code requested yet. Save your new email first.';
    case 'CURRENT_PASSWORD_WRONG':
      return 'Your current password is incorrect.';
    case 'PASSWORD_CHANGE_NONE':
      return 'No code requested yet. Request a code first.';
    case 'PASSWORD_RESET_NONE':
      return 'No code requested yet. Request a code first.';
    case 'REGISTER_NONE':
      return 'No pending verification. Register again.';
    case 'EMAIL_NOT_VERIFIED':
      return 'Verify your email first. Check your inbox for the code.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// C162: maps a provider-facing register error string to display copy.
/// Raw mailer-down shapes (500, mailer/socket/smtp blobs) become
/// [registerVerificationMailCopy]; already-friendly transient copy and
/// validation copy pass through untouched so Retry gating (via
/// `isTransientErrorMessage`) stays intact. Note: provider strings can
/// be Dio's own "This exception was thrown ... status code of 422"
/// wrapper, so a bare `exception` match must NOT qualify — only
/// mail-specific markers (or a 500) rewrite.
String friendlyRegisterMessage(String raw) {
  if (raw == registerVerificationMailCopy) return raw;
  final m = raw.toLowerCase();
  // Already-friendly transient copy passes through verbatim.
  if (m.contains('could not connect') ||
      m.contains('taking too long') ||
      m.contains('check your internet') ||
      m.contains('check your connection') ||
      m.contains('verification email. please retry')) {
    return raw;
  }
  if (m.contains('stream_socket') ||
      m.contains('mailer') ||
      m.contains('smtp') ||
      m.contains('500') ||
      (m.contains('socket') && m.contains('ssl')) ||
      (m.contains('server error') && m.contains('500'))) {
    return registerVerificationMailCopy;
  }
  return raw;
}
