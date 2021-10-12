import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String BASEURL = '3.36.176.1:3000';

Future<void> fetchExample(BuildContext context) async {
  Map<String, dynamic> param = {"param": 'param'};

  final response = await http.post(
    Uri.http(BASEURL, '/url'),
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      "token": "widget.user.accessToken",
    },
    body: json.encode(param),
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);

    if (responseBody['success']) {
      //Todo
    } else {
      showSnackbar(context, responseBody['message']);
      throw Exception('FUNCTIONNAME Exception: ${responseBody['message']}');
    }
  } else {
    showSnackbar(context, '서버와 연결이 불안정합니다');
    throw Exception('Failed to connect to server');
  }
}

Widget futureBuilderExample() {
  return FutureBuilder(
    // future: _memoizer,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text('');
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return Text("PAGE");
      }
    },
  );
}

void showSnackbar(BuildContext context, String text,
    {String? label, dynamic onPressed}) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: label != null ? label : '',
      onPressed: () => onPressed,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void shotConfirmAlert(
    BuildContext context, String title, String content, String actionName) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      if (Platform.isAndroid) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: Text(actionName),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      } else {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: Text(actionName),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    },
  );
}

Route createRoute(Widget secondPage) {
  return CupertinoPageRoute(
    builder: (context) => secondPage,
    fullscreenDialog: true,
  );
}

Route createRouteRight(Widget secondPage) {
  return CupertinoPageRoute(
    builder: (context) => secondPage,
    fullscreenDialog: false,
  );
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String? get barrierLabel => throw UnimplementedError();
}
