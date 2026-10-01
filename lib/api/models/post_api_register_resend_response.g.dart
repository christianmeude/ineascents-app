// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_register_resend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiRegisterResendResponse _$PostApiRegisterResendResponseFromJson(
  Map<String, dynamic> json,
) => _PostApiRegisterResendResponse(
  message: json['message'] as String?,
  codeExpiresAt: json['code_expires_at'] == null
      ? null
      : DateTime.parse(json['code_expires_at'] as String),
);

Map<String, dynamic> _$PostApiRegisterResendResponseToJson(
  _PostApiRegisterResendResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code_expires_at': instance.codeExpiresAt?.toIso8601String(),
};
