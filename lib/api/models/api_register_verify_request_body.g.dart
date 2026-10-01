// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_register_verify_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiRegisterVerifyRequestBody _$ApiRegisterVerifyRequestBodyFromJson(
  Map<String, dynamic> json,
) => _ApiRegisterVerifyRequestBody(
  email: json['email'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$ApiRegisterVerifyRequestBodyToJson(
  _ApiRegisterVerifyRequestBody instance,
) => <String, dynamic>{'email': instance.email, 'code': instance.code};
