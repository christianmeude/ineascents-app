// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiRegisterResponse _$PostApiRegisterResponseFromJson(
  Map<String, dynamic> json,
) => _PostApiRegisterResponse(
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  message: json['message'] as String?,
  codeExpiresAt: json['code_expires_at'] == null
      ? null
      : DateTime.parse(json['code_expires_at'] as String),
);

Map<String, dynamic> _$PostApiRegisterResponseToJson(
  _PostApiRegisterResponse instance,
) => <String, dynamic>{
  'user': instance.user,
  'message': instance.message,
  'code_expires_at': instance.codeExpiresAt?.toIso8601String(),
};
