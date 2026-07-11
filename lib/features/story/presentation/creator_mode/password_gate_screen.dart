// lib/features/story/presentation/creator_mode/password_gate_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PasswordGateScreen extends StatefulWidget {
  const PasswordGateScreen({super.key});

  @override
  State<PasswordGateScreen> createState() => _PasswordGateScreenState();
}

class _PasswordGateScreenState extends State<PasswordGateScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _validatePassword() async {
    final entered = _controller.text.trim();
    if (entered.isEmpty) return;

    setState(() => _isLoading = true);

    final Box settingsBox = Hive.box('settings');
    final storedHash = settingsBox.get('creator_password_hash') as String? ?? '';

    final isValid = entered == storedHash;

    setState(() => _isLoading = false);

    if (isValid) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/creator-dashboard');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল পাসওয়ার্ড')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'পাসওয়ার্ড',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _validatePassword,
                    child: const Text('সাবমিট'),
                  ),
          ],
        ),
      ),
    );
  }
}
