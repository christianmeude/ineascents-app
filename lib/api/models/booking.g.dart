// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: (json['id'] as num?)?.toInt(),
  bookingReference: json['booking_reference'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  customerName: json['customer_name'] as String?,
  customerEmail: json['customer_email'] as String?,
  customerPhone: json['customer_phone'] as String?,
  pax: (json['pax'] as num?)?.toInt(),
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  eventTime: json['event_time'] as String?,
  venueAddress: json['venue_address'] as String?,
  paymentMethod: json['payment_method'] as String?,
  status: json['status'] as String?,
  checkoutUrl: json['checkout_url'] as String?,
  inquiryId: (json['inquiry_id'] as num?)?.toInt(),
  package: json['package'] == null
      ? null
      : Package.fromJson(json['package'] as Map<String, dynamic>),
  scents: (json['scents'] as List<dynamic>?)
      ?.map((e) => Scent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'booking_reference': instance.bookingReference,
  'user_id': instance.userId,
  'customer_name': instance.customerName,
  'customer_email': instance.customerEmail,
  'customer_phone': instance.customerPhone,
  'pax': instance.pax,
  'event_date': instance.eventDate?.toIso8601String(),
  'event_time': instance.eventTime,
  'venue_address': instance.venueAddress,
  'payment_method': instance.paymentMethod,
  'status': instance.status,
  'checkout_url': instance.checkoutUrl,
  'inquiry_id': instance.inquiryId,
  'package': instance.package,
  'scents': instance.scents,
};
