import 'package:flutter/material.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/pages/log_in.dart';
import 'package:cargo_flow/services/appwrite_auth_san.dart';

class ExecutiveHomePage extends StatefulWidget {
  const ExecutiveHomePage({super.key});

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

class _ExecutiveHomePageState extends State<ExecutiveHomePage> {

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final appwriteAuthService = AuthServiceAppwrite();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await appwriteAuthService.logout();
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
