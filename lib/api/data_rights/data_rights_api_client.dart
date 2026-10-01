// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'data_rights_api_client.g.dart';

@RestApi()
abstract class DataRightsApiClient {
  factory DataRightsApiClient(Dio dio, {String? baseUrl}) = _DataRightsApiClient;

  /// Erase the requester (anonymize, revoke all sessions)
  @DELETE('/api/user')
  Future<void> deleteApiUser();

  /// Export all data held about the requester
  @GET('/api/user/export')
  Future<void> getApiUserExport();
}
