import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SharePage extends StatefulWidget {
  SharePage({Key? key, required this.url, required this.user})
      : super(key: key);
  final String url;
  final User user;

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  late TextEditingController _titleScrapPage;
  var _commentScrapPage = TextEditingController(text: "");
  var _newFolderName = TextEditingController(text: null);
  bool _isPublic = false; // false 면 비공개 true 면 공개
  var _folderList;
  var _selectedValue;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final GlobalKey<FormState> folderFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleScrapPage.dispose();
    _commentScrapPage.dispose();
    _newFolderName.dispose();
    super.dispose();
  }

  _getScrapData() {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 2));
      _titleScrapPage =
          TextEditingController(text: "오늘의 일기: 오늘은 너무너무 덥다 | 네이버 블로그");
      _folderList = ['구독좋아요알림🥰', '안녕', 'HELLO', 'こんにちは', '你好'];
      print("Call!");
      return 'Call Data';
    });
  }

  findFolderUsingIndexWhere(List _folderList, String _newFolderName) {
    // Find the index of folder. If not found, index = -1
    final index =
        _folderList.indexWhere((element) => element == _newFolderName);
    if (index >= 0)
      return 1;
    else
      return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('아카이브에 저장', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded, color: Colors.black),
            onPressed: () {
              fetchSaveScrap(_titleScrapPage.text, _newFolderName.text,
                  _commentScrapPage.text, _isPublic);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
                future: this._getScrapData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    // 아직 데이터를 받아오지 못한 경우!
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // error 발생 시 반환하게 되는 부분
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '이런! 문제가 발생했어요\n다시 시도해주세요',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                '스크랩할 글의 제목',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                //border corner radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    //color of shadow
                                    spreadRadius: 2,
                                    //spread radius
                                    blurRadius: 5,
                                    // blur radius
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                controller: _titleScrapPage,
                                minLines: 3,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  hintText: "글의 제목을 적어보세요!",
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 13),
                              height: 1,
                              width: double.maxFinite,
                              color: Colors.grey,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                '스크랩할 글의 폴더',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                //border corner radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    //color of shadow
                                    spreadRadius: 2,
                                    //spread radius
                                    blurRadius: 5,
                                    // blur radius
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 35,
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            focusColor: Colors.white,
                                            value: _selectedValue,
                                            items: _folderList
                                                .map<DropdownMenuItem<String>>(
                                              (String value) {
                                                return DropdownMenuItem(
                                                  value: value,
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                          child: Text(
                                                            value,
                                                          ))),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              setState(() {
                                                _selectedValue = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.add),
                                          color: Colors.black38,
                                          onPressed: () {
                                            // 폴더 추가
                                            _makeNewFolderDialog();
                                          }),
                                    ]),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 13),
                              height: 1,
                              width: double.maxFinite,
                              color: Colors.grey,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                '코멘트',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                //border corner radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    //color of shadow
                                    spreadRadius: 2,
                                    //spread radius
                                    blurRadius: 5,
                                    // blur radius
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                controller: _commentScrapPage,
                                minLines: 3,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  hintText: '나만의 코멘트를 달아보세요!',
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 13),
                              height: 1,
                              width: double.maxFinite,
                              color: Colors.grey,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '공개 여부 설정',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Switch(
                                    value: _isPublic,
                                    onChanged: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      setState(() {
                                        _isPublic = value;
                                        print(_isPublic);
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  _makeNewFolderDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          contentPadding: const EdgeInsets.all(20.0),
          content: Form(
            key: this.folderFormKey,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: TextFormField(
                    controller: _newFolderName,
                    autofocus: true,
                    onSaved: (value) {
                      setState(() {
                        _folderList.add(_newFolderName.text.trim());
                        _newFolderName = TextEditingController(text: null);
                      });
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '폴더명을 한 글자 이상 작성해주세요';
                      } else if (findFolderUsingIndexWhere(
                              _folderList, _newFolderName.text.trim()) >
                          0) {
                        return '기존에 존재하는 폴더명과 달라야 합니다';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '추가할 폴더의 이름을 적어주세요',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new TextButton(
                child: const Text('취소하기'),
                style: TextButton.styleFrom(
                  primary: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _newFolderName = TextEditingController(text: null);
                  });
                  Navigator.pop(context);
                }),
            new TextButton(
                child: const Text('추가하기'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                ),
                onPressed: () async {
                  if (this.folderFormKey.currentState!.validate()) {
                    this.folderFormKey.currentState!.save();
                    print(_folderList);
                    Navigator.pop(context);
                  }
                  ;
                })
          ],
        );
      },
    );
  }

  void fetchSaveScrap(String title, String newFolderName, String comment,
      bool _isPublic) async {
    Map<String, dynamic> body = {
      "title": title,
      "comment": comment,
      "summary": "SUMMARY",
      "contentUrl": widget.url,
      "thumbnailUrl": "thumbnailUrl",
      "folderIdx": '1',
      "categoryIdx": '23',
      "isFeed": _isPublic ? 'Y' : 'N',
    };
    final response = await http.post(
      Uri.http(BASEURL, '/scrap'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      if (responseBody['success'] == false) {
        showSnackbar(context, responseBody['message']);
      }
      SystemNavigator.pop();
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post!!! ${response.body}');
    }
  }

  Future<List<PostFolder>> fetchGetFolderList() async {
    final response = await http.get(
      Uri.http(BASEURL, '/folders'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success'])
        return responseBody['result']
            .map<PostFolder>((json) => PostFolder.fromJson(json))
            .toList();
      else {
        showSnackbar(context, responseBody['message']);
        throw Exception(
            'fetchGetArchive Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }
}
