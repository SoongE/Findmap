import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:findmap/views/email_confirm.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/mainPage.dart';

class EmailLoginPage extends StatefulWidget {
  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool isLoading = false;
  late TextEditingController _userEmailCtrl;
  late TextEditingController _userPasswordCtrl;

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: '');
    _userPasswordCtrl = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'E-mail 로그인',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 10,),
            _emailWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            _passwordWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            _loginButton(context),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            _registerButton(),
            Spacer(flex: 10,),
          ],
        ),
      ),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      controller: _userEmailCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "E-mail",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordWidget() {
    return TextFormField(
      controller: _userPasswordCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_rounded),
        labelText: "Password",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _loginButton(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child:
      ElevatedButton(
        onPressed: () => _loginCheck(),
        child: Text(
        isLoading ? '로그인 중...' : '로그인',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      ),
    );
  }

  Widget _registerButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('아직 계정이 없으신가요?'),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => Navigator.push(
              context, createRoute(RegisterPage())),
          child: Text(
            '회원가입 하러가기',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  void _loginCheck() async {
    print('_userEmailCtrl.text : ${_userEmailCtrl.text}');
    print('_userPasswordCtrl.text : ${_userPasswordCtrl.text}');
    final storage = FlutterSecureStorage();
    final String? storagePass = await storage.read(key: _userEmailCtrl.text);
    if (storagePass != null &&
        storagePass != '' &&
        storagePass == _userPasswordCtrl.text) {
      print('storagePass : $storagePass');
      final String userNickName = await storage.read(
          key: '${_userEmailCtrl.text}_$storagePass') as String;
      storage.write(key: userNickName, value: STATUS_LOGIN);
      print('로그인 성공');
      showSnackbar(context, '환영합니다, $userNickName님');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  MainPage(nickName: userNickName)));
    } else {
      print('로그인 실패');
      showSnackbar(context, '아이디가 존재하지 않거나 비밀번호가 맞지않습니다.');
    }
  }
}
