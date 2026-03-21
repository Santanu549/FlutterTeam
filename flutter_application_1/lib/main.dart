import 'package:cargo_flow/pages/create_indent.dart';
import 'package:flutter/material.dart';
import 'package:cargo_flow/pages/admin_home_page.dart';
import 'package:cargo_flow/pages/executive_home_page.dart';
import 'package:cargo_flow/pages/form.dart';
import 'package:cargo_flow/pages/log_in.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/pages/home_page.dart';
import 'package:cargo_flow/services/database_service.dart';
import 'package:cargo_flow/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cargo flow',
      theme: AppTheme.lightTheme,
      home: StreamBuilder<AppUser?>(
        stream: AuthService().authStateChanges,
        initialData: AuthService().currentUser,
        builder: (context, snapshot) {
          // Show a loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return const Scaffold(
              backgroundColor: Colors.indigoAccent,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          // If user is logged in, check if they are registered in DB
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;

            if (user.role == 'admin') {
              return const AdminHomePage();
            }

            if (user.role == 'executive') {
              return const ExecutiveHomePage();
            }

            return FutureBuilder<bool>(
              future: DatabaseService().isDriverRegistered(user.id),
              builder: (context, dbSnapshot) {
                if (dbSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Colors.indigoAccent,
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                if (dbSnapshot.data == true) {
                  return const HomePage();
                }
                return const UserForm();
              },
            );
          }
          return const MyHomePage();
        },
      ),
    );
  }
}
