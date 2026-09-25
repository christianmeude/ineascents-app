// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_reset_password_response.freezed.dart';
part 'post_api_reset_password_response.g.dart';

@Freezed()
abstract class PostApiResetPasswordResponse with _$PostApiResetPasswordResponse {
  const factory PostApiResetPasswordResponse({
    String? message,
    String? code,
  }) = _PostApiResetPasswordResponse;
  
  factory PostApiResetPasswordResponse.fromJson(Map<String, Object?> json) => _$PostApiResetPasswordResponseFromJson(json);
}
