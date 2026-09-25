// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_reset_password_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResetPasswordRequestBody _$ApiResetPasswordRequestBodyFromJson(
  Map<String, dynamic> json,
) => _ApiResetPasswordRequestBody(
  email: json['email'] as String,
  code: json['code'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
);

Map<String, dynamic> _$ApiResetPasswordRequestBodyToJson(
  _ApiResetPasswordRequestBody instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.code,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
};
