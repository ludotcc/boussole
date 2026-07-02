import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_router.dart';
import 'app_theme.dart';

class BoussoleApp extends ConsumerWidget {
  const BoussoleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Boussole',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
