import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/utils/validate.dart';
import 'package:findmap/views/email_confirm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'mainPage.dart';

class EmailLoginPage extends StatefulWidget {
  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool isLoading = false;
  bool _passwordVisible = true;
  late TextEditingController _userEmail;
  late TextEditingController _userPassword;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userEmail = TextEditingController(text: '');
    _userPassword = TextEditingController(text: '');
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
      body: new Form(
        key: loginFormKey,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 10,
              ),
              _emailWidget(),
              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
              _passwordWidget(),
              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
              _loginButton(context),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              _registerButton(),
              Spacer(
                flex: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      controller: _userEmail,
      validator: (val) => CheckValidate().email(_userEmail.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "E-mail",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordWidget() {
    return TextFormField(
      controller: _userPassword,
      validator: (val) => CheckValidate().loginPassword(_userPassword.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget _loginButton(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () => _login(),
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
          onTap: () => Navigator.push(context, createRoute(EmailConfirmPage())),
          child: Text(
            '회원가입 하러가기',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  void _login() {
    if (loginFormKey.currentState!.validate()) {
      Future<User> user = fetchSignIn();
      user.then((value) => {
            showSnackbar(context, "환영합니다! ${value.nickName}님"),
            Navigator.pushAndRemoveUntil(
                context, createRoute(MainPage(user: value)), (route) => false),
          });
    }
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
        // ToDo: erase later
        responseBody['result']['taste'] = "Taste";
        responseBody['result']['email'] = _userEmail.text;
        responseBody['result']['password'] = _userPassword.text;
        responseBody['result']['name'] = "SeungminOh";
        responseBody['result']['nickName'] = "Rhcsky";
        responseBody['result']['birthday'] = "2020-12-12";
        responseBody['result']['gender'] = 'X';
        responseBody['result']['phoneNum'] = "01011119999";
        print(responseBody['result']);
        // Todo: to here
        _saveToSecurityStorage(responseBody['result']);
        return User.fromJson(responseBody['result']);
      } else
        throw Exception(
            'Response status is failure: ${responseBody['message']}');
    } else {
      throw Exception('Failed to load post');
    }
  }

  void _saveToSecurityStorage(dynamic body) {
    final storage = FlutterSecureStorage();

    storage.write(key: 'userIdx', value: body['userIdx'].toString());
    storage.write(key: 'accessToken', value: body['accessToken']);
    storage.write(key: 'nickName', value: body['nickName']);
    storage.write(key: 'name', value: body['name']);
    storage.write(key: 'email', value: body['email']);
    storage.write(key: 'password', value: body['password']);
    storage.write(key: 'birthday', value: body['birthday']);
    storage.write(key: 'gender', value: body['gender']);
    storage.write(key: 'phoneNum', value: body['phoneNum']);
    storage.write(key: 'taste', value: body['taste']);
  }
}
