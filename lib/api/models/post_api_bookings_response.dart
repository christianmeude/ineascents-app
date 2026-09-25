// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking.dart';

part 'post_api_bookings_response.freezed.dart';
part 'post_api_bookings_response.g.dart';

@Freezed()
abstract class PostApiBookingsResponse with _$PostApiBookingsResponse {
  const factory PostApiBookingsResponse({
    Booking? data,
  }) = _PostApiBookingsResponse;
  
  factory PostApiBookingsResponse.fromJson(Map<String, Object?> json) => _$PostApiBookingsResponseFromJson(json);
}
