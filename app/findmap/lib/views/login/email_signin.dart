import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/sign_bar.dart';
import 'package:findmap/views/login/validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../mainPage.dart';
import 'kakao_login.dart';

class SignIn extends StatefulWidget {
  final VoidCallback onRegisterClicked;

  const SignIn({
    Key? key,
    required this.onRegisterClicked,
  }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isLoading = false;
  bool _passwordVisible = true;
  late TextEditingController _userEmail;
  late TextEditingController _userPassword;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userEmail = TextEditingController();
    _userPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: loginFormKey,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                child: Column(children: [
                  Spacer(flex: 1),
                  Text(
                    "Draw your map",
                    style: TextStyle(
                        fontFamily: "FugazOne",
                        fontSize: 20,
                        color: Colors.grey[700]),
                  ),
                  Text(
                    "FindMap",
                    style: TextStyle(fontFamily: "FugazOne", fontSize: 50),
                  ),
                  Spacer(flex: 1),
                ]),
                alignment: Alignment.center,
              ),
            ),
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextFormField(
                      controller: _userEmail,
                      validator: (val) =>
                          CheckValidate().email(_userEmail.text),
                      autovalidateMode: AutovalidateMode.disabled,
                      keyboardType: TextInputType.emailAddress,
                      decoration: signInInputDecorationEmail(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextFormField(
                      controller: _userPassword,
                      validator: (val) =>
                          CheckValidate().loginPassword(_userPassword.text),
                      autovalidateMode: AutovalidateMode.disabled,
                      obscureText: _passwordVisible,
                      keyboardType: TextInputType.text,
                      decoration: signInInputDecorationPassword(),
                    ),
                  ),
                  SignBar(
                    label: 'Sign in',
                    isLoading: _isLoading,
                    onPressed: () => _login(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        widget.onRegisterClicked.call();
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: KakaoLogin(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    setState(() {
      _isLoading = true;
    });
    if (loginFormKey.currentState!.validate()) {
      Future<User> user = fetchSignIn();
      user.then((value) => {
        // Todo remove print
            print(value.toJson().toString()),
            showSnackbar(context, "환영합니다! ${value.nickName}님"),
            Navigator.pushAndRemoveUntil(
                context, createRoute(MainPage(user: value)), (route) => false),
          });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<User> fetchSignIn() async {
    Map<String, dynamic> body = {
      "email": _userEmail.text,
      "password": _userPassword.text,
    };

    final response = await http.post(
      Uri.http(BASEURL, '/users/signin'),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        responseBody['result']['userInfo']['token'] =
            responseBody['result']['token'];

        _saveToSecurityStorage(responseBody['result']['userInfo']);
        return User.fromJson(responseBody['result']['userInfo']);
      } else if (responseBody['code'] == 3004) {
        final snackBar = SnackBar(
          content: Text("등록된 계정이 없습니다. 회원가입을 진행하세요!"),
          action: SnackBarAction(
            label: '회원가입',
            onPressed: () => widget.onRegisterClicked.call(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        throw Exception(
            'Need to sign up: ${responseBody['message'].toString()}');
      } else if (responseBody['code'] == 3005) {
        showSnackbar(context, "비밀번호가 일치하지 않습니다");
        throw Exception(
            'Password is not correct: ${responseBody['message'].toString()}');
      } else {
        showSnackbar(context, responseBody['message'].toString());
        throw Exception('Response status is failure: $responseBody');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void _saveToSecurityStorage(dynamic body) {
    final storage = FlutterSecureStorage();

    storage.write(key: 'userIdx', value: body['userIdx'].toString());
    storage.write(key: 'token', value: body['token']);
    storage.write(key: 'nickName', value: body['nickName']);
    storage.write(key: 'name', value: body['name']);
    storage.write(key: 'email', value: body['email']);
    // storage.write(key: 'password', value: body['password']);
    storage.write(key: 'birthday', value: body['birthday']);
    storage.write(key: 'gender', value: body['gender']);
    storage.write(key: 'taste', value: body['categoryList']);
  }

  InputDecoration signInInputDecorationPassword() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
      labelText: "Password",
      labelStyle: TextStyle(fontSize: 18, color: Colors.white),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.white),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MyColors.darkBlue),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: MyColors.darkBlue),
      ),
      errorStyle: const TextStyle(color: MyColors.darkBlue),
      suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey),
          onPressed: () => setState(() {
                _passwordVisible = !_passwordVisible;
              })),
    );
  }

  InputDecoration signInInputDecorationEmail() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
      labelText: "Email",
      labelStyle: TextStyle(fontSize: 18, color: Colors.white),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.white),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MyColors.darkBlue),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: MyColors.darkBlue),
      ),
      errorStyle: const TextStyle(color: MyColors.darkBlue),
    );
  }
}
