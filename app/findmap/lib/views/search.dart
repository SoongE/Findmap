import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.amber,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Center(
          child: Text(
            "SearchPage",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
