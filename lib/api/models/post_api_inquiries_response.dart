// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'inquiry.dart';

part 'post_api_inquiries_response.freezed.dart';
part 'post_api_inquiries_response.g.dart';

@Freezed()
abstract class PostApiInquiriesResponse with _$PostApiInquiriesResponse {
  const factory PostApiInquiriesResponse({
    Inquiry? data,
  }) = _PostApiInquiriesResponse;
  
  factory PostApiInquiriesResponse.fromJson(Map<String, Object?> json) => _$PostApiInquiriesResponseFromJson(json);
}
