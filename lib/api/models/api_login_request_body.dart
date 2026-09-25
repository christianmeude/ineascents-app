// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_login_request_body.freezed.dart';
part 'api_login_request_body.g.dart';

@Freezed()
abstract class ApiLoginRequestBody with _$ApiLoginRequestBody {
  const factory ApiLoginRequestBody({
    required String email,
    required String password,
  }) = _ApiLoginRequestBody;
  
  factory ApiLoginRequestBody.fromJson(Map<String, Object?> json) => _$ApiLoginRequestBodyFromJson(json);
}
