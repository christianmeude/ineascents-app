// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'post_api_register_response.freezed.dart';
part 'post_api_register_response.g.dart';

@Freezed()
abstract class PostApiRegisterResponse with _$PostApiRegisterResponse {
  const factory PostApiRegisterResponse({
    User? user,
    String? message,
    @JsonKey(name: 'code_expires_at')
    DateTime? codeExpiresAt,
  }) = _PostApiRegisterResponse;
  
  factory PostApiRegisterResponse.fromJson(Map<String, Object?> json) => _$PostApiRegisterResponseFromJson(json);
}
