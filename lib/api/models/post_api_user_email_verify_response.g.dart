// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_user_email_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiUserEmailVerifyResponse _$PostApiUserEmailVerifyResponseFromJson(
  Map<String, dynamic> json,
) => _PostApiUserEmailVerifyResponse(
  data: json['data'] == null
      ? null
      : User.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostApiUserEmailVerifyResponseToJson(
  _PostApiUserEmailVerifyResponse instance,
) => <String, dynamic>{'data': instance.data};
