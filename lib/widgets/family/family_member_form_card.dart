import 'package:flutter/material.dart';

import '../../core/constants/avatar_constants.dart';
import '../avatar/avatar_grid.dart';
import '../boussole_button.dart';
import '../common/app_card.dart';

class FamilyMemberFormCard extends StatelessWidget {
  const FamilyMemberFormCard({
    super.key,
    required this.firstNameController,
    required this.ageController,
    required this.birthDate,
    required this.profileType,
    required this.selectedAvatar,
    required this.isLoading,
    required this.onProfileTypeChanged,
    required this.onAvatarSelected,
    required this.onBirthDateTap,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController firstNameController;
  final TextEditingController ageController;
  final DateTime? birthDate;
  final String profileType;
  final String? selectedAvatar;
  final bool isLoading;
  final ValueChanged<String> onProfileTypeChanged;
  final ValueChanged<String> onAvatarSelected;
  final VoidCallback onBirthDateTap;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: profileType,
            decoration: _inputDecoration(
              label: 'Rôle',
              icon: Icons.family_restroom_rounded,
            ),
            items: const [
              DropdownMenuItem(value: 'papa', child: Text('Papa')),
              DropdownMenuItem(value: 'maman', child: Text('Maman')),
              DropdownMenuItem(value: 'frere', child: Text('Frère')),
              DropdownMenuItem(value: 'soeur', child: Text('Sœur')),
              DropdownMenuItem(value: 'baby', child: Text('Bébé')),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    onProfileTypeChanged(value);
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: firstNameController,
            decoration: _inputDecoration(
              label: 'Prénom',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),
          if (profileType == 'papa' || profileType == 'maman')
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                label: 'Âge',
                icon: Icons.cake_outlined,
              ),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Date de naissance'),
              subtitle: Text(
                birthDate == null
                    ? 'À renseigner'
                    : '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: isLoading ? null : onBirthDateTap,
            ),
          const SizedBox(height: 20),
          AvatarGrid(
            selectedAvatarId: selectedAvatar,
            avatars: AvatarConstants.avatarsForProfileType(profileType),
            onAvatarSelected: onAvatarSelected,
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else ...[
            BoussoleButton(
              text: 'Ajouter ce membre',
              icon: Icons.add_rounded,
              onPressed: onSubmit,
            ),
            const SizedBox(height: 12),
            BoussoleButton(
              text: 'Annuler',
              icon: Icons.close_rounded,
              isPrimary: false,
              onPressed: onCancel,
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }
}
