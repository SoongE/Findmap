import 'dart:convert';
import 'dart:io';

import 'package:findmap/models/user.dart';
import 'package:findmap/src/feature_category.dart';
import 'package:findmap/src/my_colors.dart';
import 'package:findmap/src/text.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:smart_select/smart_select.dart';

import '../mainPage.dart';
import 'sign_bar.dart';

class RegisterPage extends StatefulWidget {
  final String userEmail;
  final String userPassword;
  final String nickName;
  final String thumbnailURL;
  final String gender;

  RegisterPage(this.nickName, this.thumbnailURL, this.gender,
      {Key? key, required this.userEmail, required this.userPassword})
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
  GlobalKey<S2MultiState<int>> _categoryKey = GlobalKey<S2MultiState<int>>();
  List<int> _categorySelect = [];

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
    if (widget.nickName != '') {
      _userNickName.text = widget.nickName;
    }
    if (widget.gender != '') {
      _userGender.text = widget.gender;
    }

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
                decoration: inputDecorationBasic('??????', '?????????', LineIcons.penNib),
              ),
              TextFormField(
                controller: _userNickName,
                validator: (val) =>
                    CheckValidate().nickName(_userNickName.text),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                    inputDecorationBasic('?????????', '????????????', LineIcons.signature),
              ),
              TextFormField(
                validator: (val) => CheckValidate().birth(val!),
                controller: _userBirth,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationBasic(
                    '????????????', '1997-04-01', LineIcons.birthdayCake),
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
                items: <String>['??????', '??????', '?????????']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: inputDecorationBasic(
                    '??????', '??????/??????/?????????', LineIcons.users,
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
                      '????????????', '010-0000-0000', LineIcons.phone),
                  inputFormatters: [MaskedInputFormatter('###-####-####')]),
              ElevatedButton(
                onPressed: () {
                  _categoryKey.currentState!.showModal();
                },
                child: Row(
                  children: [
                    _categorySelectPopUp(),
                    Icon(LineIcons.cocktail, color: Colors.grey),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
                    Flexible(
                      child: Text(
                        _categorySelect.isEmpty
                            ? '?????? ??????/?????????'
                            : _convertCategoryIndexToName(_categorySelect),
                        style:
                            TextStyle(fontSize: 16, color: MyColors.darkBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.only(left: 10),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                controller: _userTOS1,
                validator: (val) => CheckValidate().tos(_userTOS1Agree),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: inputDecorationTOS('[??????] ????????????', _userTOS1Agree),
                onTap: () => {
                  FocusScope.of(context).requestFocus(new FocusNode()),
                  _tosDialog('????????????', TERMS_AND_CONDITIONS, 1),
                  _userTOS1.text = '[??????] ????????????',
                },
              ),
              TextFormField(
                controller: _userTOS2,
                validator: (val) => CheckValidate().tos(_userTOS2Agree),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                    inputDecorationTOS('[??????] ???????????? ?????? ??? ??????', _userTOS2Agree),
                onTap: () => {
                  FocusScope.of(context).requestFocus(new FocusNode()),
                  _tosDialog('???????????? ?????? ??? ??????', PERSONAL_INFORMATION, 2),
                  _userTOS2.text = '[??????] ???????????? ?????? ??? ??????',
                },
              ),
              SignBarLight(
                label: '???????????? ??????',
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

  String _convertCategoryIndexToName(List<int> list) {
    String value = '';
    for (var i in list) {
      value += CATEGORY_NAME[i]! + ', ';
    }
    return value;
  }

  Widget _categorySelectPopUp() {
    return SmartSelect<int>.multiple(
      key: _categoryKey,
      value: _categorySelect,
      modalTitle: '?????? ?????????',
      choiceConfig: S2ChoiceConfig(
        overscrollColor: Colors.transparent,
        isGrouped: true,
        layout: S2ChoiceLayout.wrap,
        type: S2ChoiceType.chips,
      ),
      onChange: (state) {
        // For chang immediately
        if (state.value.length > 5) {
          showSnackbar(context, "???????????? 5????????? ?????? ???????????????.\n?????? ????????? ????????? ???????????? ????????????.");
        } else {
          var sendList = _categorySelect;
          for (var i in state.value) {
            var filtered = _categorySelect.where((e) => e == i);
            if (filtered.isEmpty) {
              sendList.add(i);
            } else {
              sendList.remove(i);
            }
          }
          // for (var i in sendList) {
          //   fetchChangeCategory(i);
          // }
          setState(() => _categorySelect = state.value);
        }
      },
      modalHeaderStyle: S2ModalHeaderStyle(
        textStyle: TextStyle(color: Colors.black),
      ),
      modalType: S2ModalType.popupDialog,
      choiceItems: S2Choice.listFrom(
        source: CATEGORY,
        value: (index, Map<String, dynamic> item) => item['index'],
        title: (index, Map<String, dynamic> item) => item['name'],
        group: (index, Map<String, dynamic> item) => item['group'],
      ),
      tileBuilder: (context, state) {
        return Container();
      },
    );
  }

  // Future<void> fetchChangeCategory(int idx) async {
  //   Map<String, dynamic> param = {"categoryIdx": idx};
  //
  //   final response = await http.patch(
  //     Uri.http(BASEURL, '/users/interest'),
  //     headers: {
  //       HttpHeaders.contentTypeHeader: "application/json",
  //       "token": widget.user.accessToken,
  //     },
  //     body: json.encode(param),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     var responseBody = jsonDecode(response.body);
  //     if (responseBody['success']) {
  //     } else {
  //       showSnackbar(context, responseBody['message']);
  //       throw Exception(
  //           'fetchChangeCategory Exception: ${responseBody['message']}');
  //     }
  //   } else {
  //     showSnackbar(context, '????????? ????????? ??????????????????');
  //     throw Exception('Failed to connect to server');
  //   }
  // }

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
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(content),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('?????????', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text('??????',
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
                showSnackbar(context, "???????????????! ${value.nickName}???"),
                fetchRegisterProfile(widget.thumbnailURL, value.accessToken),
                Navigator.pushAndRemoveUntil(context,
                    createRoute(MainPage(user: value)), (route) => false),
              });
        } else {
          showSnackbar(context, "???????????? ??? ????????? ??????????????????");
        }
      });
    }
  }

  Future<bool> fetchSignUp() async {
    String _gender = '';
    if (_userGender.text == '??????')
      _gender = 'M';
    else if (_userGender.text == '??????')
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
      "profileUrl": 'https://localhost',
      "categoryList": _intListToString(_categorySelect)
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
        showSnackbar(context, '?????? ????????? ???????????????');
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
        responseBody['result']['userInfo']['token'] =
            responseBody['result']['token'];

        _saveToSecurityStorage(responseBody['result']['userInfo']);
        return User.fromJson(responseBody['result']['userInfo']);
      } else
        throw Exception('Response status is failure');
    } else {
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
    storage.write(key: 'birthday', value: body['birthday']);
    storage.write(key: 'gender', value: body['gender']);
    storage.write(key: 'taste', value: body['categoryList']);
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
      suffixText: agree ? '??????' : '?????????',
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

  String _intListToString(List<int> categorySelect) {
    String res = '';
    for (var i in categorySelect) {
      res += '${i.toString()},';
    }
    int _lastIndex = res.length;
    res = res.substring(0, _lastIndex - 1);
    return res;
  }

  void fetchRegisterProfile(String url, String userToken) async {
    if (url == '') {
      return;
    }
    Map<String, dynamic> param = {"profileUrl": url};

    final response = await http.post(
      Uri.http(BASEURL, '/users/info-profileUrl'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": userToken,
      },
      body: json.encode(param),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchRegisterProfile Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '????????? ????????? ??????????????????');
      throw Exception('Failed to connect to server');
    }
  }
}
