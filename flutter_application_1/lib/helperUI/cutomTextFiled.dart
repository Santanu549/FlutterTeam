import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.st, this.ic});
  final String st;
  final Icon? ic;
  @override
  Widget build(BuildContext context) {
    return Container(
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1)
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: TextField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  icon: ic ?? Icon(Icons.lock_outline, color: Color.fromARGB(255, 100, 97, 97)),
                  hintText: st,
                  hintStyle: TextStyle(color: const Color.fromARGB(255, 100, 97, 97)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                ),
              ),
            );
  }
}