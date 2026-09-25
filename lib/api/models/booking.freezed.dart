// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 int? get id;@JsonKey(name: 'booking_reference') String? get bookingReference;@JsonKey(name: 'user_id') int? get userId;@JsonKey(name: 'customer_name') String? get customerName;@JsonKey(name: 'customer_email') String? get customerEmail;@JsonKey(name: 'customer_phone') String? get customerPhone; int? get pax;@JsonKey(name: 'event_date') DateTime? get eventDate;@JsonKey(name: 'event_time') String? get eventTime;@JsonKey(name: 'venue_address') String? get venueAddress;@JsonKey(name: 'payment_method') String? get paymentMethod; String? get status;@JsonKey(name: 'checkout_url') String? get checkoutUrl;@JsonKey(name: 'inquiry_id') int? get inquiryId; Package? get package; List<Scent>? get scents;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingReference, bookingReference) || other.bookingReference == bookingReference)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.pax, pax) || other.pax == pax)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.inquiryId, inquiryId) || other.inquiryId == inquiryId)&&(identical(other.package, package) || other.package == package)&&const DeepCollectionEquality().equals(other.scents, scents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingReference,userId,customerName,customerEmail,customerPhone,pax,eventDate,eventTime,venueAddress,paymentMethod,status,checkoutUrl,inquiryId,package,const DeepCollectionEquality().hash(scents));

@override
String toString() {
  return 'Booking(id: $id, bookingReference: $bookingReference, userId: $userId, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, pax: $pax, eventDate: $eventDate, eventTime: $eventTime, venueAddress: $venueAddress, paymentMethod: $paymentMethod, status: $status, checkoutUrl: $checkoutUrl, inquiryId: $inquiryId, package: $package, scents: $scents)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'booking_reference') String? bookingReference,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone, int? pax,@JsonKey(name: 'event_date') DateTime? eventDate,@JsonKey(name: 'event_time') String? eventTime,@JsonKey(name: 'venue_address') String? venueAddress,@JsonKey(name: 'payment_method') String? paymentMethod, String? status,@JsonKey(name: 'checkout_url') String? checkoutUrl,@JsonKey(name: 'inquiry_id') int? inquiryId, Package? package, List<Scent>? scents
});


$PackageCopyWith<$Res>? get package;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? bookingReference = freezed,Object? userId = freezed,Object? customerName = freezed,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? pax = freezed,Object? eventDate = freezed,Object? eventTime = freezed,Object? venueAddress = freezed,Object? paymentMethod = freezed,Object? status = freezed,Object? checkoutUrl = freezed,Object? inquiryId = freezed,Object? package = freezed,Object? scents = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,bookingReference: freezed == bookingReference ? _self.bookingReference : bookingReference // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,pax: freezed == pax ? _self.pax : pax // ignore: cast_nullable_to_non_nullable
as int?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String?,venueAddress: freezed == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,inquiryId: freezed == inquiryId ? _self.inquiryId : inquiryId // ignore: cast_nullable_to_non_nullable
as int?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as Package?,scents: freezed == scents ? _self.scents : scents // ignore: cast_nullable_to_non_nullable
as List<Scent>?,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackageCopyWith<$Res>? get package {
    if (_self.package == null) {
    return null;
  }

  return $PackageCopyWith<$Res>(_self.package!, (value) {
    return _then(_self.copyWith(package: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'booking_reference')  String? bookingReference, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone,  int? pax, @JsonKey(name: 'event_date')  DateTime? eventDate, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'venue_address')  String? venueAddress, @JsonKey(name: 'payment_method')  String? paymentMethod,  String? status, @JsonKey(name: 'checkout_url')  String? checkoutUrl, @JsonKey(name: 'inquiry_id')  int? inquiryId,  Package? package,  List<Scent>? scents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.bookingReference,_that.userId,_that.customerName,_that.customerEmail,_that.customerPhone,_that.pax,_that.eventDate,_that.eventTime,_that.venueAddress,_that.paymentMethod,_that.status,_that.checkoutUrl,_that.inquiryId,_that.package,_that.scents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'booking_reference')  String? bookingReference, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone,  int? pax, @JsonKey(name: 'event_date')  DateTime? eventDate, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'venue_address')  String? venueAddress, @JsonKey(name: 'payment_method')  String? paymentMethod,  String? status, @JsonKey(name: 'checkout_url')  String? checkoutUrl, @JsonKey(name: 'inquiry_id')  int? inquiryId,  Package? package,  List<Scent>? scents)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.bookingReference,_that.userId,_that.customerName,_that.customerEmail,_that.customerPhone,_that.pax,_that.eventDate,_that.eventTime,_that.venueAddress,_that.paymentMethod,_that.status,_that.checkoutUrl,_that.inquiryId,_that.package,_that.scents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'booking_reference')  String? bookingReference, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone,  int? pax, @JsonKey(name: 'event_date')  DateTime? eventDate, @JsonKey(name: 'event_time')  String? eventTime, @JsonKey(name: 'venue_address')  String? venueAddress, @JsonKey(name: 'payment_method')  String? paymentMethod,  String? status, @JsonKey(name: 'checkout_url')  String? checkoutUrl, @JsonKey(name: 'inquiry_id')  int? inquiryId,  Package? package,  List<Scent>? scents)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.bookingReference,_that.userId,_that.customerName,_that.customerEmail,_that.customerPhone,_that.pax,_that.eventDate,_that.eventTime,_that.venueAddress,_that.paymentMethod,_that.status,_that.checkoutUrl,_that.inquiryId,_that.package,_that.scents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({this.id, @JsonKey(name: 'booking_reference') this.bookingReference, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'customer_name') this.customerName, @JsonKey(name: 'customer_email') this.customerEmail, @JsonKey(name: 'customer_phone') this.customerPhone, this.pax, @JsonKey(name: 'event_date') this.eventDate, @JsonKey(name: 'event_time') this.eventTime, @JsonKey(name: 'venue_address') this.venueAddress, @JsonKey(name: 'payment_method') this.paymentMethod, this.status, @JsonKey(name: 'checkout_url') this.checkoutUrl, @JsonKey(name: 'inquiry_id') this.inquiryId, this.package, final  List<Scent>? scents}): _scents = scents;
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  int? id;
@override@JsonKey(name: 'booking_reference') final  String? bookingReference;
@override@JsonKey(name: 'user_id') final  int? userId;
@override@JsonKey(name: 'customer_name') final  String? customerName;
@override@JsonKey(name: 'customer_email') final  String? customerEmail;
@override@JsonKey(name: 'customer_phone') final  String? customerPhone;
@override final  int? pax;
@override@JsonKey(name: 'event_date') final  DateTime? eventDate;
@override@JsonKey(name: 'event_time') final  String? eventTime;
@override@JsonKey(name: 'venue_address') final  String? venueAddress;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;
@override final  String? status;
@override@JsonKey(name: 'checkout_url') final  String? checkoutUrl;
@override@JsonKey(name: 'inquiry_id') final  int? inquiryId;
@override final  Package? package;
 final  List<Scent>? _scents;
