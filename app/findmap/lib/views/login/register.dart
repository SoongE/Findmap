import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

import 'sign_bar.dart';
import '../mainPage.dart';

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
  late TextEditingController _userTOS1;
  late TextEditingController _userTOS2;
  late bool _userTOS1Agree;
  late bool _userTOS2Agree;

  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userName = TextEditingController();
    _userNickName = TextEditingController();
    _userBirth = TextEditingController();
    _userGender = TextEditingController();
    _userPhoneNumber = TextEditingController();
    _userTaste = TextEditingController();
    _userTOS1 = TextEditingController();
    _userTOS2 = TextEditingController();
    _userTOS1Agree = false;
    _userTOS2Agree = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: new Form(
        key: registerFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _userName,
                validator: (val) => CheckValidate().name(_userName.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationBasic('이름', '홍길동', LineIcons.penNib),
              ),
              TextFormField(
                controller: _userNickName,
                validator: (val) =>
                    CheckValidate().nickName(_userNickName.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                    inputDecorationBasic('닉네임', '파인드맵', LineIcons.signature),
              ),
              TextFormField(
                validator: (val) => CheckValidate().birth(val!),
                controller: _userBirth,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationBasic(
                    '생년월일', '1997-04-01', LineIcons.birthdayCake),
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
                decoration: inputDecorationBasic(
                    '성별', '남성/여성/비공개', LineIcons.users,
                    isDence: true),
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    _userGender.text = newValue!;
                  });
                },
              ),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _userPhoneNumber,
                  validator: (val) =>
                      CheckValidate().phoneNumber(_userPhoneNumber.text),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: inputDecorationBasic(
                      '전화번호', '010-0000-0000', LineIcons.phone),
                  inputFormatters: [MaskedInputFormatter('###-####-####')]),
              TextFormField(
                controller: _userTaste,
                validator: (val) => CheckValidate().taste(val!),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationBasic(
                    '관심 주제/키워드', '클릭하여 선택해주세요', LineIcons.cocktail),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                controller: _userTOS1,
                validator: (val) => CheckValidate().tos(_userTOS1Agree),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationTOS('[필수] 이용약관', _userTOS1Agree),
                onTap: () => {
                  FocusScope.of(context).requestFocus(new FocusNode()),
                  _tosDialog('이용약관', '약관내용1', 1),
                  _userTOS1.text = '[필수] 이용약관',
                },
              ),
              TextFormField(
                controller: _userTOS2,
                validator: (val) => CheckValidate().tos(_userTOS2Agree),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                    inputDecorationTOS('[필수] 개인정보 수집 및 이용', _userTOS2Agree),
                onTap: () => {
                  FocusScope.of(context).requestFocus(new FocusNode()),
                  _tosDialog('개인정보 수집 및 이용', '약관내용2', 2),
                  _userTOS2.text = '[필수] 개인정보 수집 및 이용',
                },
              ),
              SignBarLight(
                label: '개인정보 입력',
                isLoading: _isLoading,
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _checkInput();
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tosDialog(String title, String content, int tosNum) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: Builder(
            builder: (context) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;

              return Container(
                  height: height, width: width, child: Text(content));
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('미동의', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text('동의',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                if (tosNum == 1) {
                  _userTOS1Agree = true;
                } else if (tosNum == 2) {
                  _userTOS2Agree = true;
                }
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _checkInput() {
    if (registerFormKey.currentState!.validate()) {
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
      } else if (responseBody['code'] == 3001) {
        showSnackbar(context, '이미 가입된 계정입니다');
        throw Exception('Response status is failure: $responseBody');
      } else {
        throw Exception('Response status is failure: $responseBody');
      }
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

  InputDecoration inputDecorationBasic(String label, String hint, IconData icon,
      {bool isDence: false}) {
    return InputDecoration(
      isDense: isDence,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      labelText: label,
      labelStyle: TextStyle(fontSize: 16, color: MyColors.darkBlue),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2, color: MyColors.darkBlue),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: MyColors.darkBlue),
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

  InputDecoration inputDecorationTOS(String label, bool agree) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      suffixText: agree ? '동의' : '미동의',
      suffixStyle: TextStyle(
          color: agree ? Colors.green : Colors.grey,
          fontWeight: agree ? FontWeight.bold : null),
      hintText: label,
      hintStyle: TextStyle(fontSize: 16, color: MyColors.darkBlue),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.transparent),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: Colors.transparent),
      ),
      errorStyle: const TextStyle(color: MyColors.darkBlue),
    );
  }
}
