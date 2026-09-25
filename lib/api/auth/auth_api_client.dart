// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_forgot_password_request_body.dart';
import '../models/api_login_request_body.dart';
import '../models/api_register_request_body.dart';
import '../models/api_reset_password_request_body.dart';
import '../models/auth_response.dart';
import '../models/post_api_forgot_password_response.dart';
import '../models/post_api_reset_password_response.dart';
import '../models/user.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  /// Register a new user
  @POST('/api/register')
  Future<AuthResponse> postApiRegister({
    @Body() required ApiRegisterRequestBody body,
  });

  /// Login user and return token
  @POST('/api/login')
  Future<AuthResponse> postApiLogin({
    @Body() required ApiLoginRequestBody body,
  });

  /// Get authenticated user
  @GET('/api/user')
  Future<User> getApiUser();

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
