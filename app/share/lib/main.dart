import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share_service.dart';
import 'package:async/async.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String _title = 'FindMap: scrap contents';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: SharePage(title: 'FindMap'),
    );
  }
}

class SharePage extends StatefulWidget {
  SharePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  String _sharedUrl = "";
  late TextEditingController _titleScrapPage;
  var _commentScrapPage = TextEditingController(text: "");
  var _newFolderName = TextEditingController(text: null);
  bool _isPublic = false; // false 면 비공개 true 면 공개
  var _folderList;
  var _selectedValue;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final GlobalKey<FormState> folderFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Create the share service
    ShareService()
    // Register a callback so that we handle shared data if it arrives while the
    // app is running
      ..onDataReceived = _handleSharedData

    // Check to see if there is any shared data already, meaning that the app
    // was launched via sharing.
      ..getSharedData().then(_handleSharedData);
  }

  @override
  void dispose() {
    _titleScrapPage.dispose();
    _commentScrapPage.dispose();
    _newFolderName.dispose();
    super.dispose();
  }

  /// Handles any shared data we may receive.
  void _handleSharedData(String sharedData) {
    setState(() {
      _sharedUrl = sharedData;
      print(_sharedUrl);
      //node.js로 url을 전송!
    });
  }

  _getScrapData() {
    // node.js로부터 제목과 카테고리 등을 받아온다
    // 지금은 아직 node랑 연결이 안 되었으니 임시로 동작이 잘 되는지만 확인 용도
    // setState했을 때 future도 다시 불러오는걸 방지하기 위해서 memoizer를 사용함
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 2));
      _titleScrapPage = TextEditingController(text: "오늘의 일기: 오늘은 너무너무 덥다 | 네이버 블로그");
      _folderList = ['구독좋아요알림🥰', '안녕', 'HELLO', 'こんにちは', '你好'];
      print("Call!");
      return 'Call Data';
    });
  }

  findFolderUsingIndexWhere(List _folderList, String _newFolderName) {
    // Find the index of folder. If not found, index = -1
    final index = _folderList.indexWhere((element) =>
    element == _newFolderName);
    if (index >= 0)
      return 1;
    else
      return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.yellow[700],
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        leading:
          IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.yellow[700],
            onPressed: () => SystemNavigator.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded),
            color: Colors.yellow[700],
            onPressed: () {
              // comments, folder 등의 정보를 node.js 로 전송
              print(_titleScrapPage.text);
              print(_folderList);
              print("사용자가 고른 폴더명:" + _selectedValue);
              print(_commentScrapPage.text);
              print(_isPublic);
              SystemNavigator.pop();
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
                }
                else if (snapshot.hasError) {
                  // error 발생 시 반환하게 되는 부분
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '이런! 문제가 발생했어요\n다시 시도해주세요',
                      style:TextStyle(fontSize: 15),
                    ),
                  );
                }
                else {
                  return Padding (
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget> [
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
                                borderRadius: BorderRadius.circular(12), //border corner radius
                                boxShadow:[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), //color of shadow
                                    spreadRadius: 2, //spread radius
                                    blurRadius: 5, // blur radius
                                    offset: Offset(0, 2), // changes position of shadow
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
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
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
                                borderRadius: BorderRadius.circular(20), //border corner radius
                                boxShadow:[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), //color of shadow
                                    spreadRadius: 2, //spread radius
                                    blurRadius: 5, // blur radius
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 35,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          focusColor: Colors.white,
                                          value: _selectedValue,
                                          items: _folderList.map<DropdownMenuItem<String>>(
                                              (String value) {
                                                return DropdownMenuItem(
                                                  value: value,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Container(width : MediaQuery.of(context).size.width * 0.6, child: Text(value,))
                                                  ),
                                                );
                                              },
                                          ).toList(),
                                          onChanged: (value) {
                                            FocusScope.of(context).requestFocus(new FocusNode());
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
                                      }
                                    ),
                                  ]
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
                                borderRadius: BorderRadius.circular(12), //border corner radius
                                boxShadow:[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), //color of shadow
                                    spreadRadius: 2, //spread radius
                                    blurRadius: 5, // blur radius
                                    offset: Offset(0, 2), // changes position of shadow
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
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      FocusScope.of(context).requestFocus(new FocusNode());
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
              }
            ),
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
          shape: RoundedRectangleBorder(borderRadius:
          BorderRadius.all(Radius.circular(12.0))),
          contentPadding: const EdgeInsets.all(20.0),
          content: Form(
            key: this.folderFormKey,
            child: new Row(
              children: <Widget> [
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
                      }
                      else if (findFolderUsingIndexWhere(_folderList,
                          _newFolderName.text.trim()) > 0) {
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
                  };
                })
          ],
        );
      },
    );
  }
}