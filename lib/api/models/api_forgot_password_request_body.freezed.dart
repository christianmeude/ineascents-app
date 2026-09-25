// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_forgot_password_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiForgotPasswordRequestBody {

 String get email;
/// Create a copy of ApiForgotPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiForgotPasswordRequestBodyCopyWith<ApiForgotPasswordRequestBody> get copyWith => _$ApiForgotPasswordRequestBodyCopyWithImpl<ApiForgotPasswordRequestBody>(this as ApiForgotPasswordRequestBody, _$identity);

  /// Serializes this ApiForgotPasswordRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiForgotPasswordRequestBody&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ApiForgotPasswordRequestBody(email: $email)';
}


}

/// @nodoc
abstract mixin class $ApiForgotPasswordRequestBodyCopyWith<$Res>  {
  factory $ApiForgotPasswordRequestBodyCopyWith(ApiForgotPasswordRequestBody value, $Res Function(ApiForgotPasswordRequestBody) _then) = _$ApiForgotPasswordRequestBodyCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ApiForgotPasswordRequestBodyCopyWithImpl<$Res>
    implements $ApiForgotPasswordRequestBodyCopyWith<$Res> {
  _$ApiForgotPasswordRequestBodyCopyWithImpl(this._self, this._then);

  final ApiForgotPasswordRequestBody _self;
  final $Res Function(ApiForgotPasswordRequestBody) _then;

/// Create a copy of ApiForgotPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiForgotPasswordRequestBody].
extension ApiForgotPasswordRequestBodyPatterns on ApiForgotPasswordRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiForgotPasswordRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiForgotPasswordRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiForgotPasswordRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _ApiForgotPasswordRequestBody() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiForgotPasswordRequestBody implements ApiForgotPasswordRequestBody {
  const _ApiForgotPasswordRequestBody({required this.email});
  factory _ApiForgotPasswordRequestBody.fromJson(Map<String, dynamic> json) => _$ApiForgotPasswordRequestBodyFromJson(json);

@override final  String email;

/// Create a copy of ApiForgotPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiForgotPasswordRequestBodyCopyWith<_ApiForgotPasswordRequestBody> get copyWith => __$ApiForgotPasswordRequestBodyCopyWithImpl<_ApiForgotPasswordRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiForgotPasswordRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiForgotPasswordRequestBody&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ApiForgotPasswordRequestBody(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ApiForgotPasswordRequestBodyCopyWith<$Res> implements $ApiForgotPasswordRequestBodyCopyWith<$Res> {
  factory _$ApiForgotPasswordRequestBodyCopyWith(_ApiForgotPasswordRequestBody value, $Res Function(_ApiForgotPasswordRequestBody) _then) = __$ApiForgotPasswordRequestBodyCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ApiForgotPasswordRequestBodyCopyWithImpl<$Res>
    implements _$ApiForgotPasswordRequestBodyCopyWith<$Res> {
  __$ApiForgotPasswordRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiForgotPasswordRequestBody _self;
  final $Res Function(_ApiForgotPasswordRequestBody) _then;

/// Create a copy of ApiForgotPasswordRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ApiForgotPasswordRequestBody(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
