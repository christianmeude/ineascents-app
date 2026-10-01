// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'inquiry.freezed.dart';
part 'inquiry.g.dart';

@Freezed()
abstract class Inquiry with _$Inquiry {
  const factory Inquiry({
    int? id,
    String? name,
    String? email,
    String? phone,
    @JsonKey(name: 'event_date')
    DateTime? eventDate,
    String? message,
    String? status,
    bool? archived,
    @JsonKey(name: 'consent_privacy_version')
    String? consentPrivacyVersion,
    @JsonKey(name: 'consented_at')
    DateTime? consentedAt,
  }) = _Inquiry;
  
  factory Inquiry.fromJson(Map<String, Object?> json) => _$InquiryFromJson(json);
}
