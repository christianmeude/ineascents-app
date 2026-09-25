// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_user_password_change_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiUserPasswordChangeRequestBody _$ApiUserPasswordChangeRequestBodyFromJson(
  Map<String, dynamic> json,
) => _ApiUserPasswordChangeRequestBody(
  currentPassword: json['current_password'] as String,
  code: json['code'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
);

Map<String, dynamic> _$ApiUserPasswordChangeRequestBodyToJson(
  _ApiUserPasswordChangeRequestBody instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'code': instance.code,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
};
