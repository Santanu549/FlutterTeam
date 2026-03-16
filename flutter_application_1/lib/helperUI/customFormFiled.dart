import 'package:flutter/material.dart';

class CustomFormFiled extends StatelessWidget {
  const CustomFormFiled({super.key, required this.hint_text, required this.wid});
  final String hint_text;
  final double wid;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width * wid,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1)
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint_text,
              ),
            ),
          );
  }
}