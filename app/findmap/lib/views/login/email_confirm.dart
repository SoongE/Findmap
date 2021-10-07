import 'dart:convert';
import 'dart:io';

import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/sign_bar.dart';
import 'package:findmap/views/login/validate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

import 'register.dart';

class EmailConfirm extends StatefulWidget {
  final VoidCallback onSignInPressed;

  const EmailConfirm({Key? key, required this.onSignInPressed})
      : super(key: key);

  @override
  _EmailConfirmState createState() => _EmailConfirmState();
}

class _EmailConfirmState extends State<EmailConfirm> {
  late TextEditingController _userConfirmNumber;
  late TextEditingController _userEmail;
  late TextEditingController _userPassword;
  late Future<String> authNumber;

  final GlobalKey<FormState> emailConfirmFormKey = GlobalKey<FormState>();
  ValueNotifier<bool> showRegisterPage = ValueNotifier<bool>(false);

  String _emailConfirmNumber = 'dlrj aksemfrl sjan glaemfek bb....';

  bool _passwordVisible = true;
  bool _isSendConfirmMail = false;

  @override
  void initState() {
    super.initState();
    _userConfirmNumber = TextEditingController();
    _userEmail = TextEditingController();
    _userPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;
    return new Form(
      key: emailConfirmFormKey,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 9,
              child: ListView(
                children: [
                  _emailForm(),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isSendConfirmMail
                        ? Container(
                            key: UniqueKey(),
                            child: _confirmForm(),
                          )
                        : Container(key: UniqueKey()),
                  ),
                  _passwordForm(),
                  _passwordAgainForm(),
                  SignBar(
                    label: 'Sign up',
                    isLoading: _isLoading,
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _checkInputs(context);
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        widget.onSignInPressed.call();
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _emailForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val) => CheckValidate().email(val!),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _userEmail,
        decoration: inputDecorationEmail(),
      ),
    );
  }

  Padding _passwordForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        validator: (val) => CheckValidate().password(val!),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _userPassword,
        obscureText: _passwordVisible,
        decoration: inputDecorationPassword("Password"),
      ),
    );
  }

  Padding _passwordAgainForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        validator: (val) =>
            CheckValidate().passwordAgain(val!, _userPassword.text),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: _passwordVisible,
        decoration: inputDecorationPassword("Password Again"),
      ),
    );
  }

  Padding _confirmForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        validator: (val) =>
            CheckValidate().emailConfirm(val!, _emailConfirmNumber),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _userConfirmNumber,
        decoration:
            inputDecorationBasic("confirmNumber", LineIcons.checkCircle),
      ),
    );
  }

  InputDecoration inputDecorationPassword(String label) {
    return InputDecoration(
      prefixIcon: Icon(LineIcons.key),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
      labelText: label,
      labelStyle: TextStyle(fontSize: 18, color: MyColors.darkBlue),
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
      suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey),
          onPressed: () => setState(() {
                _passwordVisible = !_passwordVisible;
              })),
    );
  }

  InputDecoration inputDecorationEmail() {
    return InputDecoration(
      suffixIcon: TextButton(
        onPressed: () => {
          if (CheckValidate().email(_userEmail.text) == null)
            {
              setState(() {
                _isSendConfirmMail = true;
              }),
              fetchEmailSend(_userEmail.text),
            }
          else
            {
              showSnackbar(context, "이메일을 올바르게 입력해주세요"),
            }
        },
        child: Column(
          children: [
            Icon(
              LineIcons.checkCircle,
              color: Colors.grey[800],
            ),
            Text(
              "인증번호",
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            )
          ],
        ),
      ),
      prefixIcon: Icon(LineIcons.envelope),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
      labelText: "Email",
      labelStyle: TextStyle(fontSize: 18, color: MyColors.darkBlue),
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

  InputDecoration inputDecorationBasic(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
      labelText: label,
      labelStyle: TextStyle(fontSize: 18, color: MyColors.darkBlue),
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

  Future<String> fetchEmailSend(String email) async {
    Map<String, dynamic> body = {
      "email": email,
    };
    final response = await http.post(
      Uri.http(BASEURL, '/users/email-send'),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
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

  void _checkInputs(context) {
    FocusScope.of(context).unfocus();
    if (emailConfirmFormKey.currentState!.validate()) {
      Navigator.push(
          context,
          createRouteRight(RegisterPage(
            userEmail: _userEmail.text,
            userPassword: _userPassword.text,
          )));
    } else {
      showSnackbar(context, "정보를 정확히 입력해주세요");
    }
  }
}
