import 'package:flutter/material.dart';

class AlarmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.teal,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Center(
          child: Text(
            "AlarmPage",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
