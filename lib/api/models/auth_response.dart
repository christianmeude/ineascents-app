// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@Freezed()
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    User? user,
    @JsonKey(name: 'access_token')
    String? accessToken,
    @JsonKey(name: 'token_type')
    String? tokenType,
  }) = _AuthResponse;
  
  factory AuthResponse.fromJson(Map<String, Object?> json) => _$AuthResponseFromJson(json);
}
