import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/controllers.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 44,
              backgroundColor: kPrimarySoft,
              child: Text(user.initials,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w700, color: kPrimary)),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Chip(
              label: Text(user.isStaff ? 'Campus Staff' : 'Student'),
              backgroundColor: kPrimarySoft,
              side: BorderSide.none,
              labelStyle: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
