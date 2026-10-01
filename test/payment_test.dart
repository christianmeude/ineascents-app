import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/api/export.dart';
import 'package:inea_scents_client/config/privacy.dart';
import 'package:inea_scents_client/models/payment.dart';

void main() {
  group('isOnlinePayment', () {
    test('returns true for online wallet/checkout methods', () {
      expect(isOnlinePayment(PaymentMethod.online), isTrue);
    });

    test('returns false for offline methods', () {
      expect(isOnlinePayment(PaymentMethod.cash), isFalse);
    });
  });

  group('isOnlinePaymentString', () {
    test('returns true for online wallet/checkout methods', () {
      expect(isOnlinePaymentString('online'), isTrue);
    });

    test('returns false for offline, retired and unknown methods', () {
      expect(isOnlinePaymentString('cash'), isFalse);
      expect(isOnlinePaymentString('bank_transfer'), isFalse);
      expect(isOnlinePaymentString('credit_card'), isFalse);
      expect(isOnlinePaymentString('gcash'), isFalse);
      expect(isOnlinePaymentString('maya'), isFalse);
      expect(isOnlinePaymentString('card'), isFalse);
      expect(isOnlinePaymentString(null), isFalse);
    });
  });

  group('online payment_method wire contract (C10)', () {
    test("fromJson('online') resolves to PaymentMethod.online", () {
      expect(PaymentMethod.fromJson('online'), PaymentMethod.online);
    });

    test("fromJson('cash') resolves to PaymentMethod.cash", () {
      expect(PaymentMethod.fromJson('cash'), PaymentMethod.cash);
    });

    test('request body serializes online as "online", never "\$unknown"', () {
      final body = ApiBookingsRequestBody(
        packageId: 1,
        customerName: 'Maria Santos',
        customerEmail: 'maria@example.com',
        pax: 50,
        eventDate: DateTime.utc(2026, 10, 1),
        venueAddress: 'Makati',
        paymentMethod: PaymentMethod.fromJson('online'),
        consentPrivacyVersion: privacyPolicyVersion,
      );
      final json = body.toJson();
      expect(json['payment_method'], 'online');
    });
  });

  group('isValidEmail', () {
    test('returns true for valid emails', () {
      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('maria.santos@gmail.com'), isTrue);
      expect(isValidEmail('user+tag@domain.ph'), isTrue);
    });

    test('returns false for invalid emails', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('notanemail'), isFalse);
      expect(isValidEmail('missing@'), isFalse);
      expect(isValidEmail('@domain.com'), isFalse);
    });
  });
}

