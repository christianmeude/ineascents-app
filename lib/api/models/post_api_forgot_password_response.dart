// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_forgot_password_response.freezed.dart';
part 'post_api_forgot_password_response.g.dart';

@Freezed()
abstract class PostApiForgotPasswordResponse with _$PostApiForgotPasswordResponse {
  const factory PostApiForgotPasswordResponse({
    String? message,
    String? code,
  }) = _PostApiForgotPasswordResponse;
  
  factory PostApiForgotPasswordResponse.fromJson(Map<String, Object?> json) => _$PostApiForgotPasswordResponseFromJson(json);
}
