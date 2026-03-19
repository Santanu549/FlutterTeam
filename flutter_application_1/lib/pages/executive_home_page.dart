import 'package:flutter/material.dart';
import 'package:cargo_flow/services/auth_service.dart';

import 'package:cargo_flow/pages/log_in.dart';

class ExecutiveHomePage extends StatelessWidget {
  const ExecutiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_center, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              'Welcome, Executive!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Logged in as: ${user?.email ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
