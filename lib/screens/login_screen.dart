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

  void _showError(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            _loading ? const CircularProgressIndicator() : Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _loading = true);
                    try {
                      await authService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
                      // on success firebaseUserProvider will update and navigate automatically
                    } catch (e) {
                      _showError(e.toString());
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _loading = true);
                    try {
                      final userCred = await authService.signInWithGoogle();
                      if (userCred == null) _showError('Google sign-in cancelled');
                    } catch (e) {
                      _showError(e.toString());
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: const Text('Create account'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
