// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_reset_password_request_body.freezed.dart';
part 'api_reset_password_request_body.g.dart';

@Freezed()
abstract class ApiResetPasswordRequestBody with _$ApiResetPasswordRequestBody {
  const factory ApiResetPasswordRequestBody({
    required String email,
    required String code,
    required String password,
    @JsonKey(name: 'password_confirmation')
    required String passwordConfirmation,
  }) = _ApiResetPasswordRequestBody;
  
  factory ApiResetPasswordRequestBody.fromJson(Map<String, Object?> json) => _$ApiResetPasswordRequestBodyFromJson(json);
}
