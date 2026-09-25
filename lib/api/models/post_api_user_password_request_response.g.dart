// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_user_password_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiUserPasswordRequestResponse
_$PostApiUserPasswordRequestResponseFromJson(Map<String, dynamic> json) =>
    _PostApiUserPasswordRequestResponse(
      message: json['message'] as String?,
      codeExpiresAt: json['code_expires_at'] == null
          ? null
          : DateTime.parse(json['code_expires_at'] as String),
    );

Map<String, dynamic> _$PostApiUserPasswordRequestResponseToJson(
  _PostApiUserPasswordRequestResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code_expires_at': instance.codeExpiresAt?.toIso8601String(),
};
