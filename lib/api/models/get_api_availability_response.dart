// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_api_availability_response.freezed.dart';
part 'get_api_availability_response.g.dart';

@Freezed()
abstract class GetApiAvailabilityResponse with _$GetApiAvailabilityResponse {
  const factory GetApiAvailabilityResponse({
    DateTime? date,
    String? status,
  }) = _GetApiAvailabilityResponse;
  
  factory GetApiAvailabilityResponse.fromJson(Map<String, Object?> json) => _$GetApiAvailabilityResponseFromJson(json);
}
