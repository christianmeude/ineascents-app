// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_user_password_change_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiUserPasswordChangeRequestBody {

@JsonKey(name: 'current_password') String get currentPassword; String get code; String get password;@JsonKey(name: 'password_confirmation') String get passwordConfirmation;
/// Create a copy of ApiUserPasswordChangeRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiUserPasswordChangeRequestBodyCopyWith<ApiUserPasswordChangeRequestBody> get copyWith => _$ApiUserPasswordChangeRequestBodyCopyWithImpl<ApiUserPasswordChangeRequestBody>(this as ApiUserPasswordChangeRequestBody, _$identity);

  /// Serializes this ApiUserPasswordChangeRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiUserPasswordChangeRequestBody&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.code, code) || other.code == code)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,code,password,passwordConfirmation);

@override
String toString() {
  return 'ApiUserPasswordChangeRequestBody(currentPassword: $currentPassword, code: $code, password: $password, passwordConfirmation: $passwordConfirmation)';
}


}

/// @nodoc
abstract mixin class $ApiUserPasswordChangeRequestBodyCopyWith<$Res>  {
  factory $ApiUserPasswordChangeRequestBodyCopyWith(ApiUserPasswordChangeRequestBody value, $Res Function(ApiUserPasswordChangeRequestBody) _then) = _$ApiUserPasswordChangeRequestBodyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_password') String currentPassword, String code, String password,@JsonKey(name: 'password_confirmation') String passwordConfirmation
});




}
/// @nodoc
class _$ApiUserPasswordChangeRequestBodyCopyWithImpl<$Res>
    implements $ApiUserPasswordChangeRequestBodyCopyWith<$Res> {
  _$ApiUserPasswordChangeRequestBodyCopyWithImpl(this._self, this._then);

  final ApiUserPasswordChangeRequestBody _self;
  final $Res Function(ApiUserPasswordChangeRequestBody) _then;

/// Create a copy of ApiUserPasswordChangeRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? code = null,Object? password = null,Object? passwordConfirmation = null,}) {
  return _then(_self.copyWith(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiUserPasswordChangeRequestBody].
extension ApiUserPasswordChangeRequestBodyPatterns on ApiUserPasswordChangeRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiUserPasswordChangeRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiUserPasswordChangeRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiUserPasswordChangeRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_password')  String currentPassword,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody() when $default != null:
return $default(_that.currentPassword,_that.code,_that.password,_that.passwordConfirmation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_password')  String currentPassword,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)  $default,) {final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody():
return $default(_that.currentPassword,_that.code,_that.password,_that.passwordConfirmation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_password')  String currentPassword,  String code,  String password, @JsonKey(name: 'password_confirmation')  String passwordConfirmation)?  $default,) {final _that = this;
switch (_that) {
case _ApiUserPasswordChangeRequestBody() when $default != null:
return $default(_that.currentPassword,_that.code,_that.password,_that.passwordConfirmation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiUserPasswordChangeRequestBody implements ApiUserPasswordChangeRequestBody {
  const _ApiUserPasswordChangeRequestBody({@JsonKey(name: 'current_password') required this.currentPassword, required this.code, required this.password, @JsonKey(name: 'password_confirmation') required this.passwordConfirmation});
  factory _ApiUserPasswordChangeRequestBody.fromJson(Map<String, dynamic> json) => _$ApiUserPasswordChangeRequestBodyFromJson(json);

@override@JsonKey(name: 'current_password') final  String currentPassword;
@override final  String code;
@override final  String password;
@override@JsonKey(name: 'password_confirmation') final  String passwordConfirmation;

/// Create a copy of ApiUserPasswordChangeRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiUserPasswordChangeRequestBodyCopyWith<_ApiUserPasswordChangeRequestBody> get copyWith => __$ApiUserPasswordChangeRequestBodyCopyWithImpl<_ApiUserPasswordChangeRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiUserPasswordChangeRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiUserPasswordChangeRequestBody&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.code, code) || other.code == code)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,code,password,passwordConfirmation);

@override
String toString() {
  return 'ApiUserPasswordChangeRequestBody(currentPassword: $currentPassword, code: $code, password: $password, passwordConfirmation: $passwordConfirmation)';
}


}

/// @nodoc
abstract mixin class _$ApiUserPasswordChangeRequestBodyCopyWith<$Res> implements $ApiUserPasswordChangeRequestBodyCopyWith<$Res> {
  factory _$ApiUserPasswordChangeRequestBodyCopyWith(_ApiUserPasswordChangeRequestBody value, $Res Function(_ApiUserPasswordChangeRequestBody) _then) = __$ApiUserPasswordChangeRequestBodyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_password') String currentPassword, String code, String password,@JsonKey(name: 'password_confirmation') String passwordConfirmation
});




}
/// @nodoc
class __$ApiUserPasswordChangeRequestBodyCopyWithImpl<$Res>
    implements _$ApiUserPasswordChangeRequestBodyCopyWith<$Res> {
  __$ApiUserPasswordChangeRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiUserPasswordChangeRequestBody _self;
  final $Res Function(_ApiUserPasswordChangeRequestBody) _then;

/// Create a copy of ApiUserPasswordChangeRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? code = null,Object? password = null,Object? passwordConfirmation = null,}) {
  return _then(_ApiUserPasswordChangeRequestBody(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
