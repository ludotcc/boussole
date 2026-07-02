import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/boussole_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const ProviderScope(child: BoussoleApp()));
}

class BoussoleApp extends StatelessWidget {
  const BoussoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Boussole',
      theme: BoussoleTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
