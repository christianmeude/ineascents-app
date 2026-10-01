// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_forgot_password_request_body.dart';
import '../models/api_login_request_body.dart';
import '../models/api_register_request_body.dart';
import '../models/api_register_resend_request_body.dart';
import '../models/api_register_verify_request_body.dart';
import '../models/api_reset_password_request_body.dart';
import '../models/auth_response.dart';
import '../models/post_api_forgot_password_response.dart';
import '../models/post_api_register_resend_response.dart';
import '../models/post_api_register_response.dart';
import '../models/post_api_reset_password_response.dart';
import '../models/user.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  /// Register a new user.
  ///
  /// Creates a pending user and sends an email verification code. No session is issued until the email is verified.
  @POST('/api/register')
  Future<PostApiRegisterResponse> postApiRegister({
    @Body() required ApiRegisterRequestBody body,
  });

  /// Verify registration email with code.
  ///
  /// Marks the pending user verified. No session is issued; log in afterwards.
  @POST('/api/register/verify')
  Future<User> postApiRegisterVerify({
    @Body() required ApiRegisterVerifyRequestBody body,
  });

  /// Re-send registration verification code.
  ///
  /// Issues a fresh code for a pending registration.
  @POST('/api/register/resend')
  Future<PostApiRegisterResendResponse> postApiRegisterResend({
    @Body() required ApiRegisterResendRequestBody body,
  });

  /// Login user and return token
  @POST('/api/login')
  Future<AuthResponse> postApiLogin({
    @Body() required ApiLoginRequestBody body,
  });

  /// Get authenticated user
  @GET('/api/user')
  Future<User> getApiUser();

  /// Revoke the current session token
  @POST('/api/logout')
  Future<void> postApiLogout();

  /// Send password-reset code.
  ///
  /// Always the same response; address existence is never revealed.
  @POST('/api/forgot-password')
  Future<PostApiForgotPasswordResponse> postApiForgotPassword({
    @Body() required ApiForgotPasswordRequestBody body,
  });

  /// Reset password with code
  @POST('/api/reset-password')
  Future<PostApiResetPasswordResponse> postApiResetPassword({
    @Body() required ApiResetPasswordRequestBody body,
  });
}
