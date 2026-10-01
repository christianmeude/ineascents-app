// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'auth/auth_api_client.dart';
import 'profile/profile_api_client.dart';
import 'data_rights/data_rights_api_client.dart';
import 'availability/availability_api_client.dart';
import 'bookings/bookings_api_client.dart';
import 'inquiries/inquiries_api_client.dart';
import 'packages/packages_api_client.dart';

/// Inea Scents API `v1.0.0`.
///
/// API Documentation for Inea Scents.
class RestClient {
  RestClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  AuthApiClient? _auth;
  ProfileApiClient? _profile;
  DataRightsApiClient? _dataRights;
  AvailabilityApiClient? _availability;
  BookingsApiClient? _bookings;
  InquiriesApiClient? _inquiries;
  PackagesApiClient? _packages;

  AuthApiClient get auth => _auth ??= AuthApiClient(_dio, baseUrl: _baseUrl);

  ProfileApiClient get profile => _profile ??= ProfileApiClient(_dio, baseUrl: _baseUrl);

  DataRightsApiClient get dataRights => _dataRights ??= DataRightsApiClient(_dio, baseUrl: _baseUrl);

  AvailabilityApiClient get availability => _availability ??= AvailabilityApiClient(_dio, baseUrl: _baseUrl);

  BookingsApiClient get bookings => _bookings ??= BookingsApiClient(_dio, baseUrl: _baseUrl);

  InquiriesApiClient get inquiries => _inquiries ??= InquiriesApiClient(_dio, baseUrl: _baseUrl);

  PackagesApiClient get packages => _packages ??= PackagesApiClient(_dio, baseUrl: _baseUrl);
}
