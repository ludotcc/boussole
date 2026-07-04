import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../models/moment_model.dart';
import '../providers/moments_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/boussole_app_bar.dart';

class EditMomentPage extends ConsumerStatefulWidget {
  const EditMomentPage({super.key, required this.moment});

  final MomentModel moment;

  @override
  ConsumerState<EditMomentPage> createState() => _EditMomentPageState();
}

class _EditMomentPageState extends ConsumerState<EditMomentPage> {
  late final TextEditingController _nameController;
  late String _type;
  late String _iconKey;
  late String _colorKey;
  late bool _hasRoutine;
  late bool _active;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.moment.name);
    _type = widget.moment.type;
    _iconKey = widget.moment.iconKey;
    _colorKey = widget.moment.colorKey;
    _hasRoutine = widget.moment.hasRoutine;
    _active = widget.moment.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(momentUpdateProvider);
    final isLoading = updateState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: "Modifier le moment"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppCard(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      label: "Nom du moment",
                      icon: Icons.edit_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: _inputDecoration(
                      label: "Type",
                      icon: Icons.category_rounded,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'routine',
                        child: Text("Routine"),
                      ),
                      DropdownMenuItem(value: 'meal', child: Text("Repas")),
                      DropdownMenuItem(value: 'school', child: Text("Devoirs")),
                      DropdownMenuItem(
                        value: 'leisure',
                        child: Text("Temps libre"),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _type = value;
                            });
                          },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _iconKey,
                    decoration: _inputDecoration(
                      label: "Illustration",
                      icon: Icons.image_rounded,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'routineMorning',
                        child: Text("Rituel du matin"),
                      ),
                      DropdownMenuItem(
                        value: 'routineEvening',
                        child: Text("Rituel du soir"),
                      ),
                      DropdownMenuItem(
                        value: 'breakfast',
                        child: Text("Petit-déjeuner"),
                      ),
                      DropdownMenuItem(value: 'meal', child: Text("Repas")),
                      DropdownMenuItem(
                        value: 'homework',
                        child: Text("Devoirs"),
                      ),
                      DropdownMenuItem(
                        value: 'videoGames',
                        child: Text("Temps libre"),
                      ),
                      DropdownMenuItem(value: 'bike', child: Text("Vélo")),
                      DropdownMenuItem(value: 'bath', child: Text("Bain")),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _iconKey = value;
                            });
                          },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _colorKey,
                    decoration: _inputDecoration(
                      label: "Couleur",
                      icon: Icons.palette_rounded,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'momentMorning',
                        child: Text("Matin"),
                      ),
                      DropdownMenuItem(
                        value: 'momentMeal',
                        child: Text("Repas"),
                      ),
                      DropdownMenuItem(
                        value: 'momentSchool',
                        child: Text("Devoirs"),
                      ),
                      DropdownMenuItem(
                        value: 'momentLeisure',
                        child: Text("Loisir"),
                      ),
                      DropdownMenuItem(
                        value: 'momentEvening',
                        child: Text("Soir"),
                      ),
                      DropdownMenuItem(
                        value: 'momentHygiene',
                        child: Text("Hygiène"),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _colorKey = value;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Ce moment ouvre une routine"),
                    value: _hasRoutine,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _hasRoutine = value;
                            });
                          },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Moment actif"),
                    value: _active,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _active = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : BoussoleButton(
                    text: "Enregistrer",
                    icon: Icons.check_rounded,
                    onPressed: _saveMoment,
                  ),
          ],
        ),
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

  Future<void> _saveMoment() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Merci d'indiquer un nom.")));
      return;
    }

    final updatedMoment = widget.moment.copyWith(
      name: name,
      type: _type,
      iconKey: _iconKey,
      colorKey: _colorKey,
      hasRoutine: _hasRoutine,
      active: _active,
    );

    await ref.read(momentUpdateProvider.notifier).updateMoment(updatedMoment);

    if (!mounted) {
      return;
    }

    final updateState = ref.read(momentUpdateProvider);

    if (updateState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(updateState.error.toString())));
      return;
    }

    context.pop();
  }
}
