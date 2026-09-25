// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_inquiries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostApiInquiriesResponse _$PostApiInquiriesResponseFromJson(
  Map<String, dynamic> json,
) => _PostApiInquiriesResponse(
  data: json['data'] == null
      ? null
      : Inquiry.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostApiInquiriesResponseToJson(
  _PostApiInquiriesResponse instance,
) => <String, dynamic>{'data': instance.data};
