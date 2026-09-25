// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package.dart';

part 'get_api_packages_package_response.freezed.dart';
part 'get_api_packages_package_response.g.dart';

@Freezed()
abstract class GetApiPackagesPackageResponse with _$GetApiPackagesPackageResponse {
  const factory GetApiPackagesPackageResponse({
    Package? data,
  }) = _GetApiPackagesPackageResponse;
  
  factory GetApiPackagesPackageResponse.fromJson(Map<String, Object?> json) => _$GetApiPackagesPackageResponseFromJson(json);
}
