// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_user_email_resend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiUserEmailResendResponse _$PostApiUserEmailResendResponseFromJson(
  Map<String, dynamic> json,
) => _PostApiUserEmailResendResponse(
  message: json['message'] as String?,
  codeExpiresAt: json['code_expires_at'] == null
      ? null
      : DateTime.parse(json['code_expires_at'] as String),
);

Map<String, dynamic> _$PostApiUserEmailResendResponseToJson(
  _PostApiUserEmailResendResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code_expires_at': instance.codeExpiresAt?.toIso8601String(),
};
