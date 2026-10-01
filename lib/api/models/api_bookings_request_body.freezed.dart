// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_bookings_request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiBookingsRequestBody {

@JsonKey(name: 'package_id') int get packageId;@JsonKey(name: 'customer_name') String get customerName;@JsonKey(name: 'customer_email') String get customerEmail; int get pax;@JsonKey(name: 'event_date') DateTime get eventDate;@JsonKey(name: 'venue_address') String get venueAddress;@JsonKey(name: 'payment_method') PaymentMethod get paymentMethod;@JsonKey(name: 'consent_privacy_version') String get consentPrivacyVersion;@JsonKey(name: 'customer_phone') String? get customerPhone;@JsonKey(name: 'event_time') String? get eventTime;@JsonKey(name: 'scent_ids') List<int>? get scentIds;
/// Create a copy of ApiBookingsRequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiBookingsRequestBodyCopyWith<ApiBookingsRequestBody> get copyWith => _$ApiBookingsRequestBodyCopyWithImpl<ApiBookingsRequestBody>(this as ApiBookingsRequestBody, _$identity);

  /// Serializes this ApiBookingsRequestBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiBookingsRequestBody&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.pax, pax) || other.pax == pax)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.consentPrivacyVersion, consentPrivacyVersion) || other.consentPrivacyVersion == consentPrivacyVersion)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&const DeepCollectionEquality().equals(other.scentIds, scentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,customerName,customerEmail,pax,eventDate,venueAddress,paymentMethod,consentPrivacyVersion,customerPhone,eventTime,const DeepCollectionEquality().hash(scentIds));

@override
String toString() {
  return 'ApiBookingsRequestBody(packageId: $packageId, customerName: $customerName, customerEmail: $customerEmail, pax: $pax, eventDate: $eventDate, venueAddress: $venueAddress, paymentMethod: $paymentMethod, consentPrivacyVersion: $consentPrivacyVersion, customerPhone: $customerPhone, eventTime: $eventTime, scentIds: $scentIds)';
}


}

