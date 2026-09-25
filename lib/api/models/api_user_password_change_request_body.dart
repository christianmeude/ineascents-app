// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_user_password_change_request_body.freezed.dart';
part 'api_user_password_change_request_body.g.dart';

@Freezed()
abstract class ApiUserPasswordChangeRequestBody with _$ApiUserPasswordChangeRequestBody {
  const factory ApiUserPasswordChangeRequestBody({
    @JsonKey(name: 'current_password')
    required String currentPassword,
    required String code,
    required String password,
    @JsonKey(name: 'password_confirmation')
    required String passwordConfirmation,
  }) = _ApiUserPasswordChangeRequestBody;
  
  factory ApiUserPasswordChangeRequestBody.fromJson(Map<String, Object?> json) => _$ApiUserPasswordChangeRequestBodyFromJson(json);
}
