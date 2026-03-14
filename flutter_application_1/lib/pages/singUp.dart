import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperUI/cutomTextFiled.dart';
import 'package:flutter_application_1/helperUI/pageHeader.dart';
import 'package:flutter_application_1/pages/log_in.dart';
import 'package:page_transition/page_transition.dart';

class Singup extends StatefulWidget {
  const Singup({super.key});

  @override
  State<Singup> createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  bool _isLoginPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            SizedBox(height: 30,),
            Text("Create an account", style: 
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white
              )
              ),
            SizedBox(height: 20,),
            Center(
                  child: Column(
                    children: [
                      MyWidget(st: "Email", ic: Icon(Icons.email_outlined)),//helperUI/cutomTextFiled.dart
                      
                    ],
                  )
                ),
            SizedBox(height: 20,),
              Center(
                child: MyWidget(st: "Password", ic: Icon(Icons.lock_outline)), //helperUI/cutomTextFiled.dart
              ),
            SizedBox(height: 20,),
            Center(
                child: MyWidget(st: "Confirm Password", ic: Icon(Icons.lock_outline)), //helperUI/cutomTextFiled.dart
              ),
            SizedBox(height: 25,),

            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTapDown: (_) {
                setState(() {
                  _isLoginPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isLoginPressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isLoginPressed = false;
                });
              },
              onTap: () {
                setState(() {
                });
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
                  child: Center(
                    child: Text("SignUp", 
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
                      ) 
                    ,)
                    ),
                  decoration: BoxDecoration(
                    color: _isLoginPressed ? Colors.indigoAccent[100] : Colors.indigoAccent[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isLoginPressed ? 0.3 : 0.5),
                            blurRadius: _isLoginPressed ? 6 : 10,
                            spreadRadius: _isLoginPressed ? 1 : 2,
                              offset: Offset(0, _isLoginPressed ? 3 : 5),
                              ),  
                    ],
                  ),
                ),
              ),
            ),

          SizedBox(height: 20,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ", 
                style: TextStyle(color: Colors.white, fontSize: 16),  
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, 
                  PageTransition(type: PageTransitionType.leftToRight, child: MyHomePage(), duration: Duration(milliseconds: 500))),
                  child: Text("LogIn", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),  
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}