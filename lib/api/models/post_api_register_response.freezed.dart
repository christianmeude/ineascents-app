// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_register_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiRegisterResponse {

 User? get user; String? get message;@JsonKey(name: 'code_expires_at') DateTime? get codeExpiresAt;
/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiRegisterResponseCopyWith<PostApiRegisterResponse> get copyWith => _$PostApiRegisterResponseCopyWithImpl<PostApiRegisterResponse>(this as PostApiRegisterResponse, _$identity);

  /// Serializes this PostApiRegisterResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiRegisterResponse&&(identical(other.user, user) || other.user == user)&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiRegisterResponse(user: $user, message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class $PostApiRegisterResponseCopyWith<$Res>  {
  factory $PostApiRegisterResponseCopyWith(PostApiRegisterResponse value, $Res Function(PostApiRegisterResponse) _then) = _$PostApiRegisterResponseCopyWithImpl;
@useResult
$Res call({
 User? user, String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});


$UserCopyWith<$Res>? get user;

}
/// @nodoc
class _$PostApiRegisterResponseCopyWithImpl<$Res>
    implements $PostApiRegisterResponseCopyWith<$Res> {
  _$PostApiRegisterResponseCopyWithImpl(this._self, this._then);

  final PostApiRegisterResponse _self;
  final $Res Function(PostApiRegisterResponse) _then;

/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = freezed,Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_self.copyWith(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostApiRegisterResponse].
extension PostApiRegisterResponsePatterns on PostApiRegisterResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiRegisterResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiRegisterResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiRegisterResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiRegisterResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiRegisterResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiRegisterResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User? user,  String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostApiRegisterResponse() when $default != null:
return $default(_that.user,_that.message,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User? user,  String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _PostApiRegisterResponse():
return $default(_that.user,_that.message,_that.codeExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User? user,  String? message, @JsonKey(name: 'code_expires_at')  DateTime? codeExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _PostApiRegisterResponse() when $default != null:
return $default(_that.user,_that.message,_that.codeExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiRegisterResponse implements PostApiRegisterResponse {
  const _PostApiRegisterResponse({this.user, this.message, @JsonKey(name: 'code_expires_at') this.codeExpiresAt});
  factory _PostApiRegisterResponse.fromJson(Map<String, dynamic> json) => _$PostApiRegisterResponseFromJson(json);

@override final  User? user;
@override final  String? message;
@override@JsonKey(name: 'code_expires_at') final  DateTime? codeExpiresAt;

/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiRegisterResponseCopyWith<_PostApiRegisterResponse> get copyWith => __$PostApiRegisterResponseCopyWithImpl<_PostApiRegisterResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiRegisterResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiRegisterResponse&&(identical(other.user, user) || other.user == user)&&(identical(other.message, message) || other.message == message)&&(identical(other.codeExpiresAt, codeExpiresAt) || other.codeExpiresAt == codeExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,message,codeExpiresAt);

@override
String toString() {
  return 'PostApiRegisterResponse(user: $user, message: $message, codeExpiresAt: $codeExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$PostApiRegisterResponseCopyWith<$Res> implements $PostApiRegisterResponseCopyWith<$Res> {
  factory _$PostApiRegisterResponseCopyWith(_PostApiRegisterResponse value, $Res Function(_PostApiRegisterResponse) _then) = __$PostApiRegisterResponseCopyWithImpl;
@override @useResult
$Res call({
 User? user, String? message,@JsonKey(name: 'code_expires_at') DateTime? codeExpiresAt
});


@override $UserCopyWith<$Res>? get user;

}
/// @nodoc
class __$PostApiRegisterResponseCopyWithImpl<$Res>
    implements _$PostApiRegisterResponseCopyWith<$Res> {
  __$PostApiRegisterResponseCopyWithImpl(this._self, this._then);

  final _PostApiRegisterResponse _self;
  final $Res Function(_PostApiRegisterResponse) _then;

/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = freezed,Object? message = freezed,Object? codeExpiresAt = freezed,}) {
  return _then(_PostApiRegisterResponse(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,codeExpiresAt: freezed == codeExpiresAt ? _self.codeExpiresAt : codeExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PostApiRegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
