// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_register_verify_request_body.freezed.dart';
part 'api_register_verify_request_body.g.dart';

@Freezed()
abstract class ApiRegisterVerifyRequestBody with _$ApiRegisterVerifyRequestBody {
  const factory ApiRegisterVerifyRequestBody({
    required String email,
    required String code,
  }) = _ApiRegisterVerifyRequestBody;
  
  factory ApiRegisterVerifyRequestBody.fromJson(Map<String, Object?> json) => _$ApiRegisterVerifyRequestBodyFromJson(json);
}
