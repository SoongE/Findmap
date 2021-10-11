import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';

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
      final User user = await UserApi.instance.me();
      _userEmail = user.kakaoAccount?.email ?? '';
      _userPassword = 'KakaoAcc3504@';
      String _thumbnailURL = user.kakaoAccount?.profile?.profileImageUrl ?? '';
      String _nickName = user.kakaoAccount?.profile?.nickname ?? '';
      String _gender = user.kakaoAccount?.gender.toString() ?? '';
      if (_gender == 'Gender.MALE') {
        _gender = '남성';
      } else if (_gender == 'Gender.FEMALE') {
        _gender = '여성';
      } else {
        _gender = '';
      }
      // ** node server로 사용자인증토큰 전달해주어야할 듯 여기서 보내줄지는 이야기해봐야! **
      // final kakaoUrl = Uri.parse('토큰 전달할 url');
      // http
      //     .post(kakaoUrl, body: json.encode({'access_token': token}))
      //     .then((res) => print(json.decode(res.body)))
      //     .catchError((e) => print(e.toString()));
      Navigator.push(
          context,
          createRouteRight(RegisterPage(
            _nickName,
            _thumbnailURL,
            _gender,
            userEmail: _userEmail,
            userPassword: _userPassword,
          )));
    } catch (error) {
      showSnackbar(context, "회원가입 중 문제가 발생했습니다");
    }
  }

  Future<void> _loginWithWeb() async {
    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
    } catch (error) {
      showSnackbar(context, "회원가입 중 문제가 발생했습니다");
    }
  }

  Future<void> _loginWithKakaoApp() async {
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (error) {
      showSnackbar(context, "회원가입 중 문제가 발생했습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    var sizeRatio = 0.13;
    return new Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _isKakaoTalkInstalled ? _loginWithKakaoApp : _loginWithWeb,
        child: Container(
          width: MediaQuery.of(context).size.width * sizeRatio,
          height: MediaQuery.of(context).size.width * sizeRatio,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MyColors.myYellow,
          ),
          child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset('assets/social/kakao_logo.png')),
        ),
      ),
    );
  }
}
