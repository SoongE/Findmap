import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:findmap/views/email_login.dart';
import 'package:findmap/utils/utils.dart';

import 'package:findmap/views/mainPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  late TextEditingController _userNickNameCtrl;
  late TextEditingController _userEmailCtrl;
  late TextEditingController _userPasswordCtrl;

  @override
  void initState() {
    super.initState();
    _userNickNameCtrl = TextEditingController(text: '');
    _userEmailCtrl = TextEditingController(text: '');
    _userPasswordCtrl = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Register Page',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _nickNameWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            _emailWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            _passwordWidget(),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            _joinButton(context),
            _loginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _nickNameWidget() {
    return TextFormField(
      controller: _userNickNameCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle_rounded),
        labelText: "nickName",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      controller: _userEmailCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.email,
        ),
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

  Widget _joinButton(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        color: Colors.purple,
        textColor: Colors.white,
        disabledColor: Colors.purple,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
          isLoading ? null : _registCheck();
        },
        child: Text(
          isLoading ? 'regist in.....' : 'regist',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
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
        onPressed: () => isLoading
            ? null
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => EmailLoginPage(),
                ),
              ),
        child: Text(
          'loginPage',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _registCheck() async {
    final storage = FlutterSecureStorage();
    print(' ');
    print('await storage.readAll() : ');
    print(await storage.readAll());
    print(' ');
    String userNickName = _userNickNameCtrl.text;
    String userEmail = _userEmailCtrl.text;
    String userPassword = _userPasswordCtrl.text;
    if (userNickName != '' && userEmail != '' && userPassword != '') {
      //final storage = FlutterSecureStorage();
      final String? emailCheck = await storage.read(key: userEmail);
      if (emailCheck == null) {
        storage.write(key: userEmail, value: userPassword);
        storage.write(key: '${userEmail}_$userPassword', value: userNickName);
        storage.write(key: userNickName, value: STATUS_LOGIN);
        showSnackbar(context, '환영합니다, $userNickName님');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MainPage(
                      nickName: userNickName,
                    )));
      } else {
        showSnackbar(context, 'email이 중복됩니다.');
      }
    } else {
      showSnackbar(context, "입력란을 모두 채워주세요.");
    }
  }
}
