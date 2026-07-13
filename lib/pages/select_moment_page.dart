import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/constants/moment_presets.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/moment_preset_card.dart';
import 'create_moment_settings_page.dart';

class SelectMomentPage extends StatelessWidget {
  const SelectMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedPresets = [...momentPresets]
      ..sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: "Choisir un moment"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: .78,
          children: [
            for (final preset in sortedPresets)
              MomentPresetCard(
                title: preset.name,
                image: preset.image,
                onTap: () => _openSettings(context, preset.key),
              ),
          ],
        ),
      ),
    );
  }

  String _sortKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[àâä]'), 'a')
        .replaceAll(RegExp('[ç]'), 'c')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[îï]'), 'i')
        .replaceAll(RegExp('[ôö]'), 'o')
        .replaceAll(RegExp('[ùûü]'), 'u')
        .replaceAll('œ', 'oe');
  }

  void _openSettings(BuildContext context, String presetKey) {
    context.push(
      '/create-moment-settings',
      extra: CreateMomentSettingsArgs(presetKey),
    );
  }
}
