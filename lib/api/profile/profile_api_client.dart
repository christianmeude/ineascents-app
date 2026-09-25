// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_user_email_verify_request_body.dart';
import '../models/api_user_password_change_request_body.dart';
import '../models/api_user_request_body.dart';
import '../models/post_api_user_email_resend_response.dart';
import '../models/post_api_user_email_verify_response.dart';
import '../models/post_api_user_password_change_response.dart';
import '../models/post_api_user_password_request_response.dart';
import '../models/put_api_user_response.dart';

part 'profile_api_client.g.dart';

@RestApi()
abstract class ProfileApiClient {
  factory ProfileApiClient(Dio dio, {String? baseUrl}) = _ProfileApiClient;

  /// Update profile name, request email change.
  ///
  /// Name saves inline. A new email issues a verification code to that address; the login email swaps only after verification.
  @PUT('/api/user')
  Future<PutApiUserResponse> putApiUser({
    @Body() required ApiUserRequestBody body,
  });

  /// Send password-change code to current email
  @POST('/api/user/password/request')
  Future<PostApiUserPasswordRequestResponse> postApiUserPasswordRequest();

  /// Change password with current password + code
  @POST('/api/user/password/change')
  Future<PostApiUserPasswordChangeResponse> postApiUserPasswordChange({
    @Body() required ApiUserPasswordChangeRequestBody body,
  });

  /// Verify email change with code
  @POST('/api/user/email/verify')
  Future<PostApiUserEmailVerifyResponse> postApiUserEmailVerify({
    @Body() required ApiUserEmailVerifyRequestBody body,
  });

  /// Re-send email change code
  @POST('/api/user/email/resend')
  Future<PostApiUserEmailResendResponse> postApiUserEmailResend();
}
