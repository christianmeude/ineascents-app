// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'put_api_user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PutApiUserResponse {

 User? get data;@JsonKey(name: 'email_pending') String? get emailPending;@JsonKey(name: 'code_expires_at') DateTime? get codeExpiresAt;
/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PutApiUserResponseCopyWith<PutApiUserResponse> get copyWith => _$PutApiUserResponseCopyWithImpl<PutApiUserResponse>(this as PutApiUserResponse, _$identity);

  /// Serializes this PutApiUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PutApiUserResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.emailPending, emailPending) || other.emailPending == emailPending)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,emailPending,codeExpiresAt);

@override
String toString() {
  return 'PutApiUserResponse(data: $data, emailPending: $emailPending, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class $PutApiUserResponseCopyWith<$Res>  {
  factory $PutApiUserResponseCopyWith(PutApiUserResponse value, $Res Function(PutApiUserResponse) _then) = _$PutApiUserResponseCopyWithImpl;
@useResult
$Res call({
 User? data,@JsonKey(name: 'email_pending') String? emailPending,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});


$UserCopyWith<$Res>? get data;

}
/// @nodoc
class _$PutApiUserResponseCopyWithImpl<$Res>
    implements $PutApiUserResponseCopyWith<$Res> {
  _$PutApiUserResponseCopyWithImpl(this._self, this._then);

  final PutApiUserResponse _self;
  final $Res Function(PutApiUserResponse) _then;

/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? emailPending = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as User?,emailPending: freezed == emailPending ? _self.emailPending : emailPending // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PutApiUserResponse].
extension PutApiUserResponsePatterns on PutApiUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PutApiUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PutApiUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PutApiUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _PutApiUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PutApiUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PutApiUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User? data, @JsonKey(name: 'email_pending')  String? emailPending, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PutApiUserResponse() when $default != null:
return $default(_that.data,_that.emailPending,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User? data, @JsonKey(name: 'email_pending')  String? emailPending, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _PutApiUserResponse():
return $default(_that.data,_that.emailPending,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User? data, @JsonKey(name: 'email_pending')  String? emailPending, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _PutApiUserResponse() when $default != null:
return $default(_that.data,_that.emailPending,_that.codeExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PutApiUserResponse implements PutApiUserResponse {
  const _PutApiUserResponse({this.data, @JsonKey(name: 'email_pending') this.emailPending, @JsonKey(name: 'code_expires_at') this.codeExpiresAt});
  factory _PutApiUserResponse.fromJson(Map<String, dynamic> json) => _$PutApiUserResponseFromJson(json);

@override final  User? data;
@override@JsonKey(name: 'email_pending') final  String? emailPending;
@override@JsonKey(name: 'code_expires_at') final  DateTime? codeExpiresAt;

/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PutApiUserResponseCopyWith<_PutApiUserResponse> get copyWith => __$PutApiUserResponseCopyWithImpl<_PutApiUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PutApiUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PutApiUserResponse&&(identical(other.data, data) || other.data == data)&&(identical(other.emailPending, emailPending) || other.emailPending == emailPending)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,emailPending,codeExpiresAt);

@override
String toString() {
  return 'PutApiUserResponse(data: $data, emailPending: $emailPending, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$PutApiUserResponseCopyWith<$Res> implements $PutApiUserResponseCopyWith<$Res> {
  factory _$PutApiUserResponseCopyWith(_PutApiUserResponse value, $Res Function(_PutApiUserResponse) _then) = __$PutApiUserResponseCopyWithImpl;
@override @useResult
$Res call({
 User? data,@JsonKey(name: 'email_pending') String? emailPending,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});


@override $UserCopyWith<$Res>? get data;

}
/// @nodoc
class __$PutApiUserResponseCopyWithImpl<$Res>
    implements _$PutApiUserResponseCopyWith<$Res> {
  __$PutApiUserResponseCopyWithImpl(this._self, this._then);

  final _PutApiUserResponse _self;
  final $Res Function(_PutApiUserResponse) _then;

/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? emailPending = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_PutApiUserResponse(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as User?,emailPending: freezed == emailPending ? _self.emailPending : emailPending // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PutApiUserResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
