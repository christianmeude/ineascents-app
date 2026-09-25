// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_user_email_resend_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiUserEmailResendResponse {

 String? get message;@JsonKey(name: 'code_expires_at') DateTime? get codeExpiresAt;
/// Create a copy of PostApiUserEmailResendResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiUserEmailResendResponseCopyWith<PostApiUserEmailResendResponse> get copyWith => _$PostApiUserEmailResendResponseCopyWithImpl<PostApiUserEmailResendResponse>(this as PostApiUserEmailResendResponse, _$identity);

  /// Serializes this PostApiUserEmailResendResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiUserEmailResendResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiUserEmailResendResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class $PostApiUserEmailResendResponseCopyWith<$Res>  {
  factory $PostApiUserEmailResendResponseCopyWith(PostApiUserEmailResendResponse value, $Res Function(PostApiUserEmailResendResponse) _then) = _$PostApiUserEmailResendResponseCopyWithImpl;
@useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class _$PostApiUserEmailResendResponseCopyWithImpl<$Res>
    implements $PostApiUserEmailResendResponseCopyWith<$Res> {
  _$PostApiUserEmailResendResponseCopyWithImpl(this._self, this._then);

  final PostApiUserEmailResendResponse _self;
  final $Res Function(PostApiUserEmailResendResponse) _then;

/// Create a copy of PostApiUserEmailResendResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostApiUserEmailResendResponse].
extension PostApiUserEmailResendResponsePatterns on PostApiUserEmailResendResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiUserEmailResendResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiUserEmailResendResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiUserEmailResendResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiUserEmailResendResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiUserEmailResendResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiUserEmailResendResponse() when $default != null:
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
case _PostApiUserEmailResendResponse() when $default != null:
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
case _PostApiUserEmailResendResponse():
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
case _PostApiUserEmailResendResponse() when $default != null:
return $default(_that.message,_that.codeExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiUserEmailResendResponse implements PostApiUserEmailResendResponse {
  const _PostApiUserEmailResendResponse({this.message, @JsonKey(name: 'code_expires_at') this.codeExpiresAt});
  factory _PostApiUserEmailResendResponse.fromJson(Map<String, dynamic> json) => _$PostApiUserEmailResendResponseFromJson(json);

@override final  String? message;
@override@JsonKey(name: 'code_expires_at') final  DateTime? codeExpiresAt;

/// Create a copy of PostApiUserEmailResendResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiUserEmailResendResponseCopyWith<_PostApiUserEmailResendResponse> get copyWith => __$PostApiUserEmailResendResponseCopyWithImpl<_PostApiUserEmailResendResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiUserEmailResendResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiUserEmailResendResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiUserEmailResendResponse(message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$PostApiUserEmailResendResponseCopyWith<$Res> implements $PostApiUserEmailResendResponseCopyWith<$Res> {
  factory _$PostApiUserEmailResendResponseCopyWith(_PostApiUserEmailResendResponse value, $Res Function(_PostApiUserEmailResendResponse) _then) = __$PostApiUserEmailResendResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});




}
/// @nodoc
class __$PostApiUserEmailResendResponseCopyWithImpl<$Res>
    implements _$PostApiUserEmailResendResponseCopyWith<$Res> {
  __$PostApiUserEmailResendResponseCopyWithImpl(this._self, this._then);

  final _PostApiUserEmailResendResponse _self;
  final $Res Function(_PostApiUserEmailResendResponse) _then;

/// Create a copy of PostApiUserEmailResendResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_PostApiUserEmailResendResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
