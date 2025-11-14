import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(firebaseUserProvider);
    final user = authAsync.value;
    final fallbackInitial = (user?.displayName ?? user?.email ?? '?').trim();
    final avatarLabel =
        fallbackInitial.isEmpty ? '?' : fallbackInitial[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  avatarLabel,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(user?.displayName ?? 'Not set'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? 'Not linked'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('UID'),
                    subtitle: Text(user?.uid ?? 'Unavailable'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                onPressed: () => ref.read(authServiceProvider).signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
