// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_bookings_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiBookingsRequestBody _$ApiBookingsRequestBodyFromJson(
  Map<String, dynamic> json,
) => _ApiBookingsRequestBody(
  packageId: (json['package_id'] as num).toInt(),
  customerName: json['customer_name'] as String,
  customerEmail: json['customer_email'] as String,
  pax: (json['pax'] as num).toInt(),
  eventDate: DateTime.parse(json['event_date'] as String),
  venueAddress: json['venue_address'] as String,
  paymentMethod: PaymentMethod.fromJson(json['payment_method'] as String),
  consentPrivacyVersion: json['consent_privacy_version'] as String,
  customerPhone: json['customer_phone'] as String?,
  eventTime: json['event_time'] as String?,
  scentIds: (json['scent_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ApiBookingsRequestBodyToJson(
  _ApiBookingsRequestBody instance,
) => <String, dynamic>{
  'package_id': instance.packageId,
  'customer_name': instance.customerName,
  'customer_email': instance.customerEmail,
  'pax': instance.pax,
  'event_date': instance.eventDate.toIso8601String(),
  'venue_address': instance.venueAddress,
  'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'consent_privacy_version': instance.consentPrivacyVersion,
  'customer_phone': instance.customerPhone,
  'event_time': instance.eventTime,
  'scent_ids': instance.scentIds,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.online: 'online',
  PaymentMethod.cash: 'cash',
  PaymentMethod.$unknown: r'$unknown',
};
