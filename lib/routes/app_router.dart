import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/create_child_page.dart';
import '../pages/create_adult_page.dart';
import '../pages/child_selector_page.dart';
import '../pages/create_family_page.dart';
import '../pages/create_moment_settings_page.dart';
import '../pages/child_routine_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/day_planner_page.dart';
import '../pages/edit_moment_page.dart';
import '../pages/family_agenda_page.dart';
import '../pages/family_event_form_page.dart';
import '../pages/family_members_page.dart';
import '../pages/family_members_management_page.dart';
import '../pages/family_settings_page.dart';
import '../pages/device_mode_settings_page.dart';
import '../pages/house_page.dart';
import '../pages/login_page.dart';
import '../pages/member_detail_page.dart';
import '../pages/moment_routines_page.dart';
import '../pages/parent_space_page.dart';
import '../pages/parent_unlock_page.dart';
import '../pages/routine_steps_page.dart';
import '../pages/select_avatar_page.dart';
import '../pages/select_child_avatar_page.dart';
import '../pages/select_moment_page.dart';
import '../pages/splash_page.dart';
import '../pages/today_page.dart';
import '../pages/welcome_page.dart';
import '../models/moment_model.dart';
import '../models/family_event_model.dart';
import '../models/family_member_model.dart';
import '../models/routine_model.dart';
import '../providers/device_mode_provider.dart';
import '../providers/parent_access_provider.dart';
import '../providers/session_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(sessionProvider, (_, _) => refreshNotifier.refresh());
  ref.listen(deviceConfigurationProvider, (_, _) => refreshNotifier.refresh());
  ref.listen(parentAccessProvider, (_, _) => refreshNotifier.refresh());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final path = state.uri.path;
      final session = ref.read(sessionProvider);
      final configurationAsync = ref.read(deviceConfigurationProvider);
      final parentAccess = ref.read(parentAccessProvider);

      if (path == '/') return null;

      const publicPaths = {'/welcome', '/login', '/create-family'};

      if (session == null) {
        return publicPaths.contains(path) ? null : '/welcome';
      }

      final configuration = configurationAsync.valueOrNull;
      const onboardingPaths = {
        '/family-members',
        '/create-child',
        '/create-adult',
        '/select-avatar',
        '/select-child-avatar',
      };
      if (configuration == null) {
        return onboardingPaths.contains(path) ? null : '/';
      }

      if (path == '/parent-unlock') {
        if (!configuration.isChildMode || !parentAccess.isLocked) {
          return '/home';
        }
        return null;
      }

      final isChildPath = path == '/child-select' || path.startsWith('/child/');
      if (isChildPath) {
        final childId = _childIdFromPath(path);
        if (childId != null && !configuration.canOpenChild(childId)) {
          return configuration.isChildMode ? '/child-select' : '/home';
        }
        return null;
      }

      if (configuration.isChildMode && parentAccess.isLocked) {
        return '/parent-unlock';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashPage()),

      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),

      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),

      GoRoute(
        path: '/create-family',
        builder: (_, _) => const CreateFamilyPage(),
      ),

      GoRoute(
        path: '/select-avatar',
        builder: (_, _) => const SelectAvatarPage(isParent: true),
      ),

      GoRoute(
        path: '/create-child',
        builder: (_, _) => const CreateChildPage(),
      ),

      GoRoute(
        path: '/create-adult',
        builder: (_, _) => const CreateAdultPage(),
      ),

      GoRoute(
        path: '/family-members',
        builder: (_, _) => const FamilyMembersPage(),
      ),

      GoRoute(
        path: '/select-child-avatar',
        builder: (_, _) => const SelectChildAvatarPage(),
      ),

      GoRoute(path: '/home', builder: (_, _) => const DashboardPage()),

      GoRoute(
        path: '/device-mode-settings',
        builder: (_, _) => const DeviceModeSettingsPage(),
      ),

      GoRoute(
        path: '/parent-unlock',
        builder: (_, _) => const ParentUnlockPage(),
      ),

      GoRoute(
        path: '/child-select',
        builder: (_, _) => const ChildSelectorPage(),
      ),

      GoRoute(
        path: '/child/:childId/house',
        builder: (_, state) =>
            HousePage(childId: state.pathParameters['childId']!),
      ),

      GoRoute(
        path: '/child/:childId/today',
        builder: (_, state) =>
            TodayPage(childId: state.pathParameters['childId']!),
      ),

      GoRoute(
        path: '/child/:childId/routine',
        builder: (_, state) {
          final args = state.extra;
          if (args is! ChildRoutinePageArgs) {
            return TodayPage(childId: state.pathParameters['childId']);
          }
          return ChildRoutinePage(args: args);
        },
      ),

      GoRoute(
        path: '/members',
        builder: (_, _) => const FamilyMembersManagementPage(),
      ),

      GoRoute(
        path: '/member-detail',
        builder: (_, state) {
          final member = state.extra;

          if (member is! FamilyMemberModel) {
            return const FamilyMembersManagementPage();
          }

          return MemberDetailPage(member: member);
        },
      ),

      GoRoute(
        path: '/family-settings',
        builder: (_, _) => const FamilySettingsPage(),
      ),

      GoRoute(
        path: '/family-agenda',
        builder: (_, _) => const FamilyAgendaPage(),
      ),

      GoRoute(
        path: '/parent-space',
        builder: (_, state) {
          final member = state.extra;

          if (member is! FamilyMemberModel || !member.isAdult) {
            return const DashboardPage();
          }

          return ParentSpacePage(
            parentId: member.id,
            parentName: member.firstName,
          );
        },
      ),

      GoRoute(
        path: '/family-event-form',
        builder: (_, state) {
          final event = state.extra;

          return FamilyEventFormPage(
            event: event is FamilyEventModel ? event : null,
          );
        },
      ),

      GoRoute(path: '/planner', builder: (_, _) => const DayPlannerPage()),

      GoRoute(
        path: '/today',
        builder: (_, state) {
          final childId = state.extra;

          return TodayPage(childId: childId is String ? childId : null);
        },
      ),

      GoRoute(
        path: '/select-moment',
        builder: (_, _) => const SelectMomentPage(),
      ),

      GoRoute(
        path: '/create-moment-settings',
        builder: (_, state) {
          final args = state.extra;

          if (args is! CreateMomentSettingsArgs) {
            return const SelectMomentPage();
          }

          return CreateMomentSettingsPage(args: args);
        },
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

      GoRoute(
        path: '/child-routine',
        builder: (_, state) {
          final args = state.extra;

          if (args is! ChildRoutinePageArgs) {
            return const TodayPage();
          }

          return ChildRoutinePage(args: args);
        },
      ),
    ],
  );
});

String? _childIdFromPath(String path) {
  final segments = Uri.parse(path).pathSegments;
  if (segments.length < 2 || segments.first != 'child') return null;
  return segments[1];
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
