// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking.dart';

part 'get_api_bookings_response.freezed.dart';
part 'get_api_bookings_response.g.dart';

@Freezed()
abstract class GetApiBookingsResponse with _$GetApiBookingsResponse {
  const factory GetApiBookingsResponse({
    List<Booking>? data,
  }) = _GetApiBookingsResponse;
  
  factory GetApiBookingsResponse.fromJson(Map<String, Object?> json) => _$GetApiBookingsResponseFromJson(json);
}
