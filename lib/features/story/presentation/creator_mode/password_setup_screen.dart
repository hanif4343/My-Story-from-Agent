// lib/features/story/presentation/creator_mode/password_setup_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';

/// PasswordSetupScreen allows the user to create a new password for Creator Mode.
/// It stores the SHA‑256 hash of the password in the Hive box `settings` under
/// the key `creator_password_hash`.  
///  
/// **Important**: Ensure that `Hive.openBox('settings')` is called in `main.dart`
/// before navigating to this screen.
class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _createPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = 'দুটি ক্ষেত্র পূরণ করুন');
      return;
    }

    if (password != confirm) {
      setState(() => _errorText = 'পাসওয়ার্ড মিলছে না');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final Box settingsBox = Hive.box('settings');
    final hash = sha256.convert(utf8.encode(password)).toString();
    await settingsBox.put('creator_password_hash', hash);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/creator-dashboard');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পাসওয়ার্ড সেটআপ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'পাসওয়ার্ড',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createPassword,
                    child: const Text('সাবমিট'),
                  ),
          ],
        ),
      ),
    );
  }
}
