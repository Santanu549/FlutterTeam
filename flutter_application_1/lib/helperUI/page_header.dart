import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
                    height: MediaQuery.of(context).size.height*0.31,
                    width: MediaQuery.of(context).size.width*1.0,
                   decoration: BoxDecoration(
            
                    border: BoxBorder.fromLTRB(bottom: BorderSide(color: theme.colorScheme.onPrimary, width: 5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                                offset: Offset(0, 5),
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