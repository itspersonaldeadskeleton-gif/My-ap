import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../../features/wardrobe/presentation/add_item_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/questionnaire/presentation/plan_intro_screen.dart';
import '../../features/questionnaire/presentation/questionnaire_screen.dart';
import '../../features/recommendation/presentation/recommendation_screen.dart';
import '../../features/profile/presentation/trip_packing_screen.dart';
import '../../features/styling_guide/domain/guide_args.dart';
import '../../features/styling_guide/presentation/final_look_screen.dart';
import '../../features/styling_guide/presentation/styling_guide_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';

part 'app_router.g.dart';

/// Central route table. Four tabs share a bottom NavigationBar and keep
/// their own state (indexedStack). Full-screen flows (questionnaire pages,
/// styling guide) will be added as top-level routes in later steps.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
      initialLocation: '/wardrobe',
      routes: [
        // Full-screen add / edit flow, outside the tab shell.
        GoRoute(
          path: '/add',
          builder: (_, state) => AddItemScreen(existing: state.extra as WardrobeItem?),
        ),
        GoRoute(path: '/trip', builder: (_, __) => const TripPackingScreen()),
        GoRoute(path: '/styling', builder: (_, s) => _withArgs(s, (a) => StylingGuideScreen(args: a))),
        GoRoute(path: '/final-look', builder: (_, s) => _withArgs(s, (a) => FinalLookScreen(args: a))),
        GoRoute(path: '/questionnaire', builder: (_, __) => const QuestionnaireScreen()),
        GoRoute(path: '/recommendation', builder: (_, __) => const RecommendationScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/plan', builder: (_, __) => const PlanIntroScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
            ]),
          ],
        ),
      ],
    );

/// Scaffold with the bottom navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checkroom_outlined), selectedIcon: Icon(Icons.checkroom), label: 'Wardrobe'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Guide routes need the chosen outfit passed as `extra`.
Widget _withArgs(GoRouterState s, Widget Function(StylingGuideArgs) build) {
  final a = s.extra;
  return a is StylingGuideArgs
      ? build(a)
      : const Scaffold(body: Center(child: Text('Open this from your outfit results.')));
}
