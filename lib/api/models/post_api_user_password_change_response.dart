// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_user_password_change_response.freezed.dart';
part 'post_api_user_password_change_response.g.dart';

@Freezed()
abstract class PostApiUserPasswordChangeResponse with _$PostApiUserPasswordChangeResponse {
  const factory PostApiUserPasswordChangeResponse({
    String? message,
    String? code,
  }) = _PostApiUserPasswordChangeResponse;
  
  factory PostApiUserPasswordChangeResponse.fromJson(Map<String, Object?> json) => _$PostApiUserPasswordChangeResponseFromJson(json);
}
