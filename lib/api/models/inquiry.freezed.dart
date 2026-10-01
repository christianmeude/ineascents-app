// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inquiry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inquiry {

 int? get id; String? get name; String? get email; String? get phone;@JsonKey(name: 'event_date') DateTime? get eventDate; String? get message; String? get status; bool? get archived;@JsonKey(name: 'consent_privacy_version') String? get consentPrivacyVersion;@JsonKey(name: 'consented_at') DateTime? get consentedAt;
/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InquiryCopyWith<Inquiry> get copyWith => _$InquiryCopyWithImpl<Inquiry>(this as Inquiry, _$identity);

  /// Serializes this Inquiry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inquiry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.consentPrivacyVersion, consentPrivacyVersion) || other.consentPrivacyVersion == consentPrivacyVersion)&&(identical(other.consentedAt, consentedAt) || other.consentedAt == consentedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,eventDate,message,status,archived,consentPrivacyVersion,consentedAt);

@override
String toString() {
  return 'Inquiry(id: $id, name: $name, email: $email, phone: $phone, eventDate: $eventDate, message: $message, status: $status, archived: $archived, consentPrivacyVersion: $consentPrivacyVersion, consentedAt: $consentedAt)';
}


}

/// @nodoc
abstract mixin class $InquiryCopyWith<$Res>  {
  factory $InquiryCopyWith(Inquiry value, $Res Function(Inquiry) _then) = _$InquiryCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? email, String? phone,@JsonKey(name: 'event_date') DateTime? eventDate, String? message, String? status, bool? archived,@JsonKey(name: 'consent_privacy_version') String? consentPrivacyVersion,@JsonKey(name: 'consented_at') DateTime? consentedAt
});




}
/// @nodoc
class _$InquiryCopyWithImpl<$Res>
    implements $InquiryCopyWith<$Res> {
  _$InquiryCopyWithImpl(this._self, this._then);

  final Inquiry _self;
  final $Res Function(Inquiry) _then;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? eventDate = freezed,Object? message = freezed,Object? status = freezed,Object? archived = freezed,Object? consentPrivacyVersion = freezed,Object? consentedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,archived: freezed == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool?,consentPrivacyVersion: freezed == consentPrivacyVersion ? _self.consentPrivacyVersion : consentPrivacyVersion // ignore: cast_nullable_to_non_nullable
as String?,consentedAt: freezed == consentedAt ? _self.consentedAt : consentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Inquiry].
extension InquiryPatterns on Inquiry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inquiry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inquiry value)  $default,){
final _that = this;
switch (_that) {
case _Inquiry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inquiry value)?  $default,){
final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? email,  String? phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message,  String? status,  bool? archived, @JsonKey(name: 'consent_privacy_version')  String? consentPrivacyVersion, @JsonKey(name: 'consented_at')  DateTime? consentedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.eventDate,_that.message,_that.status,_that.archived,_that.consentPrivacyVersion,_that.consentedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? email,  String? phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message,  String? status,  bool? archived, @JsonKey(name: 'consent_privacy_version')  String? consentPrivacyVersion, @JsonKey(name: 'consented_at')  DateTime? consentedAt)  $default,) {final _that = this;
switch (_that) {
case _Inquiry():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.eventDate,_that.message,_that.status,_that.archived,_that.consentPrivacyVersion,_that.consentedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? email,  String? phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message,  String? status,  bool? archived, @JsonKey(name: 'consent_privacy_version')  String? consentPrivacyVersion, @JsonKey(name: 'consented_at')  DateTime? consentedAt)?  $default,) {final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.eventDate,_that.message,_that.status,_that.archived,_that.consentPrivacyVersion,_that.consentedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inquiry implements Inquiry {
  const _Inquiry({this.id, this.name, this.email, this.phone, @JsonKey(name: 'event_date') this.eventDate, this.message, this.status, this.archived, @JsonKey(name: 'consent_privacy_version') this.consentPrivacyVersion, @JsonKey(name: 'consented_at') this.consentedAt});
  factory _Inquiry.fromJson(Map<String, dynamic> json) => _$InquiryFromJson(json);

@override final  int? id;
@override final  String? name;
@override final  String? email;
@override final  String? phone;
@override@JsonKey(name: 'event_date') final  DateTime? eventDate;
@override final  String? message;
@override final  String? status;
@override final  bool? archived;
@override@JsonKey(name: 'consent_privacy_version') final  String? consentPrivacyVersion;
@override@JsonKey(name: 'consented_at') final  DateTime? consentedAt;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InquiryCopyWith<_Inquiry> get copyWith => __$InquiryCopyWithImpl<_Inquiry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InquiryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inquiry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.consentPrivacyVersion, consentPrivacyVersion) || other.consentPrivacyVersion == consentPrivacyVersion)&&(identical(other.consentedAt, consentedAt) || other.consentedAt == consentedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,eventDate,message,status,archived,consentPrivacyVersion,consentedAt);

@override
String toString() {
  return 'Inquiry(id: $id, name: $name, email: $email, phone: $phone, eventDate: $eventDate, message: $message, status: $status, archived: $archived, consentPrivacyVersion: $consentPrivacyVersion, consentedAt: $consentedAt)';
}


}

/// @nodoc
abstract mixin class _$InquiryCopyWith<$Res> implements $InquiryCopyWith<$Res> {
  factory _$InquiryCopyWith(_Inquiry value, $Res Function(_Inquiry) _then) = __$InquiryCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? email, String? phone,@JsonKey(name: 'event_date') DateTime? eventDate, String? message, String? status, bool? archived,@JsonKey(name: 'consent_privacy_version') String? consentPrivacyVersion,@JsonKey(name: 'consented_at') DateTime? consentedAt
});




}
/// @nodoc
class __$InquiryCopyWithImpl<$Res>
    implements _$InquiryCopyWith<$Res> {
  __$InquiryCopyWithImpl(this._self, this._then);

  final _Inquiry _self;
  final $Res Function(_Inquiry) _then;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? eventDate = freezed,Object? message = freezed,Object? status = freezed,Object? archived = freezed,Object? consentPrivacyVersion = freezed,Object? consentedAt = freezed,}) {
  return _then(_Inquiry(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,archived: freezed == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool?,consentPrivacyVersion: freezed == consentPrivacyVersion ? _self.consentPrivacyVersion : consentPrivacyVersion // ignore: cast_nullable_to_non_nullable
as String?,consentedAt: freezed == consentedAt ? _self.consentedAt : consentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
