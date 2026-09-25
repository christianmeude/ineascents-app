// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'post_api_user_email_verify_response.freezed.dart';
part 'post_api_user_email_verify_response.g.dart';

@Freezed()
abstract class PostApiUserEmailVerifyResponse with _$PostApiUserEmailVerifyResponse {
  const factory PostApiUserEmailVerifyResponse({
    User? data,
  }) = _PostApiUserEmailVerifyResponse;
  
  factory PostApiUserEmailVerifyResponse.fromJson(Map<String, Object?> json) => _$PostApiUserEmailVerifyResponseFromJson(json);
}
