// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_api_inquiries_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostApiInquiriesResponse {

 Inquiry? get data;
/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostApiInquiriesResponseCopyWith<PostApiInquiriesResponse> get copyWith => _$PostApiInquiriesResponseCopyWithImpl<PostApiInquiriesResponse>(this as PostApiInquiriesResponse, _$identity);

  /// Serializes this PostApiInquiriesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostApiInquiriesResponse&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostApiInquiriesResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class $PostApiInquiriesResponseCopyWith<$Res>  {
  factory $PostApiInquiriesResponseCopyWith(PostApiInquiriesResponse value, $Res Function(PostApiInquiriesResponse) _then) = _$PostApiInquiriesResponseCopyWithImpl;
@useResult
$Res call({
 Inquiry? data
});


$InquiryCopyWith<$Res>? get data;

}
/// @nodoc
class _$PostApiInquiriesResponseCopyWithImpl<$Res>
    implements $PostApiInquiriesResponseCopyWith<$Res> {
  _$PostApiInquiriesResponseCopyWithImpl(this._self, this._then);

  final PostApiInquiriesResponse _self;
  final $Res Function(PostApiInquiriesResponse) _then;

/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Inquiry?,
  ));
}
/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InquiryCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $InquiryCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostApiInquiriesResponse].
extension PostApiInquiriesResponsePatterns on PostApiInquiriesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostApiInquiriesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostApiInquiriesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostApiInquiriesResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostApiInquiriesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostApiInquiriesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostApiInquiriesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Inquiry? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostApiInquiriesResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Inquiry? data)  $default,) {final _that = this;
switch (_that) {
case _PostApiInquiriesResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Inquiry? data)?  $default,) {final _that = this;
switch (_that) {
case _PostApiInquiriesResponse() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostApiInquiriesResponse implements PostApiInquiriesResponse {
  const _PostApiInquiriesResponse({this.data});
  factory _PostApiInquiriesResponse.fromJson(Map<String, dynamic> json) => _$PostApiInquiriesResponseFromJson(json);

@override final  Inquiry? data;

/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostApiInquiriesResponseCopyWith<_PostApiInquiriesResponse> get copyWith => __$PostApiInquiriesResponseCopyWithImpl<_PostApiInquiriesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostApiInquiriesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostApiInquiriesResponse&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostApiInquiriesResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class _$PostApiInquiriesResponseCopyWith<$Res> implements $PostApiInquiriesResponseCopyWith<$Res> {
  factory _$PostApiInquiriesResponseCopyWith(_PostApiInquiriesResponse value, $Res Function(_PostApiInquiriesResponse) _then) = __$PostApiInquiriesResponseCopyWithImpl;
@override @useResult
$Res call({
 Inquiry? data
});


@override $InquiryCopyWith<$Res>? get data;

}
/// @nodoc
class __$PostApiInquiriesResponseCopyWithImpl<$Res>
    implements _$PostApiInquiriesResponseCopyWith<$Res> {
  __$PostApiInquiriesResponseCopyWithImpl(this._self, this._then);

  final _PostApiInquiriesResponse _self;
  final $Res Function(_PostApiInquiriesResponse) _then;

/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_PostApiInquiriesResponse(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Inquiry?,
  ));
}

/// Create a copy of PostApiInquiriesResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InquiryCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $InquiryCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
