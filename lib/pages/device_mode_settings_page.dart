import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../models/device_configuration_model.dart';
import '../models/device_mode.dart';
import '../providers/children_provider.dart';
import '../providers/device_mode_provider.dart';
import '../providers/parent_access_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class DeviceModeSettingsPage extends ConsumerStatefulWidget {
  const DeviceModeSettingsPage({super.key});

  @override
  ConsumerState<DeviceModeSettingsPage> createState() =>
      _DeviceModeSettingsPageState();
}

class _DeviceModeSettingsPageState
    extends ConsumerState<DeviceModeSettingsPage> {
  final _pinController = TextEditingController();
  final _pinConfirmationController = TextEditingController();
  DeviceMode? _selectedMode;
  String? _personalChildId;
  final Set<String> _allowedChildIds = {};
  bool _initialized = false;

  @override
  void dispose() {
    _pinController.dispose();
    _pinConfirmationController.dispose();
    super.dispose();
  }

  void _initialize(DeviceConfigurationModel configuration) {
    if (_initialized) return;
    _selectedMode = configuration.mode;
    _personalChildId = configuration.personalChildId;
    _allowedChildIds
      ..clear()
      ..addAll(configuration.allowedChildIds);
    _initialized = true;
  }

  Future<void> _save(DeviceConfigurationModel current) async {
    final mode = _selectedMode ?? current.mode;
    String? newPin;

    if (mode.isChildMode && !current.hasParentPin) {
      if (_pinController.text != _pinConfirmationController.text) {
        _showMessage('Les deux PIN ne correspondent pas.');
        return;
      }
      newPin = _pinController.text;
    }

    final configuration = await ref
        .read(deviceConfigurationProvider.notifier)
        .configure(
          mode: mode,
          personalChildId: _personalChildId,
          allowedChildIds: _allowedChildIds.toList(),
          newParentPin: newPin,
        );

    if (!mounted) return;
    if (configuration == null) {
      final state = ref.read(deviceConfigurationProvider);
      _showMessage(state.error.toString());
      return;
    }

    _showMessage('Mode de l’appareil enregistré.');

    if (configuration.isChildMode) {
      context.go(configuration.childStartLocation);
      ref.read(parentAccessProvider.notifier).lock();
    } else {
      ref
          .read(parentAccessProvider.notifier)
          .syncWithConfiguration(configuration);
      context.go('/home');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final configurationAsync = ref.watch(deviceConfigurationProvider);
    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mode de l’appareil')),
      body: configurationAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(24), child: LoadingCard()),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Configuration indisponible',
            message: error.toString(),
          ),
        ),
        data: (configuration) {
          _initialize(configuration);
          return childrenAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingCard(),
            ),
            error: (error, stackTrace) => const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Profils indisponibles',
                message: 'Impossible de charger les profils enfant.',
              ),
            ),
            data: (children) => _buildForm(configuration, children),
          );
        },
      ),
    );
  }

  Widget _buildForm(
    DeviceConfigurationModel configuration,
    List<ChildModel> children,
  ) {
    final mode = _selectedMode ?? configuration.mode;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Choisissez comment Boussole s’ouvre sur cet appareil.',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        RadioGroup<DeviceMode>(
          groupValue: mode,
          onChanged: (next) => setState(() => _selectedMode = next),
          child: Column(
            children: [
              for (final value in DeviceMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RadioListTile<DeviceMode>(
                    value: value,
                    title: Text(value.label),
                    subtitle: Text(value.description),
                    secondary: Icon(_modeIcon(value)),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (mode == DeviceMode.personalChildTablet) ...[
          const SizedBox(height: 8),
          Text(
            'Profil de cette tablette',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          RadioGroup<String>(
            groupValue: _personalChildId,
            onChanged: (value) => setState(() => _personalChildId = value),
            child: Column(
              children: [
                for (final child in children)
                  RadioListTile<String>(
                    value: child.id,
                    title: Text(child.firstName),
                    secondary: _avatar(child),
                  ),
              ],
            ),
          ),
        ],
        if (mode == DeviceMode.sharedChildTablet) ...[
          const SizedBox(height: 8),
          Text(
            'Profils autorisés',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          for (final child in children)
            CheckboxListTile(
              value: _allowedChildIds.contains(child.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _allowedChildIds.add(child.id);
                  } else {
                    _allowedChildIds.remove(child.id);
                  }
                });
              },
              title: Text(child.firstName),
              secondary: _avatar(child),
            ),
        ],
        if (mode.isChildMode && !configuration.hasParentPin) ...[
          const SizedBox(height: 20),
          Text(
            'Créer le PIN parent',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Il sera demandé après un appui continu de 5 secondes sur le logo Boussole.',
          ),
          const SizedBox(height: 14),
          _pinField(_pinController, 'PIN à 4 chiffres'),
          const SizedBox(height: 12),
          _pinField(_pinConfirmationController, 'Confirmer le PIN'),
        ] else if (mode.isChildMode) ...[
          const SizedBox(height: 20),
          const ListTile(
            leading: Icon(Icons.lock_rounded, color: Colors.green),
            title: Text('PIN parent actif'),
            subtitle: Text(
              'Maintenez le logo Boussole pendant 5 secondes pour revenir à l’espace parent.',
            ),
          ),
        ],
        const SizedBox(height: 28),
        BoussoleButton(
          text: 'Enregistrer ce mode',
          icon: Icons.check_rounded,
          onPressed: () => _save(configuration),
        ),
      ],
    );
  }

  Widget _pinField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.pin_rounded),
        counterText: '',
      ),
    );
  }

  Widget _avatar(ChildModel child) {
    String asset;
    try {
      asset = AvatarConstants.assetFromId(child.avatar);
    } catch (_) {
      return const CircleAvatar(child: Icon(Icons.child_care_rounded));
    }
    return CircleAvatar(backgroundImage: AssetImage(asset));
  }

  IconData _modeIcon(DeviceMode mode) {
    return switch (mode) {
      DeviceMode.familyPhone => Icons.phone_android_rounded,
      DeviceMode.personalChildTablet => Icons.tablet_android_rounded,
      DeviceMode.sharedChildTablet => Icons.groups_rounded,
    };
  }
}
