import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';
import '../config/privacy.dart';
import 'package:dio/dio.dart';
import '../src/providers/core_providers.dart';
import '../src/services/token_storage.dart';

String _getErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not connect to the server. Please check your internet connection.';
    }
    if (e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'The request is taking too long. Please try again.';
    }
    if (e.response != null) {
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      }
      return 'Server error: \${e.response?.statusCode}';
    }
    return e.message ?? 'An unexpected network error occurred';
  }
  return e.toString();
}

// Theme state. Storage key shared with the web surfaces (`inea-theme`).
// No System option: a stored light/dark choice wins, otherwise the OS
// brightness resolves once at startup (see main), like the landing toggle.
const ineaThemeKey = 'inea-theme';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Reads the persisted theme, if any. Returns null on first launch.
Future<ThemeMode?> loadPersistedThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(ineaThemeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

// Auth state
class AuthState {
  final bool isLoggedIn;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.isLoggedIn = false,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final RestClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._apiClient, this._tokenStorage) : super(AuthState());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.auth.postApiRegister(
        body: ApiRegisterRequestBody(
          name: name,
          email: email,
          password: password,
        ),
      );
      // C159: register issues no session (pending verification) — stay
      // logged out so the screen routes to /verify-email instead of /home.
      state = state.copyWith(
        isLoggedIn: false,
        user: response.user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.auth.postApiLogin(
        body: ApiLoginRequestBody(email: email, password: password),
      );
      if (response.accessToken != null) {
        await _tokenStorage.saveToken(response.accessToken!);
      }
      state = state.copyWith(
        isLoggedIn: true,
        user: response.user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    // C159: revoke the server session first; local sign-out always runs
    // so offline logout still works (a dead token is useless anyway).
    try {
      await _apiClient.auth.postApiLogout();
    } catch (_) {
      // Best-effort: fall through to local cleanup.
    }
    await _tokenStorage.deleteToken();
    state = AuthState();
  }

  Future<void> refreshProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _apiClient.auth.getApiUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user, errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(apiClient, tokenStorage);
});

// Packages providers
final packagesProvider = FutureProvider<List<Package>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.packages.getApiPackages();
  return response.data ?? [];
});

final packageDetailsProvider = FutureProvider.family<Package, int>((
  ref,
  packageId,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.packages.getApiPackagesPackage(
    package: packageId,
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Package $packageId not found');
  }
  return data;
});

// Availability provider
class AvailabilityState {
  final int month;
  final int year;
  final List<Availability> data;

  AvailabilityState({
    required this.month,
    required this.year,
    required this.data,
  });
}

class AvailabilityNotifier extends AsyncNotifier<AvailabilityState> {
  @override
  Future<AvailabilityState> build() async {
    final now = DateTime.now();
    return _fetch(now.month, now.year);
  }

  Future<AvailabilityState> _fetch(int month, int year) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.availability.getApiAvailability(
      month: month,
      year: year,
    );
    return AvailabilityState(month: month, year: year, data: response);
  }

  void nextMonth() async {
    final current = state.value;
    if (current == null) return;
    int nextM = current.month + 1;
    int nextY = current.year;
    if (nextM > 12) {
      nextM = 1;
      nextY++;
    }
    state = const AsyncLoading<AvailabilityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(nextM, nextY));
  }

  void previousMonth() async {
    final current = state.value;
    if (current == null) return;
    int prevM = current.month - 1;
    int prevY = current.year;
    if (prevM < 1) {
      prevM = 12;
      prevY--;
    }
    state = const AsyncLoading<AvailabilityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(prevM, prevY));
  }

  void setMonth(int month, int year) async {
    final current = state.value;
    if (current != null && current.month == month && current.year == year) {
      return;
    }
    state = const AsyncLoading<AvailabilityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(month, year));
  }

  void refresh() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncLoading<AvailabilityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(current.month, current.year));
  }
}

final availabilityProvider =
    AsyncNotifierProvider<AvailabilityNotifier, AvailabilityState>(
      AvailabilityNotifier.new,
    );

