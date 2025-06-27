import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state.dart';

class LockDialog extends ConsumerStatefulWidget {
  const LockDialog({super.key});

  @override
  ConsumerState<LockDialog> createState() => _LockDialogState();
}

class _LockDialogState extends ConsumerState<LockDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Duration _selectedDuration = const Duration(minutes: 30);
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uygulamayı Kilitle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Duration>(
            value: _selectedDuration,
            decoration: const InputDecoration(
              labelText: 'Kilit Süresi',
            ),
            items: [
              DropdownMenuItem(
                value: const Duration(minutes: 15),
                child: const Text('15 dakika'),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 30),
                child: const Text('30 dakika'),
              ),
              DropdownMenuItem(
                value: const Duration(hours: 1),
                child: const Text('1 saat'),
              ),
              DropdownMenuItem(
                value: const Duration(hours: 2),
                child: const Text('2 saat'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDuration = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Şifreyi Tekrar Girin',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_passwordController.text.isEmpty) {
              setState(() {
                _errorText = 'Şifre boş olamaz';
              });
              return;
            }
            if (_passwordController.text != _confirmPasswordController.text) {
              setState(() {
                _errorText = 'Şifreler eşleşmiyor';
              });
              return;
            }
            
            final notifier = ref.read(lockStateProvider.notifier);
            notifier.setLockDuration(_selectedDuration);
            notifier.lock(_passwordController.text);
            Navigator.pop(context);
          },
          child: const Text('Kilitle'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
