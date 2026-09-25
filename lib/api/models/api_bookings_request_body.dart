// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'payment_method.dart';

part 'api_bookings_request_body.freezed.dart';
part 'api_bookings_request_body.g.dart';

@Freezed()
abstract class ApiBookingsRequestBody with _$ApiBookingsRequestBody {
  const factory ApiBookingsRequestBody({
    @JsonKey(name: 'package_id')
    required int packageId,
    @JsonKey(name: 'customer_name')
    required String customerName,
    @JsonKey(name: 'customer_email')
    required String customerEmail,
    required int pax,
    @JsonKey(name: 'event_date')
    required DateTime eventDate,
    @JsonKey(name: 'venue_address')
    required String venueAddress,
    @JsonKey(name: 'payment_method')
    required PaymentMethod paymentMethod,
    @JsonKey(name: 'customer_phone')
    String? customerPhone,
    @JsonKey(name: 'event_time')
    String? eventTime,
    @JsonKey(name: 'scent_ids')
    List<int>? scentIds,
  }) = _ApiBookingsRequestBody;
  
  factory ApiBookingsRequestBody.fromJson(Map<String, Object?> json) => _$ApiBookingsRequestBodyFromJson(json);
}
