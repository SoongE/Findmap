import 'package:findmap/views/first.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:findmap/views/email_login.dart';
import 'package:findmap/views/mainPage.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

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
  @override
  void initState() {
    super.initState();
    _checkUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void _checkUser(context) async {
    final storage = new FlutterSecureStorage();
    print('${await storage.readAll()}');
    Map<String, String> allStorage = await storage.readAll();
    String statusUser = '';
    if (allStorage != null) {
      allStorage.forEach((k, v) {
        print('k : $k, v : $v');
        if (v == STATUS_LOGIN) statusUser = k;
      });
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FirstPage()));
    }
    if (statusUser != null && statusUser != '') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(nickName: statusUser)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FirstPage()));
    }
  }
}
