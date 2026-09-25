// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_reset_password_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResetPasswordRequestBody {

 String get email; String get code; String get password;@JsonKey(name: 'password_confirmation') String get passwordConfirmation;
/// Create a copy of ApiResetPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResetPasswordRequestBodyCopyWith<ApiResetPasswordRequestBody> get copyWith => _$ApiResetPasswordRequestBodyCopyWithImpl<ApiResetPasswordRequestBody>(this as ApiResetPasswordRequestBody, _$identity);

  /// Serializes this ApiResetPasswordRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResetPasswordRequestBody&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,code,password,passwordConfirmation);

@override
String toString() {
  return 'ApiResetPasswordRequestBody(email: $email, code: $code, password: $password, passwordConfirmation: $passwordConfirmation)';
}


}

/// @nodoc
abstract mixin class $ApiResetPasswordRequestBodyCopyWith<$Res>  {
  factory $ApiResetPasswordRequestBodyCopyWith(ApiResetPasswordRequestBody value, $Res Function(ApiResetPasswordRequestBody) _then) = _$ApiResetPasswordRequestBodyCopyWithImpl;
@useResult
$Res call({
 String email, String code, String password,@JsonKey(name: 'password_confirmation') String passwordConfirmation
});




}
/// @nodoc
class _$ApiResetPasswordRequestBodyCopyWithImpl<$Res>
    implements $ApiResetPasswordRequestBodyCopyWith<$Res> {
  _$ApiResetPasswordRequestBodyCopyWithImpl(this._self, this._then);

  final ApiResetPasswordRequestBody _self;
  final $Res Function(ApiResetPasswordRequestBody) _then;

/// Create a copy of ApiResetPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? code = null,Object? password = null,Object? passwordConfirmation = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiResetPasswordRequestBody].
extension ApiResetPasswordRequestBodyPatterns on ApiResetPasswordRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResetPasswordRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResetPasswordRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResetPasswordRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody() when $default != null:
return $default(_that.email,_that.code,_that.password,_that.passwordConfirmation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)  $default,) {final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody():
return $default(_that.email,_that.code,_that.password,_that.passwordConfirmation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)?  $default,) {final _that = this;
switch (_that) {
case _ApiResetPasswordRequestBody() when $default != null:
return $default(_that.email,_that.code,_that.password,_that.passwordConfirmation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiResetPasswordRequestBody implements ApiResetPasswordRequestBody {
  const _ApiResetPasswordRequestBody({required this.email, required this.code, required this.password, @JsonKey(name: 'password_confirmation') required this.passwordConfirmation});
  factory _ApiResetPasswordRequestBody.fromJson(Map<String, dynamic> json) => _$ApiResetPasswordRequestBodyFromJson(json);

@override final  String email;
@override final  String code;
@override final  String password;
@override@JsonKey(name: 'password_confirmation') final  String passwordConfirmation;

/// Create a copy of ApiResetPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResetPasswordRequestBodyCopyWith<_ApiResetPasswordRequestBody> get copyWith => __$ApiResetPasswordRequestBodyCopyWithImpl<_ApiResetPasswordRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiResetPasswordRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResetPasswordRequestBody&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,code,password,passwordConfirmation);

@override
String toString() {
  return 'ApiResetPasswordRequestBody(email: $email, code: $code, password: $password, passwordConfirmation: $passwordConfirmation)';
}


}

/// @nodoc
abstract mixin class _$ApiResetPasswordRequestBodyCopyWith<$Res> implements $ApiResetPasswordRequestBodyCopyWith<$Res> {
  factory _$ApiResetPasswordRequestBodyCopyWith(_ApiResetPasswordRequestBody value, $Res Function(_ApiResetPasswordRequestBody) _then) = __$ApiResetPasswordRequestBodyCopyWithImpl;
@override @useResult
$Res call({
 String email, String code, String password,@JsonKey(name: 'password_confirmation') String passwordConfirmation
});




}
/// @nodoc
class __$ApiResetPasswordRequestBodyCopyWithImpl<$Res>
    implements _$ApiResetPasswordRequestBodyCopyWith<$Res> {
  __$ApiResetPasswordRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiResetPasswordRequestBody _self;
  final $Res Function(_ApiResetPasswordRequestBody) _then;

/// Create a copy of ApiResetPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? code = null,Object? password = null,Object? passwordConfirmation = null,}) {
  return _then(_ApiResetPasswordRequestBody(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
