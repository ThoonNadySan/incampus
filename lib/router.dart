import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incampus/core/providers/auth_provider.dart';
import 'package:incampus/features/auth/login_screen.dart';
import 'package:incampus/features/auth/signup_screen.dart';
import 'package:incampus/features/auth/forgot_password_screen.dart';
import 'package:incampus/features/auth/subscriptions_screen.dart';
import 'package:incampus/features/home/home_screen.dart';
import 'package:incampus/features/home/edit_profile_screen.dart';
import 'package:incampus/features/event_detail/event_detail_screen.dart';
import 'package:incampus/features/landing/landing_page.dart';

enum RouteNames {
  landing,
  login,
  signup,
  subscriptions,
  home,
  eventDetail,
}

// Router provider for managing navigation based on auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: GoRouterRefreshStream(
      authState.whenData((user) => user),
    ),
    redirect: (context, state) {
      final user = authState.value;

      final isOnLanding = state.matchedLocation == '/landing';
      final isOnLogin = state.matchedLocation == '/login';
      final isOnSignup = state.matchedLocation == '/signup';

      // 🔓 If NOT logged in
      if (user == null) {
        // Allow landing + auth pages
        if (isOnLanding || isOnLogin || isOnSignup) {
          return null;
        }
        return '/landing'; // 👈 go to landing
      }

      // 🔐 If logged in
      if (isOnLanding || isOnLogin || isOnSignup) {
        return '/home'; // 👈 go to home after login
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/landing',
        name: RouteNames.landing.name,
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup.name,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) {
          final email = state.extra as String?;
          return ForgotPasswordScreen(initialEmail: email);
        },
      ),
      GoRoute(
        path: '/subscriptions',
        name: RouteNames.subscriptions.name,
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) {
          final showPwd = state.uri.queryParameters['password'] == 'true';
          return EditProfileScreen(showPasswordSection: showPwd);
        },
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home.name,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'event-detail/:id',
            name: RouteNames.eventDetail.name,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return EventDetailScreen(eventId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});

// Helper class for refreshing router on auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(dynamic stream) {
    notifyListeners();
    if (stream is Stream) {
      _subscription = stream.asBroadcastStream().listen(
            (_) => notifyListeners(),
          );
    }
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
