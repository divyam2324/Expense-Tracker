import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            _loading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      /// ------------------------
                      /// EMAIL + PASSWORD SIGN-IN
                      /// ------------------------
                      ElevatedButton(
                        onPressed: () async {
                          if (_emailCtrl.text.isEmpty ||
                              _passCtrl.text.isEmpty) {
                            _showError("Enter email & password");
                            return;
                          }

                          setState(() => _loading = true);

                          final user = await authService.signIn(
                            _emailCtrl.text.trim(),
                            _passCtrl.text.trim(),
                          );

                          setState(() => _loading = false);

                          if (user == null) {
                            _showError("Invalid login credentials");
                          }

                          // NO MANUAL NAVIGATION REQUIRED
                          // AuthGate will detect user & navigate to home
                        },
                        child: const Text("Sign In"),
                      ),

                      const SizedBox(height: 8),

                      /// ------------------------
                      /// NAVIGATE TO SIGNUP
                      /// ------------------------
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text("Create account"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
