import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(lockStateProvider);

    if (!lockState.isLocked) {
      return const SizedBox.shrink();
    }

    // Kalan süreyi hesapla
    final remaining = lockState.lockTime!
        .add(lockState.lockDuration)
        .difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Uygulama Kilitli',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kalan Süre: $minutes:${seconds.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    errorText: _errorText,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (ref
                        .read(lockStateProvider.notifier)
                        .unlock(_passwordController.text)) {
                      _errorText = null;
                      _passwordController.clear();
                    } else {
                      setState(() {
                        _errorText = 'Yanlış şifre';
                      });
                    }
                  },
                  child: const Text('Kilidi Aç'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