@override List<Scent>? get scents {
  final value = _scents;
  if (value == null) return null;
  if (_scents is EqualUnmodifiableListView) return _scents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingReference, bookingReference) || other.bookingReference == bookingReference)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.pax, pax) || other.pax == pax)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl)&&(identical(other.inquiryId, inquiryId) || other.inquiryId == inquiryId)&&(identical(other.package, package) || other.package == package)&&const DeepCollectionEquality().equals(other._scents, _scents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingReference,userId,customerName,customerEmail,customerPhone,pax,eventDate,eventTime,venueAddress,paymentMethod,status,checkoutUrl,inquiryId,package,const DeepCollectionEquality().hash(_scents));

@override
String toString() {
  return 'Booking(id: $id, bookingReference: $bookingReference, userId: $userId, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, pax: $pax, eventDate: $eventDate, eventTime: $eventTime, venueAddress: $venueAddress, paymentMethod: $paymentMethod, status: $status, checkoutUrl: $checkoutUrl, inquiryId: $inquiryId, package: $package, scents: $scents)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'booking_reference') String? bookingReference,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone, int? pax,@JsonKey(name: 'event_date') DateTime? eventDate,@JsonKey(name: 'event_time') String? eventTime,@JsonKey(name: 'venue_address') String? venueAddress,@JsonKey(name: 'payment_method') String? paymentMethod, String? status,@JsonKey(name: 'checkout_url') String? checkoutUrl,@JsonKey(name: 'inquiry_id') int? inquiryId, Package? package, List<Scent>? scents
});


@override $PackageCopyWith<$Res>? get package;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? bookingReference = freezed,Object? userId = freezed,Object? customerName = freezed,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? pax = freezed,Object? eventDate = freezed,Object? eventTime = freezed,Object? venueAddress = freezed,Object? paymentMethod = freezed,Object? status = freezed,Object? checkoutUrl = freezed,Object? inquiryId = freezed,Object? package = freezed,Object? scents = freezed,}) {
  return _then(_Booking(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,bookingReference: freezed == bookingReference ? _self.bookingReference : bookingReference // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,pax: freezed == pax ? _self.pax : pax // ignore: cast_nullable_to_non_nullable
as int?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as String?,venueAddress: freezed == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,inquiryId: freezed == inquiryId ? _self.inquiryId : inquiryId // ignore: cast_nullable_to_non_nullable
as int?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as Package?,scents: freezed == scents ? _self._scents : scents // ignore: cast_nullable_to_non_nullable
as List<Scent>?,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackageCopyWith<$Res>? get package {
    if (_self.package == null) {
    return null;
  }

  return $PackageCopyWith<$Res>(_self.package!, (value) {
    return _then(_self.copyWith(package: value));
  });
}
}

// dart format on