// Bookings provider
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  // C98: re-scope the cached list whenever the signed-in identity changes,
  // so logout → login as a different User refetches instead of serving the
  // previous User's cached Bookings.
  ref.watch(authProvider.select((auth) => auth.user?.id));
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.bookings.getApiBookings();
  return response.data ?? [];
});

// Booking flow state
enum BookingCheckoutStatus {
  idle,
  awaitingPayment,
  awaitingAdmin,
  confirmed,
  cancelled,
}

class BookingFlowState {
  final Package? selectedPackage;
  final DateTime? selectedDate;
  final String? selectedTime;
  final int? selectedPax;
  final List<int> selectedScentIds;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? venueAddress;
  final String? paymentMethod;
  final bool isLoading;
  final String? errorMessage;
  final int currentStep;
  final Booking? booking;
  final BookingCheckoutStatus checkoutStatus;

  BookingFlowState({
    this.selectedPackage,
    this.selectedDate,
    this.selectedTime,
    this.selectedPax,
    this.selectedScentIds = const [],
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.venueAddress,
    this.paymentMethod,
    this.isLoading = false,
    this.errorMessage,
    this.currentStep = 2,
    this.booking,
    this.checkoutStatus = BookingCheckoutStatus.idle,
  });

  BookingFlowState copyWith({
    Package? selectedPackage,
    DateTime? selectedDate,
    String? selectedTime,
    int? selectedPax,
    List<int>? selectedScentIds,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? venueAddress,
    String? paymentMethod,
    bool? isLoading,
    String? errorMessage,
    int? currentStep,
    Booking? booking,
    BookingCheckoutStatus? checkoutStatus,
  }) {
    return BookingFlowState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedPax: selectedPax ?? this.selectedPax,
      selectedScentIds: selectedScentIds ?? this.selectedScentIds,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      venueAddress: venueAddress ?? this.venueAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
      booking: booking ?? this.booking,
      checkoutStatus: checkoutStatus ?? this.checkoutStatus,
    );
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  final Ref _ref;
  final RestClient _apiClient;
  Timer? _pollTimer;

  BookingFlowNotifier(this._ref, this._apiClient)
    : super(BookingFlowState(currentStep: 2));

