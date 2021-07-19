import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:findmap/views/register.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/mainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          '로그인',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _emailWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            _passwordWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            _loginButton(context),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            _registerButton(),
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
        labelText: "Email",
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
      child: FlatButton(
        color: Colors.purple,
        textColor: Colors.white,
        disabledColor: Colors.purple,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        onPressed: () => isLoading ? null : _loginCheck(),
        child: Text(
          isLoading ? 'loggin in.....' : 'login',
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
        Text('Don\'t have an account ?'),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => RegisterPage())),
          child: Text(
            'register',
            style: TextStyle(color: Colors.blueAccent),
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
