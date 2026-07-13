import 'package:flutter/material.dart';

import '../../core/constants/avatar_constants.dart';

class AvatarGrid extends StatelessWidget {
  const AvatarGrid({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
    this.avatars = AvatarConstants.avatars,
  });

  final String? selectedAvatarId;
  final ValueChanged<String> onAvatarSelected;
  final List<AvatarItem> avatars;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: avatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final avatar = avatars[index];

        final bool selected = avatar.id == selectedAvatarId;

        return GestureDetector(
          onTap: () => onAvatarSelected(avatar.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? const Color(0xFF4C8DFF) : Colors.transparent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Image.asset(avatar.asset, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
