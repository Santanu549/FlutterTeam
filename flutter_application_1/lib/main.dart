import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/form.dart';
import 'package:flutter_application_1/pages/log_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cargo flow',
      theme: ThemeData(),
      home: userForm(), //log_in.dart
    );
  }
}
