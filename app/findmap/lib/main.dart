import 'dart:convert';

import 'package:findmap/models/user.dart';
import 'package:findmap/views/login/first.dart';
import 'package:findmap/views/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find anything fitted with you',
      theme: ThemeData(
        fontFamily: 'NanumBarunGothic',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _storage = new FlutterSecureStorage();
  bool _userStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _checkUser(context);
    });
    // _checkUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void _checkUser(context) async {
    Map<String, String> userInfo = await _storage.readAll();

    _userStatus = userInfo.isEmpty ? false : true;

    if (_userStatus) {
      var jsonStorage = jsonDecode(json.encode(userInfo));
      jsonStorage['idx'] = int.parse(jsonStorage['idx']);
      var user = User.fromJson(jsonStorage);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage(user: user)));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FirstPage()));
    }
  }
}
