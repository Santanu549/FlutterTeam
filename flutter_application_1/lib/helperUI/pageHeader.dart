import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                    height: MediaQuery.of(context).size.height*0.31,
                    width: MediaQuery.of(context).size.width*1.0,
                   decoration: BoxDecoration(
            
                    border: BoxBorder.fromLTRB(bottom: BorderSide(color: Colors.white, width: 5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5), // Shadow color
                              blurRadius: 10, // How much the shadow is blurred
                              spreadRadius: 2, // How much the shadow is spread
                                offset: Offset(0, 5), // Changes the position of the shadow (x, y)
                                ),
                              ],
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)
                    ),
                   image: DecorationImage(
                     image: AssetImage("images/one.jpg"),
                     fit: BoxFit.cover,
                     ),
                   ),
                  );
  }
}