import 'package:flutter/material.dart';

class CustomFormFiled extends StatelessWidget {
  const CustomFormFiled({super.key, required this.hint_text, required this.wid});
  final String hint_text;
  final double wid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width * wid,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.onPrimary, width: 1),
            ),
            child: TextField(
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint_text,
                hintStyle: theme.inputDecorationTheme.hintStyle,
              ),
            ),
          );
  }
}