import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../providers/device_mode_provider.dart';
import '../providers/parent_access_provider.dart';
import '../widgets/boussole_button.dart';

class ParentUnlockPage extends ConsumerStatefulWidget {
  const ParentUnlockPage({super.key});

  @override
  ConsumerState<ParentUnlockPage> createState() => _ParentUnlockPageState();
}

class _ParentUnlockPageState extends ConsumerState<ParentUnlockPage> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final unlocked = await ref
        .read(parentAccessProvider.notifier)
        .unlock(_pinController.text);
    if (!mounted || !unlocked) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(parentAccessProvider);
    final configuration = ref.watch(deviceConfigurationProvider).valueOrNull;

    if (configuration?.isChildMode != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF5FF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AppAssets.logo, width: 170),
                        const SizedBox(height: 24),
                        Text(
                          'Accès parent',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Saisissez le PIN créé lors de l’activation du mode enfant.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _pinController,
                          autofocus: true,
                          obscureText: true,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onSubmitted: (_) => _unlock(),
                          decoration: const InputDecoration(
                            labelText: 'PIN parent',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            counterText: '',
                          ),
                        ),
                        if (lockState.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            lockState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 22),
                        if (lockState.isChecking)
                          const CircularProgressIndicator()
                        else
                          BoussoleButton(
                            text: 'Ouvrir l’espace parent',
                            icon: Icons.lock_open_rounded,
                            onPressed: _unlock,
                          ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                              return;
                            }
                            context.go(
                              configuration?.childStartLocation ?? '/',
                            );
                          },
                          child: const Text('Retour à l’espace enfant'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
