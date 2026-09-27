import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/index.dart';
import '../models/index.dart';
import '../widgets/index.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // You can add auth checks here if needed
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          verified: state.queryParameters['verified'] == '1',
        ),
      ),
      // C38: scaffolded edit-profile form (submit disabled, C14 open).
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          initialEmail: state.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          initialEmail: state.queryParameters['email'] ?? '',
        ),
      ),
      // C23: stateful tabs — each tab keeps its own stack, so switching
      // tabs never resets the other tabs. Platform page transitions come
      // from AppTheme.pageTransitionsTheme (Cupertino iOS / Zoom Android /
      // cross-fade desktop); tab switches via goBranch are instant.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ResponsiveAppShell(
          themeToggle: const ConnectedThemeToggleButton(inverted: true),
          navigationShell: navigationShell,
          child: const SizedBox.shrink(),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/packages',
                builder: (context, state) {
                  final initialDate = tryParseDateParam(
                    state.queryParameters['date'],
                  );
                  return PackagesScreen(initialDate: initialDate);
                },
              ),
              GoRoute(
                path: '/booking/:id',
                builder: (context, state) {
                  final packageId = int.parse(state.pathParameters['id']!);
                  final initialPax = int.tryParse(
                    state.queryParameters['pax'] ?? '',
                  );
                  final initialDate = tryParseDateParam(
                    state.queryParameters['date'],
                  );
                  return BookingScreen(
                    packageId: packageId,
                    initialPax: initialPax,
                    initialDate: initialDate,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const MyBookingsScreen(),
              ),
              GoRoute(
                path: '/bookings/:id',
                builder: (context, state) {
                  final bookingId = int.tryParse(
                    state.pathParameters['id'] ?? '',
                  );
                  if (bookingId == null) return const MyBookingsScreen();
                  return BookingDetailScreen(bookingId: bookingId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              // C39: scaffold only — form ships disabled, C15 wires submit.
              GoRoute(
                path: '/profile/password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider((ref) => AppRouter.router);
