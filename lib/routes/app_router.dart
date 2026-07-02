import 'package:go_router/go_router.dart';

import '../pages/create_child_page.dart';
import '../pages/create_family_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/login_page.dart';
import '../pages/select_avatar_page.dart';
import '../pages/select_child_avatar_page.dart';
import '../pages/splash_page.dart';
import '../pages/welcome_page.dart';

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
  ],
);
