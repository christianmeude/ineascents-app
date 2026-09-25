// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_forgot_password_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiForgotPasswordResponse {

 String? get message; String? get code;
/// Create a copy of PostApiForgotPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiForgotPasswordResponseCopyWith<PostApiForgotPasswordResponse> get copyWith => _$PostApiForgotPasswordResponseCopyWithImpl<PostApiForgotPasswordResponse>(this as PostApiForgotPasswordResponse, _$identity);

  /// Serializes this PostApiForgotPasswordResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiForgotPasswordResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'PostApiForgotPasswordResponse(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $PostApiForgotPasswordResponseCopyWith<$Res>  {
  factory $PostApiForgotPasswordResponseCopyWith(PostApiForgotPasswordResponse value, $Res Function(PostApiForgotPasswordResponse) _then) = _$PostApiForgotPasswordResponseCopyWithImpl;
@useResult
$Res call({
 String? message, String? code
});




}
/// @nodoc
class _$PostApiForgotPasswordResponseCopyWithImpl<$Res>
    implements $PostApiForgotPasswordResponseCopyWith<$Res> {
  _$PostApiForgotPasswordResponseCopyWithImpl(this._self, this._then);

  final PostApiForgotPasswordResponse _self;
  final $Res Function(PostApiForgotPasswordResponse) _then;

/// Create a copy of PostApiForgotPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? code = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostApiForgotPasswordResponse].
extension PostApiForgotPasswordResponsePatterns on PostApiForgotPasswordResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiForgotPasswordResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiForgotPasswordResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiForgotPasswordResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiForgotPasswordResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiForgotPasswordResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiForgotPasswordResponse() when $default != null:
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
case _PostApiForgotPasswordResponse() when $default != null:
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
case _PostApiForgotPasswordResponse():
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
case _PostApiForgotPasswordResponse() when $default != null:
return $default(_that.message,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiForgotPasswordResponse implements PostApiForgotPasswordResponse {
  const _PostApiForgotPasswordResponse({this.message, this.code});
  factory _PostApiForgotPasswordResponse.fromJson(Map<String, dynamic> json) => _$PostApiForgotPasswordResponseFromJson(json);

@override final  String? message;
@override final  String? code;

/// Create a copy of PostApiForgotPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiForgotPasswordResponseCopyWith<_PostApiForgotPasswordResponse> get copyWith => __$PostApiForgotPasswordResponseCopyWithImpl<_PostApiForgotPasswordResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiForgotPasswordResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiForgotPasswordResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'PostApiForgotPasswordResponse(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class _$PostApiForgotPasswordResponseCopyWith<$Res> implements $PostApiForgotPasswordResponseCopyWith<$Res> {
  factory _$PostApiForgotPasswordResponseCopyWith(_PostApiForgotPasswordResponse value, $Res Function(_PostApiForgotPasswordResponse) _then) = __$PostApiForgotPasswordResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message, String? code
});




}
/// @nodoc
class __$PostApiForgotPasswordResponseCopyWithImpl<$Res>
    implements _$PostApiForgotPasswordResponseCopyWith<$Res> {
  __$PostApiForgotPasswordResponseCopyWithImpl(this._self, this._then);

  final _PostApiForgotPasswordResponse _self;
  final $Res Function(_PostApiForgotPasswordResponse) _then;

/// Create a copy of PostApiForgotPasswordResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? code = freezed,}) {
  return _then(_PostApiForgotPasswordResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
