// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_inquiries_request_body.dart';
import '../models/post_api_inquiries_response.dart';

part 'inquiries_api_client.g.dart';

@RestApi()
abstract class InquiriesApiClient {
  factory InquiriesApiClient(Dio dio, {String? baseUrl}) = _InquiriesApiClient;

  /// Submit a new inquiry.
  ///
  /// Public lead capture for the landing page. One row per submission; email is not unique.
  @POST('/api/inquiries')
  Future<PostApiInquiriesResponse> postApiInquiries({
    @Body() required ApiInquiriesRequestBody body,
  });
}
