import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperUI/customFormFiled.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/three.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomFormFiled(hint_text: 'First Name', wid: 0.4),
                    CustomFormFiled(hint_text: 'Last Name', wid: 0.4),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                CustomFormFiled(hint_text: 'Address', wid: 0.7)
              ],
            ),
          ],
        ));
  }
}
