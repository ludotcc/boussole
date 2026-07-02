import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class ParentAvatar extends StatelessWidget {
  const ParentAvatar({super.key, required this.avatar, this.radius = 34});

  final String? avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatar != null && avatar!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.cardSecondary,
      backgroundImage: hasAvatar
          ? AssetImage('assets/images/avatars/$avatar.png')
          : null,
      child: hasAvatar
          ? null
          : Icon(Icons.person, size: radius, color: AppColors.primary),
    );
  }
}
