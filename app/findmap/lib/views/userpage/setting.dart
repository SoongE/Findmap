import 'dart:convert';

import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/first.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();

  Setting(this.user);

  final User user;
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(color: Colors.black),
          title: Text('설정', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textButton('알림'),
              _textButton('공지사항'),
              _textButton('맞춤 서비스 변경'),
              _textButton('팔로우 및 초대'),
              _textButton('약관 확인'),
              _textButton('오픈소스 라이선스 확인'),
              _textButton('비밀번호 변경'),
              _textButton('문의'),
              _textButton('회원탈퇴'),
              _textButton('로그아웃', callback: _logout),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajou Nice Team',
            style: TextStyle(
                color: Colors.black, fontFamily: 'FugazOne', fontSize: 16),
          ),
          Text('', style: TextStyle(fontSize: 5)),
          Text('Findmap은 2021 한이음 프로젝트를 기반으로 만들어진 애플리케이션입니다.',
              style: TextStyle(color: Colors.grey[600]))
        ],
      ),
    );
  }

  Widget _textButton(String title, {VoidCallback? callback}) {
    return TextButton(
      onPressed: () => callback!(),
      child: Text(title, style: TextStyle(color: Colors.black, fontSize: 15)),
      style: ButtonStyle(
          alignment: Alignment.centerLeft,
          splashFactory: NoSplash.splashFactory),
    );
  }

  void _logout() async {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();

    var _isSignOutSafe = fetchSignOut(context);

    _isSignOutSafe.then((value) => value
        ? {
            showSnackbar(context, "정상적으로 로그아웃 되었습니다"),
            Navigator.pushAndRemoveUntil(
                context, createRoute(FirstPage()), (route) => false),
          }
        // : showSnackbar(context, "정상적으로 로그아웃되지 않았습니다"));
        : Navigator.pushAndRemoveUntil(
            context, createRoute(FirstPage()), (route) => false));
  }

  Future<bool> fetchSignOut(BuildContext context) async {
    final response = await http.patch(
      Uri.http(BASEURL, '/users/logout'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }
}
