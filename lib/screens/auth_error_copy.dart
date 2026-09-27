import 'package:dio/dio.dart';

/// Single shared phrasebook for auth error words (C14 creates, C15/C93
/// extend). Screens map the server machine `code` — never render server
/// `message` verbatim. Unknown shapes fall back to generic copy.
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
