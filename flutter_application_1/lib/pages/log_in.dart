import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperUI/custom_text_field.dart';
import 'package:flutter_application_1/helperUI/page_header.dart';
import 'package:flutter_application_1/pages/form.dart';
import 'package:flutter_application_1/pages/sign_up.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:page_transition/page_transition.dart'
    show PageTransition, PageTransitionType;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoginPressed = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(email: email, password: password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: UserForm(),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Login failed. Please try again.';
        if (e.toString().contains('user-not-found')) {
          message = 'No account found with this email.';
        } else if (e.toString().contains('wrong-password') ||
            e.toString().contains('invalid-credential')) {
          message = 'Incorrect password.';
        } else if (e.toString().contains('invalid-email')) {
          message = 'Invalid email address.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Header(),
            SizedBox(height: 30),
            Text("Welcome!", style: theme.textTheme.headlineMedium),
            SizedBox(height: 20),
            Center(
                child: Column(
              children: [
                MyWidget(
                    st: "Email",
                    ic: Icon(Icons.email_outlined),
                    controller: _emailController),
              ],
            )),
            SizedBox(height: 20),
            Center(
              child: MyWidget(
                  st: "Password",
                  ic: Icon(Icons.lock_outline),
                  controller: _passwordController,
                  obscureText: true),
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTapDown: (_) {
                      setState(() => _isLoginPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isLoginPressed = false);
                    },
                    onTapCancel: () {
                      setState(() => _isLoginPressed = false);
                    },
                    onTap: _handleLogin,
                    child: AnimatedScale(
                      scale: _isLoginPressed ? 0.94 : 1.0,
                      duration: Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        height: 60,
                        width: 100,
                        decoration: BoxDecoration(
                          color: _isLoginPressed
                              ? AppTheme.primaryColor.withValues(alpha: 0.7)
                              : AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: theme.colorScheme.onPrimary, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: _isLoginPressed ? 0.3 : 0.5),
                              blurRadius: _isLoginPressed ? 6 : 10,
                              spreadRadius: _isLoginPressed ? 1 : 2,
                              offset: Offset(0, _isLoginPressed ? 3 : 5),
                            ),
                          ],
                        ),
                        child: Center(
                            child: Text("LogIn",
                                style: theme.textTheme.titleLarge)),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Do not have an account? ",
                    style: theme.textTheme.bodyLarge),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: SignUp(),
                          duration: Duration(milliseconds: 500))),
                  child: Text("SignUp",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
