// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_user_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiUserRequestBody {

 String? get name; String? get email;
/// Create a copy of ApiUserRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiUserRequestBodyCopyWith<ApiUserRequestBody> get copyWith => _$ApiUserRequestBodyCopyWithImpl<ApiUserRequestBody>(this as ApiUserRequestBody, _$identity);

  /// Serializes this ApiUserRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiUserRequestBody&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'ApiUserRequestBody(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $ApiUserRequestBodyCopyWith<$Res>  {
  factory $ApiUserRequestBodyCopyWith(ApiUserRequestBody value, $Res Function(ApiUserRequestBody) _then) = _$ApiUserRequestBodyCopyWithImpl;
@useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class _$ApiUserRequestBodyCopyWithImpl<$Res>
    implements $ApiUserRequestBodyCopyWith<$Res> {
  _$ApiUserRequestBodyCopyWithImpl(this._self, this._then);

  final ApiUserRequestBody _self;
  final $Res Function(ApiUserRequestBody) _then;

/// Create a copy of ApiUserRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiUserRequestBody].
extension ApiUserRequestBodyPatterns on ApiUserRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiUserRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiUserRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiUserRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiUserRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiUserRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiUserRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiUserRequestBody() when $default != null:
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? email)  $default,) {final _that = this;
switch (_that) {
case _ApiUserRequestBody():
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _ApiUserRequestBody() when $default != null:
return $default(_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiUserRequestBody implements ApiUserRequestBody {
  const _ApiUserRequestBody({this.name, this.email});
  factory _ApiUserRequestBody.fromJson(Map<String, dynamic> json) => _$ApiUserRequestBodyFromJson(json);

@override final  String? name;
@override final  String? email;

/// Create a copy of ApiUserRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiUserRequestBodyCopyWith<_ApiUserRequestBody> get copyWith => __$ApiUserRequestBodyCopyWithImpl<_ApiUserRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiUserRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiUserRequestBody&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'ApiUserRequestBody(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$ApiUserRequestBodyCopyWith<$Res> implements $ApiUserRequestBodyCopyWith<$Res> {
  factory _$ApiUserRequestBodyCopyWith(_ApiUserRequestBody value, $Res Function(_ApiUserRequestBody) _then) = __$ApiUserRequestBodyCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class __$ApiUserRequestBodyCopyWithImpl<$Res>
    implements _$ApiUserRequestBodyCopyWith<$Res> {
  __$ApiUserRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiUserRequestBody _self;
  final $Res Function(_ApiUserRequestBody) _then;

/// Create a copy of ApiUserRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_ApiUserRequestBody(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
