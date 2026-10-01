// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inquiry _$InquiryFromJson(Map<String, dynamic> json) => _Inquiry(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  message: json['message'] as String?,
  status: json['status'] as String?,
  archived: json['archived'] as bool?,
  consentPrivacyVersion: json['consent_privacy_version'] as String?,
  consentedAt: json['consented_at'] == null
      ? null
      : DateTime.parse(json['consented_at'] as String),
);

Map<String, dynamic> _$InquiryToJson(_Inquiry instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'event_date': instance.eventDate?.toIso8601String(),
  'message': instance.message,
  'status': instance.status,
  'archived': instance.archived,
  'consent_privacy_version': instance.consentPrivacyVersion,
  'consented_at': instance.consentedAt?.toIso8601String(),
};
