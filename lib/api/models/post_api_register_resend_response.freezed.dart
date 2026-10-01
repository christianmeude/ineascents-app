// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_register_resend_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiRegisterResendResponse {

 String? get message;@JsonKey(name: 'code_expires_at') DateTime? get codeExpiresAt;
/// Create a copy of PostApiRegisterResendResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiRegisterResendResponseCopyWith<PostApiRegisterResendResponse> get copyWith => _$PostApiRegisterResendResponseCopyWithImpl<PostApiRegisterResendResponse>(this as PostApiRegisterResendResponse, _$identity);

  /// Serializes this PostApiRegisterResendResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiRegisterResendResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiRegisterResendResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class $PostApiRegisterResendResponseCopyWith<$Res>  {
  factory $PostApiRegisterResendResponseCopyWith(PostApiRegisterResendResponse value, $Res Function(PostApiRegisterResendResponse) _then) = _$PostApiRegisterResendResponseCopyWithImpl;
@useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class _$PostApiRegisterResendResponseCopyWithImpl<$Res>
    implements $PostApiRegisterResendResponseCopyWith<$Res> {
  _$PostApiRegisterResendResponseCopyWithImpl(this._self, this._then);

  final PostApiRegisterResendResponse _self;
  final $Res Function(PostApiRegisterResendResponse) _then;

/// Create a copy of PostApiRegisterResendResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostApiRegisterResendResponse].
extension PostApiRegisterResendResponsePatterns on PostApiRegisterResendResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiRegisterResendResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiRegisterResendResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiRegisterResendResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiRegisterResendResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiRegisterResendResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiRegisterResendResponse() when $default != null:
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
case _PostApiRegisterResendResponse() when $default != null:
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
case _PostApiRegisterResendResponse():
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
case _PostApiRegisterResendResponse() when $default != null:
return $default(_that.message,_that.codeExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiRegisterResendResponse implements PostApiRegisterResendResponse {
  const _PostApiRegisterResendResponse({this.message, @JsonKey(name: 'code_expires_at') this.codeExpiresAt});
  factory _PostApiRegisterResendResponse.fromJson(Map<String, dynamic> json) => _$PostApiRegisterResendResponseFromJson(json);

@override final  String? message;
@override@JsonKey(name: 'code_expires_at') final  DateTime? codeExpiresAt;

/// Create a copy of PostApiRegisterResendResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiRegisterResendResponseCopyWith<_PostApiRegisterResendResponse> get copyWith => __$PostApiRegisterResendResponseCopyWithImpl<_PostApiRegisterResendResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiRegisterResendResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiRegisterResendResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiRegisterResendResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$PostApiRegisterResendResponseCopyWith<$Res> implements $PostApiRegisterResendResponseCopyWith<$Res> {
  factory _$PostApiRegisterResendResponseCopyWith(_PostApiRegisterResendResponse value, $Res Function(_PostApiRegisterResendResponse) _then) = __$PostApiRegisterResendResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class __$PostApiRegisterResendResponseCopyWithImpl<$Res>
    implements _$PostApiRegisterResendResponseCopyWith<$Res> {
  __$PostApiRegisterResendResponseCopyWithImpl(this._self, this._then);

  final _PostApiRegisterResendResponse _self;
  final $Res Function(_PostApiRegisterResendResponse) _then;

/// Create a copy of PostApiRegisterResendResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_PostApiRegisterResendResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
