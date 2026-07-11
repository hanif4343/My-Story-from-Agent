import 'package:flutter/material.dart';

/// A screen that gates access to Creator Mode by verifying a password.
///
/// If the password is correct, the user is navigated to the Creator Dashboard
/// (`/creator-dashboard`). Otherwise a SnackBar with an error message is shown.
class PasswordGateScreen extends StatefulWidget {
  const PasswordGateScreen({Key? key}) : super(key: key);

  @override
  State<PasswordGateScreen> createState() => _PasswordGateScreenState();
}

class _PasswordGateScreenState extends State<PasswordGateScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;

  /// Disposes the text controller when the widget is removed from the tree.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles the password submission.
  ///
  /// Currently uses a plain‑text comparison as a placeholder.
  /// TODO: Replace with SHA‑256 hash comparison using `dart:convert` and
  /// store the hashed password securely in Hive.
  Future<void> _submitPassword() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    const String correctPassword = 'creator123'; // placeholder

    final entered = _controller.text.trim();

    // TODO: compare SHA256 hashes instead of plain strings.
    final isValid = entered == correctPassword;

    if (isValid) {
      // Navigate to the creator dashboard.
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/creator-dashboard');
    } else {
      // Show error snackbar.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল পাসওয়ার্ড')),
      );
    }

    setState(() => _isProcessing = false);
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
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitPassword(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitPassword,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
