// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_register_request_body.freezed.dart';
part 'api_register_request_body.g.dart';

@Freezed()
abstract class ApiRegisterRequestBody with _$ApiRegisterRequestBody {
  const factory ApiRegisterRequestBody({
    required String name,
    required String email,
    required String password,
  }) = _ApiRegisterRequestBody;
  
  factory ApiRegisterRequestBody.fromJson(Map<String, Object?> json) => _$ApiRegisterRequestBodyFromJson(json);
}
