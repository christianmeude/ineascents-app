// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_register_resend_response.freezed.dart';
part 'post_api_register_resend_response.g.dart';

@Freezed()
abstract class PostApiRegisterResendResponse with _$PostApiRegisterResendResponse {
  const factory PostApiRegisterResendResponse({
    String? message,
    @JsonKey(name: 'code_expires_at')
    DateTime? codeExpiresAt,
  }) = _PostApiRegisterResendResponse;
  
  factory PostApiRegisterResendResponse.fromJson(Map<String, Object?> json) => _$PostApiRegisterResendResponseFromJson(json);
}
