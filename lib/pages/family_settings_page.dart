import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../providers/family_provider.dart';
import '../providers/family_settings_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class FamilySettingsPage extends ConsumerStatefulWidget {
  const FamilySettingsPage({super.key});

  @override
  ConsumerState<FamilySettingsPage> createState() => _FamilySettingsPageState();
}

class _FamilySettingsPageState extends ConsumerState<FamilySettingsPage> {
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _familyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final currentEmail = ref.read(sessionProvider)?.email.trim() ?? '';
    final nextEmail = _emailController.text.trim();

    await ref
        .read(familySettingsProvider.notifier)
        .updateSettings(
          familyName: _familyNameController.text,
          email: nextEmail == currentEmail ? '' : nextEmail,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final state = ref.read(familySettingsProvider);

    if (state.hasError) {
      _showMessage(state.error.toString());
      return;
    }

    _passwordController.clear();
    _showMessage('Paramètres enregistrés.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(currentFamilyProvider);
    final actionState = ref.watch(familySettingsProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Paramètres famille'), elevation: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.backgroundBase01, fit: BoxFit.cover),
          SafeArea(
            child: familyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: LoadingCard(),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Oups',
                  message: error.toString(),
                ),
              ),
              data: (family) {
                if (family == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.family_restroom_rounded,
                      title: 'Famille introuvable',
                      message: 'Reconnectez-vous pour continuer.',
                    ),
                  );
                }

                if (!_initialized) {
                  _familyNameController.text = family.name;
                  _emailController.text = session?.email ?? '';
                  _initialized = true;
                }

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('Famille ${family.name}', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Gardez les informations du compte famille à jour.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      child: Column(
                        children: [
                          TextField(
                            controller: _familyNameController,
                            decoration: _inputDecoration(
                              label: 'Nom de famille',
                              icon: Icons.family_restroom_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              label: 'Nouveau mot de passe',
                              icon: Icons.lock_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Un changement d’email peut demander une confirmation Firebase.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.devices_rounded),
                        title: const Text('Mode de l’appareil'),
                        subtitle: const Text(
                          'Téléphone familial, tablette personnelle ou tablette partagée.',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/device-mode-settings'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'En mode enfant, maintenez le logo Boussole pendant 5 secondes pour accéder à cet espace.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (actionState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      BoussoleButton(
                        text: 'Enregistrer',
                        icon: Icons.check_rounded,
                        onPressed: _save,
                      ),
                  ],
                );
              },
            ),
          ),
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
