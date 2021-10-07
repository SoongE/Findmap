import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'register.dart';

class KakaoLogin extends StatefulWidget {
  @override
  _KakaoLoginState createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State<KakaoLogin> {
  bool _isKakaoTalkInstalled = false;

  String _userEmail = "temp@gmail.com"; // register page로 넘어가기 위해 임시로 설정
  String _userPassword = "password?1234"; // 추후에 token으로 접속할 페이지를 만든다면 삭제
  late Future<String> authNumber;

  final GlobalKey<FormState> kakaoConfirmFormKey = GlobalKey<FormState>();
  ValueNotifier<bool> showRegisterPage = ValueNotifier<bool>(false);

  @override
  void initState() {
    _initKakaoTalkInstalled();
    super.initState();
  }

  _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  Future<void> _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      TokenManager.instance.setToken(token);
      // ** node server로 사용자인증토큰 전달해주어야할 듯 여기서 보내줄지는 이야기해봐야! **
      // final kakaoUrl = Uri.parse('토큰 전달할 url');
      // http
      //     .post(kakaoUrl, body: json.encode({'access_token': token}))
      //     .then((res) => print(json.decode(res.body)))
      //     .catchError((e) => print(e.toString()));
      Navigator.push(
          context,
          createRouteRight(RegisterPage(
            userEmail: _userEmail,
            userPassword: _userPassword,
          )));
    } catch (error) {
      showSnackbar(context, "_issueAccessToken: 회원가입 중 문제가 발생했습니다");
      print(error);
    }
  }

  Future<void> _loginWithWeb() async {
    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
    } catch (error) {
      showSnackbar(context, "_loginWithWeb: 회원가입 중 문제가 발생했습니다");
    }
  }

  Future<void> _loginWithKakaoApp() async {
    print("application");
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (error) {
      showSnackbar(context, "_loginWithKakaoApp: 회원가입 중 문제가 발생했습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: CupertinoButton(
        onPressed: _isKakaoTalkInstalled ? _loginWithKakaoApp : _loginWithWeb,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyColors.myYellow),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble, color: Colors.black),
              SizedBox(
                width: 10,
              ),
              Text(
                '카카오로 로그인하기',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
