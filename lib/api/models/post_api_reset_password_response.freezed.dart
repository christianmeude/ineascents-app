// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_reset_password_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiResetPasswordResponse {

 String? get message; String? get code;
/// Create a copy of PostApiResetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiResetPasswordResponseCopyWith<PostApiResetPasswordResponse> get copyWith => _$PostApiResetPasswordResponseCopyWithImpl<PostApiResetPasswordResponse>(this as PostApiResetPasswordResponse, _$identity);

  /// Serializes this PostApiResetPasswordResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiResetPasswordResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'PostApiResetPasswordResponse(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $PostApiResetPasswordResponseCopyWith<$Res>  {
  factory $PostApiResetPasswordResponseCopyWith(PostApiResetPasswordResponse value, $Res Function(PostApiResetPasswordResponse) _then) = _$PostApiResetPasswordResponseCopyWithImpl;
@useResult
$Res call({
 String? message, String? code
});




}
/// @nodoc
class _$PostApiResetPasswordResponseCopyWithImpl<$Res>
    implements $PostApiResetPasswordResponseCopyWith<$Res> {
  _$PostApiResetPasswordResponseCopyWithImpl(this._self, this._then);

  final PostApiResetPasswordResponse _self;
  final $Res Function(PostApiResetPasswordResponse) _then;

/// Create a copy of PostApiResetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? code = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostApiResetPasswordResponse].
extension PostApiResetPasswordResponsePatterns on PostApiResetPasswordResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiResetPasswordResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiResetPasswordResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiResetPasswordResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? message,  String? code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse() when $default != null:
return $default(_that.message,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? message,  String? code)  $default,) {final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse():
return $default(_that.message,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? message,  String? code)?  $default,) {final _that = this;
switch (_that) {
case _PostApiResetPasswordResponse() when $default != null:
return $default(_that.message,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiResetPasswordResponse implements PostApiResetPasswordResponse {
  const _PostApiResetPasswordResponse({this.message, this.code});
  factory _PostApiResetPasswordResponse.fromJson(Map<String, dynamic> json) => _$PostApiResetPasswordResponseFromJson(json);

@override final  String? message;
@override final  String? code;

/// Create a copy of PostApiResetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiResetPasswordResponseCopyWith<_PostApiResetPasswordResponse> get copyWith => __$PostApiResetPasswordResponseCopyWithImpl<_PostApiResetPasswordResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiResetPasswordResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiResetPasswordResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'PostApiResetPasswordResponse(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class _$PostApiResetPasswordResponseCopyWith<$Res> implements $PostApiResetPasswordResponseCopyWith<$Res> {
  factory _$PostApiResetPasswordResponseCopyWith(_PostApiResetPasswordResponse value, $Res Function(_PostApiResetPasswordResponse) _then) = __$PostApiResetPasswordResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message, String? code
});




}
/// @nodoc
class __$PostApiResetPasswordResponseCopyWithImpl<$Res>
    implements _$PostApiResetPasswordResponseCopyWith<$Res> {
  __$PostApiResetPasswordResponseCopyWithImpl(this._self, this._then);

  final _PostApiResetPasswordResponse _self;
  final $Res Function(_PostApiResetPasswordResponse) _then;

/// Create a copy of PostApiResetPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? code = freezed,}) {
  return _then(_PostApiResetPasswordResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
