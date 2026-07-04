import 'package:go_router/go_router.dart';

import '../pages/create_child_page.dart';
import '../pages/create_family_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/day_planner_page.dart';
import '../pages/edit_moment_page.dart';
import '../pages/login_page.dart';
import '../pages/moment_routines_page.dart';
import '../pages/routine_steps_page.dart';
import '../pages/select_avatar_page.dart';
import '../pages/select_child_avatar_page.dart';
import '../pages/select_moment_type_page.dart';
import '../pages/splash_page.dart';
import '../pages/today_page.dart';
import '../pages/welcome_page.dart';
import '../models/moment_model.dart';
import '../models/routine_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),

    GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),

    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

    GoRoute(
      path: '/create-family',
      builder: (_, __) => const CreateFamilyPage(),
    ),

    GoRoute(
      path: '/select-avatar',
      builder: (_, __) => const SelectAvatarPage(isParent: true),
    ),

    GoRoute(path: '/create-child', builder: (_, __) => const CreateChildPage()),

    GoRoute(
      path: '/select-child-avatar',
      builder: (_, __) => const SelectChildAvatarPage(),
    ),

    GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),

    GoRoute(path: '/planner', builder: (_, __) => const DayPlannerPage()),

    GoRoute(path: '/today', builder: (_, __) => const TodayPage()),

    GoRoute(
      path: '/select-moment',
      builder: (_, __) => const SelectMomentTypePage(),
    ),

    GoRoute(
      path: '/edit-moment',
      builder: (_, state) {
        final moment = state.extra;

        if (moment is! MomentModel) {
          return const DayPlannerPage();
        }

        return EditMomentPage(moment: moment);
      },
    ),

    GoRoute(
      path: '/moment-routines',
      builder: (_, state) {
        final moment = state.extra;

        if (moment is! MomentModel) {
          return const DayPlannerPage();
        }

        return MomentRoutinesPage(moment: moment);
      },
    ),

    GoRoute(
      path: '/routine-steps',
      builder: (_, state) {
        final routine = state.extra;

        if (routine is! RoutineModel) {
          return const DayPlannerPage();
        }

        return RoutineStepsPage(routine: routine);
      },
    ),
  ],
);
