import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/utils/validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

import 'mainPage.dart';

class RegisterPage extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  RegisterPage({Key? key, required this.userEmail, required this.userPassword})
      : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _userName;
  late TextEditingController _userNickName;
  late TextEditingController _userBirth;
  late TextEditingController _userGender;
  late TextEditingController _userPhoneNumber;
  late TextEditingController _userTaste;

  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  bool isInfoComplete = false;

  @override
  void initState() {
    super.initState();
    _userName = TextEditingController();
    _userNickName = TextEditingController();
    _userBirth = TextEditingController();
    _userGender = TextEditingController();
    _userPhoneNumber = TextEditingController();
    _userTaste = TextEditingController();
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
          '회원가입',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: new Form(
        key: formKey2,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _userName,
                validator: (val) => CheckValidate().name(_userName.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixIcon: Icon(LineIcons.penNib),
                  labelText: "이름",
                  hintText: "홍길동",
                  border: OutlineInputBorder(),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                controller: _userNickName,
                validator: (val) =>
                    CheckValidate().nickName(_userNickName.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixIcon: Icon(LineIcons.signature),
                  labelText: "닉네임",
                  hintText: "파인드맵",
                  border: OutlineInputBorder(),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                controller: _userBirth,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixIcon: Icon(LineIcons.birthdayCake),
                  labelText: "생년월일",
                  hintText: "1997-04-01",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime date = DateTime(1900);
                  FocusScope.of(context).requestFocus(new FocusNode());

                  date = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100)))!;

                  _userBirth.text = date.toString().split(' ').elementAt(0);
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              DropdownButtonFormField(
                validator: (val) => CheckValidate().gender(_userGender.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                items: <String>['남성', '여성', '비공개']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  prefixIcon: Icon(LineIcons.users),
                  labelText: "성별",
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    _userGender.text = newValue!;
                  });
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _userPhoneNumber,
                  validator: (val) =>
                      CheckValidate().phoneNumber(_userPhoneNumber.text),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    prefixIcon: Icon(LineIcons.phoneSquare),
                    labelText: "전화번호",
                    hintText: "010-0000-0000",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [MaskedInputFormatter('###-####-####')]),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                controller: _userTaste,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixIcon: Icon(LineIcons.cocktail),
                  labelText: "관심주제/키워드",
                  hintText: "클릭하여 선택해주세요",
                  border: OutlineInputBorder(),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              _confirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmButton(context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        animationDuration: Duration(seconds: 1),
        fixedSize: Size(MediaQuery.of(context).size.width, 45),
      ),
      onPressed: () => _checkInput(),
      child: Text(
        "가입하기",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  void _checkInput() {
    if (formKey2.currentState!.validate()) {
      Future<bool> _isSignUpSuccess = fetchSignUp();

      _isSignUpSuccess.then((value) {
        if (value) {
          Future<User> user = fetchSignIn();
          user.then((value) => {
                showSnackbar(context, "환영합니다! ${value.nickName}님"),
                Navigator.pushAndRemoveUntil(context,
                    createRoute(MainPage(user: value)), (route) => false),
              });
        } else {
          showSnackbar(context, "회원가입 중 문제가 발생했습니다");
        }
      });
    }
  }

  Future<bool> fetchSignUp() async {
    String _gender = '';
    if (_userGender.text == '남성')
      _gender = 'M';
    else if (_userGender.text == '여성')
      _gender = 'W';
    else
      _gender = 'X';

    Map<String, dynamic> body = {
      "email": widget.userEmail,
      "password": widget.userPassword,
      "name": _userName.text,
      "nickName": _userNickName.text,
      "birthday": _userBirth.text,
      "gender": _gender,
      "phoneNum": _userPhoneNumber.text.replaceAll('-', ''),
    };
    final response = await http.post(
      Uri.http(BASEURL, '/users/signup'),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        return responseBody['success'];
      } else
        throw Exception(
            'Response status is failure: ${responseBody['message']}');
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<User> fetchSignIn() async {
    Map<String, dynamic> body = {
      "email": widget.userEmail,
      "password": widget.userPassword,
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
        responseBody['result']['taste'] = _userTaste.text;
        responseBody['result']['email'] = widget.userEmail;
        responseBody['result']['password'] = widget.userPassword;
        responseBody['result']['name'] = _userName.text;
        responseBody['result']['nickName'] = _userNickName.text;
        responseBody['result']['birthday'] = _userBirth.text;
        responseBody['result']['gender'] = 'X';
        responseBody['result']['phoneNum'] =
            _userPhoneNumber.text.replaceAll('-', '');
        print(responseBody['result']);
        // Todo: to here
        _saveToSecurityStorage(responseBody['result']);
        return User.fromJson(responseBody['result']);
      } else
        throw Exception('Response status is failure');
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
