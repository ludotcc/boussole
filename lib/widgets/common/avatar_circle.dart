import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    this.imagePath,
    this.radius = 32,
    this.backgroundColor,
    this.icon,
  });

  final String? imagePath;
  final double radius;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.cardSecondary,

      backgroundImage: hasImage
          ? AssetImage('assets/images/avatars/$imagePath.png')
          : null,

      child: hasImage
          ? null
          : Icon(icon ?? Icons.person, size: radius, color: AppColors.primary),
    );
  }
}
