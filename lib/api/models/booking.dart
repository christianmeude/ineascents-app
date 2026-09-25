// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package.dart';
import 'scent.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@Freezed()
abstract class Booking with _$Booking {
  const factory Booking({
    int? id,
    @JsonKey(name: 'booking_reference')
    String? bookingReference,
    @JsonKey(name: 'user_id')
    int? userId,
    @JsonKey(name: 'customer_name')
    String? customerName,
    @JsonKey(name: 'customer_email')
    String? customerEmail,
    @JsonKey(name: 'customer_phone')
    String? customerPhone,
    int? pax,
    @JsonKey(name: 'event_date')
    DateTime? eventDate,
    @JsonKey(name: 'event_time')
    String? eventTime,
    @JsonKey(name: 'venue_address')
    String? venueAddress,
    @JsonKey(name: 'payment_method')
    String? paymentMethod,
    String? status,
    @JsonKey(name: 'checkout_url')
    String? checkoutUrl,
    @JsonKey(name: 'inquiry_id')
    int? inquiryId,
    Package? package,
    List<Scent>? scents,
  }) = _Booking;
  
  factory Booking.fromJson(Map<String, Object?> json) => _$BookingFromJson(json);
}
