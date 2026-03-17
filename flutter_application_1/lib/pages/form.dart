import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperUI/customFormFiled.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage("images/four.png"), 
                height: MediaQuery.of(context).size.height * 0.4, 
                width: MediaQuery.of(context).size.width * 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomFormFiled(hint_text: 'First Name', wid: 0.4),
                    CustomFormFiled(hint_text: 'Last Name', wid: 0.4),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomFormFiled(hint_text: 'Vehical No', wid: 0.4),
                    CustomFormFiled(hint_text: 'Phone No', wid: 0.4),
                  ],
                ),

                SizedBox(height: 20),

                CustomFormFiled(hint_text: 'Address', wid: 0.7),

                SizedBox(height: 20),

                InkWell(
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
                  onTap: () {
                    setState(() {});
                  },
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
                          child: Text("Submit",
                              style: theme.textTheme.titleLarge)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
