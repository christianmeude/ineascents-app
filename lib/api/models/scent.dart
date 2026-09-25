// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scent.freezed.dart';
part 'scent.g.dart';

/// Scent model
@Freezed()
abstract class Scent with _$Scent {
  const factory Scent({
    int? id,
    String? name,
    String? description,
    @JsonKey(name: 'image_url')
    String? imageUrl,
    @JsonKey(name: 'is_available')
    bool? isAvailable,
    @JsonKey(name: 'created_at')
    DateTime? createdAt,
    @JsonKey(name: 'updated_at')
    DateTime? updatedAt,
  }) = _Scent;
  
  factory Scent.fromJson(Map<String, Object?> json) => _$ScentFromJson(json);
}
