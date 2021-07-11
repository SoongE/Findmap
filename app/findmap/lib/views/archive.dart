import 'package:flutter/material.dart';

class ArchivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.purple,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Center(
          child: Text(
            "ArchivePage",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
