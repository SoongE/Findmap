import 'package:flutter/material.dart';

const STATUS_LOGIN = 'STATUS_LOGIN';
const STATUS_LOGOUT = 'STATUS_LOGOUT';

void showSnackbar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: "OK",
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Route createRoute(Widget secondPage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => secondPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
