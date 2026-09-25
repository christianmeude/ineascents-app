// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_user_email_verify_request_body.freezed.dart';
part 'api_user_email_verify_request_body.g.dart';

@Freezed()
abstract class ApiUserEmailVerifyRequestBody with _$ApiUserEmailVerifyRequestBody {
  const factory ApiUserEmailVerifyRequestBody({
    required String code,
  }) = _ApiUserEmailVerifyRequestBody;
  
  factory ApiUserEmailVerifyRequestBody.fromJson(Map<String, Object?> json) => _$ApiUserEmailVerifyRequestBodyFromJson(json);
}
