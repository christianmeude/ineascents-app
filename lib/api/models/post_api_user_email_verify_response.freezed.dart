// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_user_email_verify_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiUserEmailVerifyResponse {

 User? get data;
/// Create a copy of PostApiUserEmailVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiUserEmailVerifyResponseCopyWith<PostApiUserEmailVerifyResponse> get copyWith => _$PostApiUserEmailVerifyResponseCopyWithImpl<PostApiUserEmailVerifyResponse>(this as PostApiUserEmailVerifyResponse, _$identity);

  /// Serializes this PostApiUserEmailVerifyResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiUserEmailVerifyResponse&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostApiUserEmailVerifyResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class $PostApiUserEmailVerifyResponseCopyWith<$Res>  {
  factory $PostApiUserEmailVerifyResponseCopyWith(PostApiUserEmailVerifyResponse value, $Res Function(PostApiUserEmailVerifyResponse) _then) = _$PostApiUserEmailVerifyResponseCopyWithImpl;
@useResult
$Res call({
 User? data
});


$UserCopyWith<$Res>? get data;

}
/// @nodoc
class _$PostApiUserEmailVerifyResponseCopyWithImpl<$Res>
    implements $PostApiUserEmailVerifyResponseCopyWith<$Res> {
  _$PostApiUserEmailVerifyResponseCopyWithImpl(this._self, this._then);

  final PostApiUserEmailVerifyResponse _self;
  final $Res Function(PostApiUserEmailVerifyResponse) _then;

/// Create a copy of PostApiUserEmailVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as User?,
  ));
}
/// Create a copy of PostApiUserEmailVerifyResponse
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


/// Adds pattern-matching-related methods to [PostApiUserEmailVerifyResponse].
extension PostApiUserEmailVerifyResponsePatterns on PostApiUserEmailVerifyResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiUserEmailVerifyResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiUserEmailVerifyResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiUserEmailVerifyResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User? data)  $default,) {final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse():
return $default(_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User? data)?  $default,) {final _that = this;
switch (_that) {
case _PostApiUserEmailVerifyResponse() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiUserEmailVerifyResponse implements PostApiUserEmailVerifyResponse {
  const _PostApiUserEmailVerifyResponse({this.data});
  factory _PostApiUserEmailVerifyResponse.fromJson(Map<String, dynamic> json) => _$PostApiUserEmailVerifyResponseFromJson(json);

@override final  User? data;

/// Create a copy of PostApiUserEmailVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiUserEmailVerifyResponseCopyWith<_PostApiUserEmailVerifyResponse> get copyWith => __$PostApiUserEmailVerifyResponseCopyWithImpl<_PostApiUserEmailVerifyResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiUserEmailVerifyResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiUserEmailVerifyResponse&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostApiUserEmailVerifyResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class _$PostApiUserEmailVerifyResponseCopyWith<$Res> implements $PostApiUserEmailVerifyResponseCopyWith<$Res> {
  factory _$PostApiUserEmailVerifyResponseCopyWith(_PostApiUserEmailVerifyResponse value, $Res Function(_PostApiUserEmailVerifyResponse) _then) = __$PostApiUserEmailVerifyResponseCopyWithImpl;
@override @useResult
$Res call({
 User? data
});


@override $UserCopyWith<$Res>? get data;

}
/// @nodoc
class __$PostApiUserEmailVerifyResponseCopyWithImpl<$Res>
    implements _$PostApiUserEmailVerifyResponseCopyWith<$Res> {
  __$PostApiUserEmailVerifyResponseCopyWithImpl(this._self, this._then);

  final _PostApiUserEmailVerifyResponse _self;
  final $Res Function(_PostApiUserEmailVerifyResponse) _then;

/// Create a copy of PostApiUserEmailVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_PostApiUserEmailVerifyResponse(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as User?,
  ));
}

/// Create a copy of PostApiUserEmailVerifyResponse
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
