import 'package:dio/dio.dart';

/// C95 per-ticket request file: registration code-gate endpoints.
///
/// The generated `lib/api/**` client has no register verify/resend methods
/// (backend A11), and hand-edits to codegen are forbidden — so the
/// verify-email screen calls these Dio helpers instead.
Future<void> postRegisterVerify(
  Dio dio, {
  required String email,
  required String code,
}) async {
  await dio.post('/api/register/verify', data: {'email': email, 'code': code});
}

Future<void> postRegisterResend(Dio dio, {required String email}) async {
  await dio.post('/api/register/resend', data: {'email': email});
}
