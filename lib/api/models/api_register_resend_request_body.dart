// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_register_resend_request_body.freezed.dart';
part 'api_register_resend_request_body.g.dart';

@Freezed()
abstract class ApiRegisterResendRequestBody with _$ApiRegisterResendRequestBody {
  const factory ApiRegisterResendRequestBody({
    required String email,
  }) = _ApiRegisterResendRequestBody;
  
  factory ApiRegisterResendRequestBody.fromJson(Map<String, Object?> json) => _$ApiRegisterResendRequestBodyFromJson(json);
}
