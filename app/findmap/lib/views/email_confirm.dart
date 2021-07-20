import 'dart:convert';
import 'dart:io';

import 'package:findmap/utils/utils.dart';
import 'package:findmap/utils/validate.dart';
import 'package:findmap/views/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EmailConfirmPage extends StatefulWidget {
  @override
  _EmailConfirmPageState createState() => _EmailConfirmPageState();
}

class _EmailConfirmPageState extends State<EmailConfirmPage> {
  late TextEditingController _userConfirmNumber;
  late TextEditingController _userEmailCtrl;
  late TextEditingController _userPasswordCtrl;
  late Future<String> authNumber;

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
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
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
              _confirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmWidget() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      focusNode: _confirmFocus,
      validator: (val) =>
          CheckValidate().emailConfirm(val!, _emailConfirmNumber),
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
      validator: (val) => CheckValidate().email(val!),
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
      validator: (val) => CheckValidate().password(val!),
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
      validator: (val) =>
          CheckValidate().passwordAgain(val!, _userPasswordCtrl.text),
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
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      _isSendConfirmMail
          ? _registerCheck()
          : fetchEmailSend(_userEmailCtrl.text);
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

    Navigator.push(
        context,
        createRoute(RegisterPage(
          userEmail: userEmail,
          userPassword: userPassword,
        )));
  }

  Future<String> fetchEmailSend(String email) async {
    Map<String, dynamic> body = {
      "email": email,
    };
    final response = await http.post(
      Uri.http(BASEURL, '/users/email-send'),
      headers: {
        // HttpHeaders.authorizationHeader: "Basic your_api_token_here",
        HttpHeaders.contentTypeHeader: "application/json"
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        _emailConfirmNumber =
            jsonDecode(response.body)['result']['authNumber'].toString();
      });

      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
