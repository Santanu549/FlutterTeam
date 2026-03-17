import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/form.dart';
import 'package:flutter_application_1/pages/log_in.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.indigoAccent,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          // If user is logged in, go to form page; otherwise, go to login
          if (snapshot.hasData) {
            return UserForm();
          }
          return MyHomePage();
        },
      ),
    );
  }
}