  /// Refreshes the cached bookings list after checkout resolves. The poll
  /// loop reads `_apiClient` directly, so invalidating mid-poll is safe.
  void _refreshBookingsList() {
    _ref.invalidate(bookingsProvider);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 2) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step.clamp(2, 5));
  }

  /// C60: an in-progress auto-draft — a chosen package, date, or Pax Choice
  /// on a non-terminal checkout. Reopening the flow resumes [resumeStage].
  bool get hasDraft =>
      (state.selectedPackage != null ||
          state.selectedDate != null ||
          state.selectedPax != null) &&
      state.checkoutStatus == BookingCheckoutStatus.idle &&
      state.booking == null;

  /// C60: the exact wizard stage a reopened draft resumes at — the stored
  /// step, clamped to the wizard (2 Schedule, 3 Details, 4 Payment); an
  /// in-flight checkout (5) stays put; no draft defaults to stage 1 (2).
  int get resumeStage {
    if (state.currentStep == 5) return 5;
    if (!hasDraft) return 2;
    return state.currentStep.clamp(2, 4);
  }

  bool canProceedFromSchedule() {
    return state.selectedDate != null &&
        state.selectedPax != null &&
        state.selectedTime != null;
  }

  bool canProceedFromDetails() {
    final nameOk = (state.customerName ?? '').trim().isNotEmpty;
    final email = (state.customerEmail ?? '').trim();
    final venueOk = (state.venueAddress ?? '').trim().isNotEmpty;
    return nameOk && venueOk && email.isNotEmpty && isValidEmail(email);
  }

  void setSelectedPackage(Package package) {
    int? defaultPax = 1;
    if (package.paxOptions != null && package.paxOptions!.isNotEmpty) {
      if (!package.paxOptions!.contains(1)) {
        defaultPax = package.paxOptions!.first;
      }
    }
    state = state.copyWith(selectedPackage: package, selectedPax: defaultPax);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  void setSelectedPax(int pax) {
    state = state.copyWith(selectedPax: pax);
  }

  void toggleScent(int scentId) {
    final scents = List<int>.from(state.selectedScentIds);
    if (scents.contains(scentId)) {
      scents.remove(scentId);
    } else {
      // C144: shelf cap — at most 4 scents per booking; extra taps ignored.
      if (scents.length >= 4) return;
      scents.add(scentId);
    }
    state = state.copyWith(selectedScentIds: scents);
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerEmail(String email) {
    state = state.copyWith(customerEmail: email);
  }

  void setCustomerPhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void setVenueAddress(String address) {
    state = state.copyWith(venueAddress: address);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void prefillFromUser(User? user) {
    if (user == null) return;
    state = state.copyWith(
      customerName: state.customerName ?? user.name,
      customerEmail: state.customerEmail ?? user.email,
    );
  }

  Future<Booking?> submitBooking() async {
    final email = state.customerEmail?.trim() ?? '';
    if (state.selectedPackage == null ||
        state.selectedDate == null ||
        state.selectedTime == null ||
        state.selectedPax == null ||
        (state.paymentMethod ?? '').isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please fill in all required fields',
      );
      return null;
    }
    if ((state.customerName ?? '').trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Customer name is required');
      return null;
    }
    if ((state.venueAddress ?? '').trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Event venue is required');
      return null;
    }
    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Email address is required');
      return null;
    }
    if (!isValidEmail(email)) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid email address',
      );
      return null;
    }

    final pkgId = state.selectedPackage?.id;
    if (pkgId == null) {
      state = state.copyWith(errorMessage: 'Selected package is invalid');
      return null;
    }
    // Pre-booking sanity gate: a corrupt package payload must never reach
    // POST / confirmation. Tolerant parsing already cleans most shapes, but
    // if pax options are missing/empty or the chosen pax isn't offered,
    // block here with a recoverable message instead of confirming garbage.
    final paxOptions = state.selectedPackage?.paxOptions;
    if (paxOptions == null ||
        paxOptions.isEmpty ||
        paxOptions.any((p) => p < 1) ||
        !paxOptions.contains(state.selectedPax)) {
      state = state.copyWith(
        errorMessage:
            'Selected package is unavailable, please choose another package',
      );
      return null;
    }
    _pollTimer?.cancel();
    state = state.copyWith(isLoading: true, errorMessage: null, booking: null);
    try {
      final response = await _apiClient.bookings.postApiBookings(
        body: ApiBookingsRequestBody(
          packageId: pkgId,
          customerName: state.customerName!.trim(),
          customerEmail: email,
          customerPhone: (state.customerPhone?.trim().isNotEmpty ?? false)
              ? state.customerPhone!.trim()
              : null,
          pax: state.selectedPax!,
          eventDate: state.selectedDate!,
          eventTime: TimeSlot.toEventTime(state.selectedTime),
          venueAddress: state.venueAddress!.trim(),
          paymentMethod: PaymentMethod.fromJson(state.paymentMethod!),
          scentIds: state.selectedScentIds.isNotEmpty
              ? state.selectedScentIds
              : null,
          // C159: booking consent pins the bundled policy version (server
          // rejects stale versions; bump privacy.dart with the backend).
          consentPrivacyVersion: privacyPolicyVersion,
        ),
      );

      final booking = response.data;
      if (booking == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'The server returned an empty response. Please try again.',
        );
        return null;
      }

      final method = state.paymentMethod!;
      final status = isOnlinePaymentString(method)
          ? BookingCheckoutStatus.awaitingPayment
          : BookingCheckoutStatus.awaitingAdmin;
      state = state.copyWith(
        isLoading: false,
        booking: booking,
        checkoutStatus: status,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
        checkoutStatus: BookingCheckoutStatus.idle,
      );
      return null;
    }
  }

  /// Polls `GET /api/bookings` until the created booking is confirmed or
  /// cancelled/expired. Re-arms every [interval] until [maxDuration], then
  /// runs one final reconcile: the checkout flips only on a resolved Status,
  /// never on a bare timeout, so a late PayMongo success can still flip the
  /// Booking off pending via `checkStatusImmediate`.
  Future<void> startPolling({
    Duration interval = const Duration(seconds: 3),
    Duration maxDuration = const Duration(minutes: 15),
  }) async {
    final bookingId = state.booking?.id;
    if (bookingId == null) return;

    _pollTimer?.cancel();
    final stopwatch = Stopwatch()..start();

    Future<void> poll() async {
      var resolved = false;
      try {
        final response = await _apiClient.bookings.getApiBookings();
        final matches = response.data?.where((b) => b.id == bookingId).toList();
        if (matches != null && matches.isNotEmpty) {
          final updated = matches.first;
          final status = (updated.status ?? '').toLowerCase();
          if (status == 'confirmed' || status == 'paid') {
            state = state.copyWith(
              booking: updated,
              checkoutStatus: BookingCheckoutStatus.confirmed,
            );
            resolved = true;
          } else if (status == 'cancelled' ||
              status == 'expired' ||
              status == 'canceled') {
            state = state.copyWith(
              booking: updated,
              checkoutStatus: BookingCheckoutStatus.cancelled,
            );
            resolved = true;
          }
        }
      } catch (_) {
        // Transient network/server error while polling — keep trying.
      }

      if (resolved) {
        _pollTimer?.cancel();
        _refreshBookingsList();
        return;
      }
      if (stopwatch.elapsed >= maxDuration) {
        _pollTimer?.cancel();
        // Final reconcile, not a verdict: a still-pending Booking keeps
        // waiting (the timer is spent, `checkStatusImmediate` stays
        // available), so only a resolved Status flips the checkout.
        await checkStatusImmediate();
        return;
      }
      _pollTimer = Timer(interval, poll);
    }

    await poll();
  }

  /// Fetches the current booking status exactly once and updates the checkout
  /// status only if it has resolved (confirmed/cancelled). If the booking is
  /// still pending it leaves the current status untouched, so the caller can
  /// keep waiting without ever forcing a false cancellation.
  Future<void> checkStatusImmediate() async {
    final bookingId = state.booking?.id;
    if (bookingId == null) return;

    try {
      final response = await _apiClient.bookings.getApiBookings();
      final matches = response.data?.where((b) => b.id == bookingId).toList();
      if (matches == null || matches.isEmpty) return;
      final updated = matches.first;
      final status = (updated.status ?? '').toLowerCase();
      if (status == 'confirmed' || status == 'paid') {
        state = state.copyWith(
          booking: updated,
          checkoutStatus: BookingCheckoutStatus.confirmed,
        );
        _refreshBookingsList();
      } else if (status == 'cancelled' ||
          status == 'expired' ||
          status == 'canceled') {
        state = state.copyWith(
          booking: updated,
          checkoutStatus: BookingCheckoutStatus.cancelled,
        );
        _refreshBookingsList();
      }
    } catch (_) {
      // Transient network/server error — the caller can retry.
    }
  }

  void rebook() {
    _pollTimer?.cancel();
    state = state.copyWith(
      booking: null,
      checkoutStatus: BookingCheckoutStatus.idle,
      errorMessage: null,
      isLoading: false,
      currentStep: 2,
    );
  }

  void reset() {
    _pollTimer?.cancel();
    state = BookingFlowState(currentStep: 2);
  }

  /// Drops stale flow state when entering a package booking screen.
  /// Resets on terminal checkout (confirmed/cancelled) or when the
  /// in-memory package differs from [packageId]. In-flight same-package
  /// flows are kept so calendar reads and checkout polling stay alive.
  void ensureFreshForPackage(int packageId) {
    final terminal =
        state.checkoutStatus == BookingCheckoutStatus.confirmed ||
        state.checkoutStatus == BookingCheckoutStatus.cancelled;
    final mismatch =
        state.selectedPackage != null && state.selectedPackage!.id != packageId;
    if (terminal || mismatch) reset();
  }
}

final bookingFlowProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return BookingFlowNotifier(ref, apiClient);
    });
