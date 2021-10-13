import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/src/feature_category.dart';
import 'package:findmap/utils/device_info.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/first.dart';
import 'package:findmap/views/userpage/view_document.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

import 'follower_following.dart';
import 'notice.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();

  Setting(this.user);

  final User user;
}

class _SettingState extends State<Setting> {
  GlobalKey<S2SingleState<bool>> _confirmKey = GlobalKey<S2SingleState<bool>>();
  bool _confirmSelect = false;

  GlobalKey<S2MultiState<int>> _categoryKey = GlobalKey<S2MultiState<int>>();
  List<int> _categorySelect = [7, 8, 9, 10];

  final AsyncMemoizer<List<int>> getUserCategoryMemoizer =
      AsyncMemoizer<List<int>>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(color: Colors.black),
          title: Text('설정', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<List<int>>(
              future: getUserCategoryMemoizer
                  .runOnce(() async => await fetchGetUserCategory()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                _categorySelect = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _confirmPopUp(),
                    _categorySelectPopUp(),
                    // _textButton('알림'),
                    _textButton('공지사항', callback: _toNotice),
                    _textButton('관심 카테고리 변경', callback: _changeCategory),
                    _textButton('팔로잉/팔로우', callback: _toFollowingFollow),
                    _textButton('약관 확인', callback: _toDocumentToS),
                    _textButton('오픈소스 라이선스 확인', callback: _toDocumentLicense),
                    _textButton('비밀번호 변경'),
                    _textButton('문의', callback: _sendEmail),
                    _textButton('회원탈퇴', callback: _withdrawal),
                    _textButton('로그아웃', callback: _logout),
                    _footer(),
                  ],
                );
              },
            )),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajou Nice Team',
            style: TextStyle(
                color: Colors.black, fontFamily: 'FugazOne', fontSize: 16),
          ),
          Text('', style: TextStyle(fontSize: 5)),
          Text('Findmap은 2021 한이음 프로젝트를 기반으로 만들어진 애플리케이션입니다.',
              style: TextStyle(color: Colors.grey[600]))
        ],
      ),
    );
  }

  Widget _textButton(String title, {VoidCallback? callback}) {
    return TextButton(
      onPressed: () => callback!(),
      child: Text(title, style: TextStyle(color: Colors.black, fontSize: 15)),
      style: ButtonStyle(
          alignment: Alignment.centerLeft,
          splashFactory: NoSplash.splashFactory),
    );
  }

  void _toFollowingFollow() {
    Navigator.of(context).push(createRoute(FollowerFollowing(widget.user)));
  }

  void _toDocumentToS() {
    Navigator.of(context).push(createRoute(DocumentView(name: 'ToS')));
  }

  void _toDocumentLicense() {
    Navigator.of(context).push(createRoute(DocumentView(name: 'license')));
  }

  void _toNotice() {
    Navigator.of(context).push(createRoute(Notice()));
  }

  void _changeCategory() async {
    fetchGetUserCategory().then((value) => _categorySelect = value);
    _categoryKey.currentState!.showModal();
  }

  void _withdrawal() async {
    _confirmKey.currentState!.showModal();
    Navigator.pushAndRemoveUntil(
        context, createRoute(FirstPage()), (route) => false);
  }

  void _logout() async {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();

    fetchSignOut().then((value) => value
        ? {
            showSnackbar(context, "정상적으로 로그아웃 되었습니다"),
            Navigator.pushAndRemoveUntil(
                context, createRoute(FirstPage()), (route) => false),
          }
        : showSnackbar(context, "정상적으로 로그아웃되지 않았습니다"));
    // : Navigator.pushAndRemoveUntil(
    //     context, createRoute(FirstPage()), (route) => false));
  }

  void _sendEmail() async {
    String body = await _getEmailBody();

    final Email email = Email(
      body: body,
      subject: '[${widget.user.nickName}] Findmap 문의',
      recipients: ['findmap@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      String title = "";
      String content =
          "${widget.user.nickName}님 죄송합니다🤣\n\n기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를 전송하기 어려운 상황입니다.\n\n아래 이메일로 연락주시면 Findmap 고객센터에서 친절하게 답변을 드리도록 하겠습니다.\n\n- 이메일: findmap@gmail.com\n- 전화: 010-0000-0000\n\n다시한번 불편을 드려서 죄송합니다.";
      shotConfirmAlert(context, title, content, '확인');
    }
  }

  Future<String> _getEmailBody() async {
    Map<String, dynamic> appInfo = await getAppInfo();
    Map<String, dynamic> deviceInfo = await getDeviceInfo();

    Map<String, dynamic> userInfo = {
      'Idx': widget.user.userIdx,
      '이름': widget.user.name,
      '닉네임': widget.user.nickName,
      '이메일': widget.user.email,
    };

    String body = "";

    body += "==============\n";
    body += "아래 내용을 함께 보내주시면 큰 도움이 됩니다 🧅\n";

    userInfo.forEach((key, value) {
      body += "$key: $value\n";
    });

    appInfo.forEach((key, value) {
      body += "$key: $value\n";
    });

    deviceInfo.forEach((key, value) {
      body += "$key: $value\n";
    });

    body += "==============\n";

    return body;
  }

  Future<bool> fetchSignOut() async {
    final response = await http.patch(
      Uri.http(BASEURL, '/users/logout'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  Future<bool> fetchWithdrawal() async {
    final response = await http.patch(
      Uri.http(BASEURL, '/users/withdraw'),
      headers: {
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        return responseBody['success'];
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchWithdrawal Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }

  Future<List<int>> fetchGetUserCategory() async {
    final response = await http.get(
      Uri.http(BASEURL, '/users/interest'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      if (responseBody['success']) {
        if (responseBody['result'] == null) return [];
        List<int> interest = [];
        for (var i in responseBody['result']) {
          interest.add(i['categoryIdx']);
        }
        return interest;
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetUserCategory Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> fetchChangeCategory(int idx) async {
    Map<String, dynamic> param = {"categoryIdx": idx};

    final response = await http.patch(
      Uri.http(BASEURL, '/users/interest'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode(param),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchChangeCategory Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server');
    }
  }

  Widget _confirmPopUp() {
    return SmartSelect<bool>.single(
      key: _confirmKey,
      value: _confirmSelect,
      title: "",
      onChange: (state) {
        if (state.value) {
          final storage = new FlutterSecureStorage();
          storage.deleteAll();

          fetchWithdrawal().then((value) => value
              ? {
                  showSnackbar(context, "회원탈퇴가 완료되었습니다"),
                  Navigator.pushAndRemoveUntil(
                      context, createRoute(FirstPage()), (route) => false),
                }
              : Navigator.pushAndRemoveUntil(
                  context, createRoute(FirstPage()), (route) => false));

          _confirmSelect = false;
        }
      },
      choiceLayout: S2ChoiceLayout.wrap,
      modalType: S2ModalType.bottomSheet,
      modalHeaderBuilder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '정말 탈퇴를 진행하시겠습니까?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
                  Text('사용자와 관련된 모든 정보가 폐기되고 되돌릴 수 없습니다. 그래도 탈퇴하시겠습니까?')
                ],
              ),
            ),
          ),
        );
      },
      modalHeaderStyle: S2ModalHeaderStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      modalStyle: S2ModalStyle(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      choiceItems: [S2Choice<bool>(value: true, title: '네, 회원 탈퇴를 진행합니다')],
      choiceDivider: true,
      choiceBuilder: (context, choice, searchText) {
        return InkWell(
          onTap: () => choice.select(!choice.selected),
          child: Container(
            padding: const EdgeInsets.all(7),
            child: Text(
              choice.title,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      tileBuilder: (context, state) {
        return Container();
      },
    );
  }

  Widget _categorySelectPopUp() {
    return SmartSelect<int>.multiple(
      key: _categoryKey,
      value: _categorySelect,
      modalTitle: '맞춤 서비스',
      choiceConfig: S2ChoiceConfig(
        overscrollColor: Colors.transparent,
        isGrouped: true,
        layout: S2ChoiceLayout.wrap,
        type: S2ChoiceType.chips,
      ),
      onChange: (state) {
        // For changing immediately
        print(state.value);
        if (state.value.length > 5) {
          showSnackbar(context, "관심사는 5개까지 선택 가능합니다.\n최근 수정한 내용은 반영되지 않습니다.");
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
          for (var i in sendList) {
            fetchChangeCategory(i);
          }
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
}
