import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoussoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BoussoleAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.fallbackLocation,
    this.actions,
  });

  final String title;
  final bool showBackButton;
  final String? fallbackLocation;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final canGoBack =
        showBackButton && (context.canPop() || fallbackLocation != null);

    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else if (fallbackLocation != null) {
                  context.go(fallbackLocation!);
                }
              },
            )
          : null,
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
