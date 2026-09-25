// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_inquiries_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiInquiriesRequestBody _$ApiInquiriesRequestBodyFromJson(
  Map<String, dynamic> json,
) => _ApiInquiriesRequestBody(
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  message: json['message'] as String?,
);

Map<String, dynamic> _$ApiInquiriesRequestBodyToJson(
  _ApiInquiriesRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'event_date': instance.eventDate?.toIso8601String(),
  'message': instance.message,
};
