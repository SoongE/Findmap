import 'package:findmap/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:line_icons/line_icons.dart';

import 'mainPage.dart';

class RegisterPage extends StatefulWidget {
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
        fixedSize: Size(MediaQuery
            .of(context)
            .size
            .width, 45),
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
      final storage = FlutterSecureStorage();

      storage.write(key: 'name', value: _userName.text);
      storage.write(key: 'nickName', value: _userNickName.text);
      storage.write(key: 'birth', value: _userBirth.text);
      storage.write(key: 'gender', value: _userGender.text);
      storage.write(key: 'phoneNumber', value: _userPhoneNumber.text);
      storage.write(key: 'taste', value: _userTaste.text);

      showSnackbar(context, "환영합니다, ${_userNickName.text}님");
      Navigator.pushAndRemoveUntil(
          context,
          createRoute(MainPage()), (route) => false);
    }
  }

  _validateFormKey() {
    if (formKey2.currentState!.validate()) {
      setState(() {
        isInfoComplete = true;
      });
    }
  }
}

class CheckValidate {
  String? name(String value) {
    if (value.isEmpty) {
      return '이름을 입력해주세요';
    } else {
      String pattern = r'^[가-힣|a-z|A-Z|]+$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value) || value.length < 2) {
        return '이름을 정확히 입력해주세요';
      } else {
        return null;
      }
    }
  }

  String? nickName(String value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    } else {
      String pattern = r'^[가-힣|a-z|A-Z|0-9]+$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        return '특수문자는 사용 불가합니다';
      } else {
        return null;
      }
    }
  }

  String? gender(String value) {
    if (value.isEmpty) {
      return '성별을 선택해주세요';
    } else {
      return null;
    }
  }
}