/// @nodoc
abstract mixin class $ApiBookingsRequestBodyCopyWith<$Res>  {
  factory $ApiBookingsRequestBodyCopyWith(ApiBookingsRequestBody value, $Res Function(ApiBookingsRequestBody) _then) = _$ApiBookingsRequestBodyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'package_id') int packageId,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_email') String customerEmail, int pax,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'venue_address') String venueAddress,@JsonKey(name: 'payment_method') PaymentMethod paymentMethod,@JsonKey(name: 'consent_privacy_version') String consentPrivacyVersion,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'event_time') String? eventTime,@JsonKey(name: 'scent_ids') List<int>? scentIds
});




}
/// @nodoc
class _$ApiBookingsRequestBodyCopyWithImpl<$Res>
    implements $ApiBookingsRequestBodyCopyWith<$Res> {
  _$ApiBookingsRequestBodyCopyWithImpl(this._self, this._then);

  final ApiBookingsRequestBody _self;
  final $Res Function(ApiBookingsRequestBody) _then;

/// Create a copy of ApiBookingsRequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageId = null,Object? customerName = null,Object? customerEmail = null,Object? pax = null,Object? eventDate = null,Object? venueAddress = null,Object? paymentMethod = null,Object? consentPrivacyVersion = null,Object? customerPhone = freezed,Object? eventTime = freezed,Object? scentIds = freezed,}) {
  return _then(_self.copyWith(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,pax: null == pax ? _self.pax : pax // ignore: cast_nullable_to_non_nullable
as int,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,consentPrivacyVersion: null == consentPrivacyVersion ? _self.consentPrivacyVersion : consentPrivacyVersion // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String?,scentIds: freezed == scentIds ? _self.scentIds : scentIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiBookingsRequestBody].
extension ApiBookingsRequestBodyPatterns on ApiBookingsRequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiBookingsRequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiBookingsRequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiBookingsRequestBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiBookingsRequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiBookingsRequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiBookingsRequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_id')  int packageId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail,  int pax, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'venue_address')  String venueAddress, @JsonKey(name: 'payment_method')  PaymentMethod paymentMethod, @JsonKey(name: 'consent_privacy_version')  String consentPrivacyVersion, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'scent_ids')  List<int>? scentIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiBookingsRequestBody() when $default != null:
return $default(_that.packageId,_that.customerName,_that.customerEmail,_that.pax,_that.eventDate,_that.venueAddress,_that.paymentMethod,_that.consentPrivacyVersion,_that.customerPhone,_that.eventTime,_that.scentIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_id')  int packageId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail,  int pax, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'venue_address')  String venueAddress, @JsonKey(name: 'payment_method')  PaymentMethod paymentMethod, @JsonKey(name: 'consent_privacy_version')  String consentPrivacyVersion, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'scent_ids')  List<int>? scentIds)  $default,) {final _that = this;
switch (_that) {
case _ApiBookingsRequestBody():
return $default(_that.packageId,_that.customerName,_that.customerEmail,_that.pax,_that.eventDate,_that.venueAddress,_that.paymentMethod,_that.consentPrivacyVersion,_that.customerPhone,_that.eventTime,_that.scentIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'package_id')  int packageId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail,  int pax, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'venue_address')  String venueAddress, @JsonKey(name: 'payment_method')  PaymentMethod paymentMethod, @JsonKey(name: 'consent_privacy_version')  String consentPrivacyVersion, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'scent_ids')  List<int>? scentIds)?  $default,) {final _that = this;
switch (_that) {
case _ApiBookingsRequestBody() when $default != null:
return $default(_that.packageId,_that.customerName,_that.customerEmail,_that.pax,_that.eventDate,_that.venueAddress,_that.paymentMethod,_that.consentPrivacyVersion,_that.customerPhone,_that.eventTime,_that.scentIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiBookingsRequestBody implements ApiBookingsRequestBody {
  const _ApiBookingsRequestBody({@JsonKey(name: 'package_id') required this.packageId, @JsonKey(name: 'customer_name') required this.customerName, @JsonKey(name: 'customer_email') required this.customerEmail, required this.pax, @JsonKey(name: 'event_date') required this.eventDate, @JsonKey(name: 'venue_address') required this.venueAddress, @JsonKey(name: 'payment_method') required this.paymentMethod, @JsonKey(name: 'consent_privacy_version') required this.consentPrivacyVersion, @JsonKey(name: 'customer_phone') this.customerPhone, @JsonKey(name: 'event_time') this.eventTime, @JsonKey(name: 'scent_ids') final  List<int>? scentIds}): _scentIds = scentIds;
  factory _ApiBookingsRequestBody.fromJson(Map<String, dynamic> json) => _$ApiBookingsRequestBodyFromJson(json);

@override@JsonKey(name: 'package_id') final  int packageId;
@override@JsonKey(name: 'customer_name') final  String customerName;
@override@JsonKey(name: 'customer_email') final  String customerEmail;
@override final  int pax;
@override@JsonKey(name: 'event_date') final  DateTime eventDate;
@override@JsonKey(name: 'venue_address') final  String venueAddress;
@override@JsonKey(name: 'payment_method') final  PaymentMethod paymentMethod;
@override@JsonKey(name: 'consent_privacy_version') final  String consentPrivacyVersion;
@override@JsonKey(name: 'customer_phone') final  String? customerPhone;
@override@JsonKey(name: 'event_time') final  String? eventTime;
 final  List<int>? _scentIds;
@override@JsonKey(name: 'scent_ids') List<int>? get scentIds {
  final value = _scentIds;
  if (value == null) return null;
  if (_scentIds is EqualUnmodifiableListView) return _scentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ApiBookingsRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiBookingsRequestBodyCopyWith<_ApiBookingsRequestBody> get copyWith => __$ApiBookingsRequestBodyCopyWithImpl<_ApiBookingsRequestBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiBookingsRequestBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiBookingsRequestBody&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.pax, pax) || other.pax == pax)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.consentPrivacyVersion, consentPrivacyVersion) || other.consentPrivacyVersion == consentPrivacyVersion)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&const DeepCollectionEquality().equals(other._scentIds, _scentIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageId,customerName,customerEmail,pax,eventDate,venueAddress,paymentMethod,consentPrivacyVersion,customerPhone,eventTime,const DeepCollectionEquality().hash(_scentIds));

@override
String toString() {
  return 'ApiBookingsRequestBody(packageId: $packageId, customerName: $customerName, customerEmail: $customerEmail, pax: $pax, eventDate: $eventDate, venueAddress: $venueAddress, paymentMethod: $paymentMethod, consentPrivacyVersion: $consentPrivacyVersion, customerPhone: $customerPhone, eventTime: $eventTime, scentIds: $scentIds)';
}


}

/// @nodoc
abstract mixin class _$ApiBookingsRequestBodyCopyWith<$Res> implements $ApiBookingsRequestBodyCopyWith<$Res> {
  factory _$ApiBookingsRequestBodyCopyWith(_ApiBookingsRequestBody value, $Res Function(_ApiBookingsRequestBody) _then) = __$ApiBookingsRequestBodyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'package_id') int packageId,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_email') String customerEmail, int pax,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'venue_address') String venueAddress,@JsonKey(name: 'payment_method') PaymentMethod paymentMethod,@JsonKey(name: 'consent_privacy_version') String consentPrivacyVersion,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'event_time') String? eventTime,@JsonKey(name: 'scent_ids') List<int>? scentIds
});




}
/// @nodoc
class __$ApiBookingsRequestBodyCopyWithImpl<$Res>
    implements _$ApiBookingsRequestBodyCopyWith<$Res> {
  __$ApiBookingsRequestBodyCopyWithImpl(this._self, this._then);

  final _ApiBookingsRequestBody _self;
  final $Res Function(_ApiBookingsRequestBody) _then;

/// Create a copy of ApiBookingsRequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageId = null,Object? customerName = null,Object? customerEmail = null,Object? pax = null,Object? eventDate = null,Object? venueAddress = null,Object? paymentMethod = null,Object? consentPrivacyVersion = null,Object? customerPhone = freezed,Object? eventTime = freezed,Object? scentIds = freezed,}) {
  return _then(_ApiBookingsRequestBody(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,pax: null == pax ? _self.pax : pax // ignore: cast_nullable_to_non_nullable
as int,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,consentPrivacyVersion: null == consentPrivacyVersion ? _self.consentPrivacyVersion : consentPrivacyVersion // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String?,scentIds: freezed == scentIds ? _self._scentIds : scentIds // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}


}

// dart format on
