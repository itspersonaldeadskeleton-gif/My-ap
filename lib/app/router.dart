import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/home_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import '../features/style/style_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/onboarding/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!onboardingCompleted && state.uri.path != '/onboarding') {
      return '/onboarding';
    }
    if (onboardingCompleted && state.uri.path == '/onboarding') {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeScreen()),
        GoRoute(path: '/style', builder: (_, __) => const StyleScreen()),
        GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checkroom_outlined), label: 'Wardrobe'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Style'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onDestinationSelected: (i) {
          const paths = ['/', '/wardrobe', '/style', '/calendar', '/profile'];
          context.go(paths[i]);
        },
      ),
    );
  }
}
