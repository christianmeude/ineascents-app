// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_availability_response.dart';

part 'availability_api_client.g.dart';

@RestApi()
abstract class AvailabilityApiClient {
  factory AvailabilityApiClient(Dio dio, {String? baseUrl}) = _AvailabilityApiClient;

  /// Get availability calendar for a given month and year.
  ///
  /// Returns a list of dates for the requested month marked as 'Booked' or 'Available'.
  ///
  /// [month] - Month number (1-12). Defaults to current month.
  ///
  /// [year] - Year (e.g. 2024). Defaults to current year.
  @GET('/api/availability')
  Future<List<GetApiAvailabilityResponse>> getApiAvailability({
    @Query('month') int? month,
    @Query('year') int? year,
  });
}
