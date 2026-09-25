// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package.dart';

part 'get_api_packages_response.freezed.dart';
part 'get_api_packages_response.g.dart';

@Freezed()
abstract class GetApiPackagesResponse with _$GetApiPackagesResponse {
  const factory GetApiPackagesResponse({
    List<Package>? data,
  }) = _GetApiPackagesResponse;
  
  factory GetApiPackagesResponse.fromJson(Map<String, Object?> json) => _$GetApiPackagesResponseFromJson(json);
}
