import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.contains("@") ? null : "Enter valid email",
              ),
              TextFormField(
                controller: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Password too short" : null,
              ),
              const SizedBox(height: 24),
              loading
                  ? const CircularProgressIndicator()
                  : FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => loading = true);

                      final auth = ref.read(authServiceProvider);
                      final res = await auth.signUp(
                        email.text.trim(),
                        password.text.trim(),
                        displayName: name.text.trim(),
                      );

                      setState(() => loading = false);

                      if (res == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Signup failed")),
                        );
                        return;
                      }

                      // Auth state will automatically update and navigate via AuthGate
                      // No need to manually navigate
                    },
                    child: const Text("Create Account"),
                  ),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
