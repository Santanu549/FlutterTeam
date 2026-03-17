import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.st,
    this.ic,
    this.controller,
    this.obscureText = false,
  });
  final String st;
  final Icon? ic;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.onPrimary, width: 1),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                textAlign: TextAlign.start,
                style: TextStyle(color: AppTheme.onPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  icon: ic ?? Icon(Icons.lock_outline, color: theme.iconTheme.color),
                  hintText: st,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                ),
              ),
            );
  }
}