// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_inquiries_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiInquiriesRequestBody {

 String get name; String get email; String get phone;@JsonKey(name: 'event_date') DateTime? get eventDate; String? get message;
/// Create a copy of ApiInquiriesRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiInquiriesRequestBodyCopyWith<ApiInquiriesRequestBody> get copyWith => _$ApiInquiriesRequestBodyCopyWithImpl<ApiInquiriesRequestBody>(this as ApiInquiriesRequestBody, _$identity);

  /// Serializes this ApiInquiriesRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiInquiriesRequestBody&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,eventDate,message);

@override
String toString() {
  return 'ApiInquiriesRequestBody(name: $name, email: $email, phone: $phone, eventDate: $eventDate, message: $message)';
}


}

/// @nodoc
abstract mixin class $ApiInquiriesRequestBodyCopyWith<$Res>  {
  factory $ApiInquiriesRequestBodyCopyWith(ApiInquiriesRequestBody value, $Res Function(ApiInquiriesRequestBody) _then) = _$ApiInquiriesRequestBodyCopyWithImpl;
@useResult
$Res call({
 String name, String email, String phone,@JsonKey(name: 'event_date') DateTime? eventDate, String? message
});




}
/// @nodoc
class _$ApiInquiriesRequestBodyCopyWithImpl<$Res>
    implements $ApiInquiriesRequestBodyCopyWith<$Res> {
  _$ApiInquiriesRequestBodyCopyWithImpl(this._self, this._then);

  final ApiInquiriesRequestBody _self;
  final $Res Function(ApiInquiriesRequestBody) _then;

/// Create a copy of ApiInquiriesRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? eventDate = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiInquiriesRequestBody].
extension ApiInquiriesRequestBodyPatterns on ApiInquiriesRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiInquiriesRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiInquiriesRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiInquiriesRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.eventDate,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody():
return $default(_that.name,_that.email,_that.phone,_that.eventDate,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String phone, @JsonKey(name: 'event_date')  DateTime? eventDate,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ApiInquiriesRequestBody() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.eventDate,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiInquiriesRequestBody implements ApiInquiriesRequestBody {
  const _ApiInquiriesRequestBody({required this.name, required this.email, required this.phone, @JsonKey(name: 'event_date') this.eventDate, this.message});
  factory _ApiInquiriesRequestBody.fromJson(Map<String, dynamic> json) => _$ApiInquiriesRequestBodyFromJson(json);

@override final  String name;
@override final  String email;
@override final  String phone;
@override@JsonKey(name: 'event_date') final  DateTime? eventDate;
@override final  String? message;

/// Create a copy of ApiInquiriesRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiInquiriesRequestBodyCopyWith<_ApiInquiriesRequestBody> get copyWith => __$ApiInquiriesRequestBodyCopyWithImpl<_ApiInquiriesRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiInquiriesRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiInquiriesRequestBody&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,eventDate,message);

@override
String toString() {
  return 'ApiInquiriesRequestBody(name: $name, email: $email, phone: $phone, eventDate: $eventDate, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ApiInquiriesRequestBodyCopyWith<$Res> implements $ApiInquiriesRequestBodyCopyWith<$Res> {
  factory _$ApiInquiriesRequestBodyCopyWith(_ApiInquiriesRequestBody value, $Res Function(_ApiInquiriesRequestBody) _then) = __$ApiInquiriesRequestBodyCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String phone,@JsonKey(name: 'event_date') DateTime? eventDate, String? message
});




}
/// @nodoc
class __$ApiInquiriesRequestBodyCopyWithImpl<$Res>
    implements _$ApiInquiriesRequestBodyCopyWith<$Res> {
  __$ApiInquiriesRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiInquiriesRequestBody _self;
  final $Res Function(_ApiInquiriesRequestBody) _then;

/// Create a copy of ApiInquiriesRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? eventDate = freezed,Object? message = freezed,}) {
  return _then(_ApiInquiriesRequestBody(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
