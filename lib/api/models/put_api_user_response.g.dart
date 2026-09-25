// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PutApiUserResponse _$PutApiUserResponseFromJson(Map<String, dynamic> json) =>
    _PutApiUserResponse(
      data: json['data'] == null
          ? null
          : User.fromJson(json['data'] as Map<String, dynamic>),
      emailPending: json['email_pending'] as String?,
      codeExpiresAt: json['code_expires_at'] == null
          ? null
          : DateTime.parse(json['code_expires_at'] as String),
    );

Map<String, dynamic> _$PutApiUserResponseToJson(_PutApiUserResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'email_pending': instance.emailPending,
      'code_expires_at': instance.codeExpiresAt?.toIso8601String(),
    };
