// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_user_password_request_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiUserPasswordRequestResponse {

 String? get message;@JsonKey(name: 'code_expires_at') DateTime? get codeExpiresAt;
/// Create a copy of PostApiUserPasswordRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiUserPasswordRequestResponseCopyWith<PostApiUserPasswordRequestResponse> get copyWith => _$PostApiUserPasswordRequestResponseCopyWithImpl<PostApiUserPasswordRequestResponse>(this as PostApiUserPasswordRequestResponse, _$identity);

  /// Serializes this PostApiUserPasswordRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiUserPasswordRequestResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiUserPasswordRequestResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class $PostApiUserPasswordRequestResponseCopyWith<$Res>  {
  factory $PostApiUserPasswordRequestResponseCopyWith(PostApiUserPasswordRequestResponse value, $Res Function(PostApiUserPasswordRequestResponse) _then) = _$PostApiUserPasswordRequestResponseCopyWithImpl;
@useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class _$PostApiUserPasswordRequestResponseCopyWithImpl<$Res>
    implements $PostApiUserPasswordRequestResponseCopyWith<$Res> {
  _$PostApiUserPasswordRequestResponseCopyWithImpl(this._self, this._then);

  final PostApiUserPasswordRequestResponse _self;
  final $Res Function(PostApiUserPasswordRequestResponse) _then;

/// Create a copy of PostApiUserPasswordRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostApiUserPasswordRequestResponse].
extension PostApiUserPasswordRequestResponsePatterns on PostApiUserPasswordRequestResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiUserPasswordRequestResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiUserPasswordRequestResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiUserPasswordRequestResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse() when $default != null:
return $default(_that.message,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse():
return $default(_that.message,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _PostApiUserPasswordRequestResponse() when $default != null:
return $default(_that.message,_that.codeExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiUserPasswordRequestResponse implements PostApiUserPasswordRequestResponse {
  const _PostApiUserPasswordRequestResponse({this.message, @JsonKey(name: 'code_expires_at') this.codeExpiresAt});
  factory _PostApiUserPasswordRequestResponse.fromJson(Map<String, dynamic> json) => _$PostApiUserPasswordRequestResponseFromJson(json);

@override final  String? message;
@override@JsonKey(name: 'code_expires_at') final  DateTime? codeExpiresAt;

/// Create a copy of PostApiUserPasswordRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiUserPasswordRequestResponseCopyWith<_PostApiUserPasswordRequestResponse> get copyWith => __$PostApiUserPasswordRequestResponseCopyWithImpl<_PostApiUserPasswordRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiUserPasswordRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiUserPasswordRequestResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiUserPasswordRequestResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$PostApiUserPasswordRequestResponseCopyWith<$Res> implements $PostApiUserPasswordRequestResponseCopyWith<$Res> {
  factory _$PostApiUserPasswordRequestResponseCopyWith(_PostApiUserPasswordRequestResponse value, $Res Function(_PostApiUserPasswordRequestResponse) _then) = __$PostApiUserPasswordRequestResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class __$PostApiUserPasswordRequestResponseCopyWithImpl<$Res>
    implements _$PostApiUserPasswordRequestResponseCopyWith<$Res> {
  __$PostApiUserPasswordRequestResponseCopyWithImpl(this._self, this._then);

  final _PostApiUserPasswordRequestResponse _self;
  final $Res Function(_PostApiUserPasswordRequestResponse) _then;

/// Create a copy of PostApiUserPasswordRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_PostApiUserPasswordRequestResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
