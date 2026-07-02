import 'package:go_router/go_router.dart';

import '../pages/accueil_page.dart';
import '../pages/splash_page.dart';
import '../pages/welcome_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),

    GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),

    GoRoute(path: '/home', builder: (_, __) => const AccueilPage()),
  ],
);
