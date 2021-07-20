import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmailConfirmPage extends StatefulWidget {
  @override
  _EmailConfirmPageState createState() => _EmailConfirmPageState();
}

class _EmailConfirmPageState extends State<EmailConfirmPage> {
  late TextEditingController _userConfirmNumber;
  late TextEditingController _userEmailCtrl;
  late TextEditingController _userPasswordCtrl;
  String _emailConfirmNumber = 'dlrj aksemfrl sjan glaemfek bb....';

  bool _passwordVisible = true;
  bool _isSendConfirmMail = false;
  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();
  FocusNode _passwordAgainFocus = new FocusNode();
  FocusNode _confirmFocus = new FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userConfirmNumber = TextEditingController(text: '');
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
          'E-mail 회원가입',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: new Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _emailWidget(),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              _passwordWidget(),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              _passwordAgainWidget(),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: _isSendConfirmMail
                    ? Container(
                        key: UniqueKey(),
                        child: Column(children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                          _confirmWidget(),
                        ]),
                      )
                    : Container(key: UniqueKey()),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _confirmButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmWidget() {
    return TextFormField(
      keyboardType: TextInputType.text,
      focusNode: _confirmFocus,
      validator: (val) => CheckValidate()
          .validateEmailConfirm(_confirmFocus, val!, _emailConfirmNumber),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: _userConfirmNumber,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle_rounded),
        labelText: "confirmNumber",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocus,
      validator: (val) => CheckValidate().validateEmail(_emailFocus, val!),
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      keyboardType: TextInputType.text,
      focusNode: _passwordFocus,
      validator: (val) =>
          CheckValidate().validatePassword(_passwordFocus, val!),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: _userPasswordCtrl,
      obscureText: _passwordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_rounded),
        labelText: "Password",
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey),
            onPressed: () => setState(() {
                  _passwordVisible = !_passwordVisible;
                })),
      ),
    );
  }

  Widget _passwordAgainWidget() {
    return TextFormField(
      keyboardType: TextInputType.text,
      focusNode: _passwordAgainFocus,
      validator: (val) => CheckValidate().validatePasswordAgain(
          _passwordAgainFocus, val!, _userPasswordCtrl.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: _passwordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_rounded),
        labelText: "Password again",
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey),
            onPressed: () => setState(() {
                  _passwordVisible = !_passwordVisible;
                })),
      ),
    );
  }

  Widget _confirmButton(context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(MediaQuery.of(context).size.width - 40, 45),
        ),
        onPressed: () => _checkInputs(context),
        child: Text(
          _isSendConfirmMail ? '확인' : '인증번호 보내기',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _checkInputs(context) {
    if (formKey.currentState!.validate()) {
      _isSendConfirmMail ? _registerCheck() : _sendConfirmEmail();
      setState(() {
        _isSendConfirmMail = true;
      });
    }
  }

  void _registerCheck() async {
    final storage = FlutterSecureStorage();
    String userEmail = _userEmailCtrl.text;
    String userPassword = _userPasswordCtrl.text;

    storage.write(key: 'email', value: userEmail);
    storage.write(key: 'password', value: userPassword);
    storage.write(key: 'token', value: "tokenrhcsky");

    Navigator.push(context, createRoute(RegisterPage()));
  }

  void _sendConfirmEmail() {
    _emailConfirmNumber = '1234';
  }
}

class CheckValidate {
  String? validateEmail(FocusNode focusNode, String value) {
    if (value.isEmpty) {
      focusNode.requestFocus();
      return '이메일을 입력하세요.';
    } else {
      String pattern =
          r'^(([^<>()[\]\\,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        focusNode.requestFocus(); //포커스를 해당 textformfield에 맞춘다.
        return '잘못된 이메일 형식입니다.';
      } else {
        return null;
      }
    }
  }

  String? validatePassword(FocusNode focusNode, String value) {
    if (value.isEmpty) {
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    } else {
      String pattern =
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        focusNode.requestFocus();
        return '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      } else {
        return null;
      }
    }
  }

  String? validatePasswordAgain(
      FocusNode focusNode, String value, String password) {
    if (value == password) {
      return null;
    } else {
      focusNode.requestFocus();
      return '비밀번호가 일치하지 않습니다.';
    }
  }

  String? validateEmailConfirm(
      FocusNode focusNode, String value, String confirm) {
    if (value == confirm) {
      return null;
    } else {
      focusNode.requestFocus();
      return '인증번호가 일치하지 않습니다.';
    }
  }
}
