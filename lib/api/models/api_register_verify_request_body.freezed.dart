// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_register_verify_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiRegisterVerifyRequestBody {

 String get email; String get code;
/// Create a copy of ApiRegisterVerifyRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiRegisterVerifyRequestBodyCopyWith<ApiRegisterVerifyRequestBody> get copyWith => _$ApiRegisterVerifyRequestBodyCopyWithImpl<ApiRegisterVerifyRequestBody>(this as ApiRegisterVerifyRequestBody, _$identity);

  /// Serializes this ApiRegisterVerifyRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiRegisterVerifyRequestBody&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,code);

@override
String toString() {
  return 'ApiRegisterVerifyRequestBody(email: $email, code: $code)';
}


}

/// @nodoc
abstract mixin class $ApiRegisterVerifyRequestBodyCopyWith<$Res>  {
  factory $ApiRegisterVerifyRequestBodyCopyWith(ApiRegisterVerifyRequestBody value, $Res Function(ApiRegisterVerifyRequestBody) _then) = _$ApiRegisterVerifyRequestBodyCopyWithImpl;
@useResult
$Res call({
 String email, String code
});




}
/// @nodoc
class _$ApiRegisterVerifyRequestBodyCopyWithImpl<$Res>
    implements $ApiRegisterVerifyRequestBodyCopyWith<$Res> {
  _$ApiRegisterVerifyRequestBodyCopyWithImpl(this._self, this._then);

  final ApiRegisterVerifyRequestBody _self;
  final $Res Function(ApiRegisterVerifyRequestBody) _then;

/// Create a copy of ApiRegisterVerifyRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? code = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiRegisterVerifyRequestBody].
extension ApiRegisterVerifyRequestBodyPatterns on ApiRegisterVerifyRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiRegisterVerifyRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiRegisterVerifyRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiRegisterVerifyRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody() when $default != null:
return $default(_that.email,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String code)  $default,) {final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody():
return $default(_that.email,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String code)?  $default,) {final _that = this;
switch (_that) {
case _ApiRegisterVerifyRequestBody() when $default != null:
return $default(_that.email,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiRegisterVerifyRequestBody implements ApiRegisterVerifyRequestBody {
  const _ApiRegisterVerifyRequestBody({required this.email, required this.code});
  factory _ApiRegisterVerifyRequestBody.fromJson(Map<String, dynamic> json) => _$ApiRegisterVerifyRequestBodyFromJson(json);

@override final  String email;
@override final  String code;

/// Create a copy of ApiRegisterVerifyRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiRegisterVerifyRequestBodyCopyWith<_ApiRegisterVerifyRequestBody> get copyWith => __$ApiRegisterVerifyRequestBodyCopyWithImpl<_ApiRegisterVerifyRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiRegisterVerifyRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiRegisterVerifyRequestBody&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,code);

@override
String toString() {
  return 'ApiRegisterVerifyRequestBody(email: $email, code: $code)';
}


}

/// @nodoc
abstract mixin class _$ApiRegisterVerifyRequestBodyCopyWith<$Res> implements $ApiRegisterVerifyRequestBodyCopyWith<$Res> {
  factory _$ApiRegisterVerifyRequestBodyCopyWith(_ApiRegisterVerifyRequestBody value, $Res Function(_ApiRegisterVerifyRequestBody) _then) = __$ApiRegisterVerifyRequestBodyCopyWithImpl;
@override @useResult
$Res call({
 String email, String code
});




}
/// @nodoc
class __$ApiRegisterVerifyRequestBodyCopyWithImpl<$Res>
    implements _$ApiRegisterVerifyRequestBodyCopyWith<$Res> {
  __$ApiRegisterVerifyRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiRegisterVerifyRequestBody _self;
  final $Res Function(_ApiRegisterVerifyRequestBody) _then;

/// Create a copy of ApiRegisterVerifyRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? code = null,}) {
  return _then(_ApiRegisterVerifyRequestBody(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
