import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:findmap/models/post_folder.dart';
import 'package:findmap/models/user.dart';
import 'package:findmap/src/feature_category.dart';
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
  var _titleScrapPage = TextEditingController(text: "");
  var _commentScrapPage = TextEditingController(text: "");
  var _newFolderName = TextEditingController(text: "");
  var _summaryScrapPage = TextEditingController(text: "");
  var _thumbnailUrl = '';
  int _categoryIdx = -1;
  bool _isPublic = false; // false 면 비공개 true 면 공개
  List<String> _folderList = ['아카이브'];
  List<PostFolder> _postFolderList = [
    PostFolder(0, -1, '아카이브', -1, '', '', '')
  ];
  String _selectedValue = '아카이브';
  final GlobalKey<FormState> folderFormKey = GlobalKey<FormState>();
  final AsyncMemoizer<Map> getScrapDataMemoizer = AsyncMemoizer<Map>();

  @override
  void initState() {
    fetchGetFolderList().then((value) {
      _postFolderList.addAll(value);
      setState(() {
        _folderList.addAll(value.map((e) => e.name));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleScrapPage.dispose();
    _commentScrapPage.dispose();
    _newFolderName.dispose();
    super.dispose();
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
              fetchSaveScrap(
                  _titleScrapPage.text,
                  _summaryScrapPage.text,
                  _newFolderName.text,
                  _commentScrapPage.text,
                  _thumbnailUrl,
                  _categoryIdx,
                  _isPublic);
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
                future: getScrapDataMemoizer
                    .runOnce(() async => await fetchGetScrapData(widget.url)),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('');
                  } else {
                    Map data = snapshot.data;
                    _titleScrapPage.text = data['title'];
                    _thumbnailUrl = data['thumbnailUrl'];
                    _summaryScrapPage.text = data['summary'];
                    _categoryIdx = data['categoryIdx'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                '제목',
                                style: TextStyle(
                                  fontSize: 18,
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
                                '요약',
                                style: TextStyle(
                                  fontSize: 18,
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
                                controller: _summaryScrapPage,
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
                                '폴더',
                                style: TextStyle(
                                  fontSize: 18,
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
                                                        child:
                                                            _selectedValue ==
                                                                    value
                                                                ? Row(
                                                                    children: [
                                                                        Text(
                                                                          value,
                                                                          style:
                                                                              TextStyle(color: Colors.green),
                                                                        ),
                                                                        Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3)),
                                                                        Icon(
                                                                            Icons
                                                                                .check,
                                                                            color:
                                                                                Colors.green)
                                                                      ])
                                                                : Text(value),
                                                      )),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              setState(() {
                                                _selectedValue =
                                                    value.toString();
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

  Future<Map> fetchGetScrapData(String url) async {
    Map<String, dynamic> param = {"url": url};

    final response =
        await http.get(Uri.http(BASEURL, '/test/share', param), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      "token": widget.user.accessToken,
    }).timeout(Duration(minutes: 2));

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'success') {
        print(responseBody);
        return {
          'title': responseBody['body']['title'],
          'summary': responseBody['body']['description'],
          'categoryIdx': CATEGORY_INDEX[responseBody['body']['category']] ?? 0,
          'thumbnailUrl': responseBody['body']['img_url'],
        };
      } else {
        showSnackbar(context, '제목과 내용을 찾지 못했습니다. 직접 넣어주세요.');
        throw Exception(
            'fetchGetScrapData Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to connect to server\n${response.body}');
    }
  }

  int findFolderUsingIndexWhere(List _folderList, String _newFolderName) {
    // Find the index of folder. If not found, index = -1
    final index =
        _folderList.indexWhere((element) => element == _newFolderName);
    if (index >= 0)
      return 1;
    else
      return -1;
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
                      var folderName = _newFolderName.text.trim();
                      fetchAddFolder(folderName).then((value) {
                        setState(() => {
                              _folderList.add(folderName),
                              _selectedValue = folderName,
                              _newFolderName =
                                  TextEditingController(text: null),
                            });
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
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  setState(() {
                    _newFolderName = TextEditingController(text: null);
                  });
                  Navigator.pop(context);
                }),
            new TextButton(
                child: const Text('추가'),
                onPressed: () async {
                  if (this.folderFormKey.currentState!.validate()) {
                    this.folderFormKey.currentState!.save();
                    Navigator.pop(context);
                  }
                })
          ],
        );
      },
    );
  }

  Future<void> fetchAddFolder(String name) async {
    final response = await http.post(
      Uri.http(BASEURL, '/folders'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": widget.user.accessToken,
      },
      body: json.encode({"name": name}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        int idx = responseBody['result']['insertId'];
        _postFolderList.add(PostFolder(idx, -1, name, -1, '', '', ''));
      } else {
        showSnackbar(context, responseBody['message']);
        throw Exception('fetchAddFolder Exception: ${responseBody['message']}');
      }
    } else {
      showSnackbar(context, '서버와 연결이 불안정합니다');
      throw Exception('Failed to load post');
    }
  }

  void fetchSaveScrap(
      String title,
      String summary,
      String newFolderName,
      String comment,
      String thumbnailUrl,
      int categoryIdx,
      bool _isPublic) async {
    PostFolder _saveFolder =
        _postFolderList.firstWhere((element) => element.name == _selectedValue);
    print(_saveFolder.idx);
    var _folderIdx;
    if (_saveFolder.idx == 0) {
      _folderIdx = '';
    } else {
      _folderIdx = _saveFolder.idx.toString();
    }

    Map<String, dynamic> body = {
      "title": title,
      "comment": comment,
      "summary": summary,
      "contentUrl": widget.url,
      "thumbnailUrl": thumbnailUrl,
      "folderIdx": _folderIdx,
      "categoryIdx": categoryIdx.toString(),
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
      if (responseBody['success'] == false) {
        showSnackbar(context, responseBody['message']);
      } else {
        SystemNavigator.pop();
      }
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
