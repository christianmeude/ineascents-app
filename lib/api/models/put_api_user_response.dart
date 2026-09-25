// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'put_api_user_response.freezed.dart';
part 'put_api_user_response.g.dart';

@Freezed()
abstract class PutApiUserResponse with _$PutApiUserResponse {
  const factory PutApiUserResponse({
    User? data,
    @JsonKey(name: 'email_pending')
    String? emailPending,
    @JsonKey(name: 'code_expires_at')
    DateTime? codeExpiresAt,
  }) = _PutApiUserResponse;
  
  factory PutApiUserResponse.fromJson(Map<String, Object?> json) => _$PutApiUserResponseFromJson(json);
}
