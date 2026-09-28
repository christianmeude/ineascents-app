import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/providers/index.dart';
import 'package:inea_scents_client/src/providers/core_providers.dart';
import 'package:inea_scents_client/src/services/token_storage.dart';

import 'helpers/fake_api.dart';

/// C98: Bookings isolation across account switch — logout → login as a
/// different User must show only the new User's Bookings with zero manual
/// refresh. The fake server has no per-User routing, so the test swaps
/// [FakeApiBackend.bookingsOverride] at the switch to simulate server-side
/// per-User scoping; the provider must refetch on identity change.
void main() {
  Map<String, Object?> userRow(
    FakeApiBackend backend, {
    required int id,
    required int userId,
    required String email,
    required String reference,
  }) =>
      {
        ...backend.bookingJson(status: 'confirmed'),
        'id': id,
        'user_id': userId,
        'customer_email': email,
        'booking_reference': reference,
      };

  Future<void> loginAs(
    ProviderContainer container,
    FakeApiBackend backend,
    String email,
  ) async {
    backend.registeredEmail = email;
    backend.verifiedEmails.add(email);
    await container.read(authProvider.notifier).login(
          email: email,
          password: 'secret-pass-1',
        );
  }

  test('logout then login as a different User refetches without refresh',
      () async {
    final backend = FakeApiBackend();
    final storage = _MemoryTokenStorage();
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(buildFakeRestClient(backend)),
        tokenStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    // User A signs in and loads their Bookings.
    backend.bookingsOverride = [
      userRow(backend,
          id: 1, userId: 1, email: 'a@example.com', reference: 'IN-A-1'),
    ];
    await loginAs(container, backend, 'a@example.com');
    var list = await container.read(bookingsProvider.future);
    expect(list.map((b) => b.bookingReference), ['IN-A-1']);
    expect(backend.bookingsEndpointCallCount, 1);

    // Account switch: logout clears the token, server now scopes to User B.
    await container.read(authProvider.notifier).logout();
    expect(await storage.readToken(), isNull);
    backend.bookingsOverride = [
      userRow(backend,
          id: 2, userId: 2, email: 'b@example.com', reference: 'IN-B-1'),
    ];

    // Login as B — the list must show only B's Bookings, zero manual refresh.
    await loginAs(container, backend, 'b@example.com');
    list = await container.read(bookingsProvider.future);
    expect(list.map((b) => b.bookingReference), ['IN-B-1']);
    expect(backend.bookingsEndpointCallCount, greaterThan(1));
  });
}

class _MemoryTokenStorage extends TokenStorage {
  String? token;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}
